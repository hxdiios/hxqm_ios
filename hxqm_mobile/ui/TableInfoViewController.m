//
//  TableInfoViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/27/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "TableInfoViewController.h"
#import "PhotoManager.h"
#import "ContentManager.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "LogUtils.h"
#import "SingleProjectManager.h"
#import "GTMNSString+URLArguments.h"
#import "Constants.h"
#import "SectionCell.h"
#import "SVProgressHUD.h"
#import "GTMNSString+URLArguments.h"
#import "ProblemManager.h"
#import "TemplateManager.h"
#import "MajorProjectListView.h"
#import "TableDetailViewController.h"
#import "RectifyJsToObjectiveC.h"
#import "ProblemManager.h"

#define TAG @"_TableInfoViewController"
// 动画执行的时间
#define kDuration 0.5
#define DELETE_DIALOG 100
#define CHECK_DIALOG 101

@interface TableInfoViewController () <ProjectSelectDelegate> {
    BaseAjaxHttpRequest *request;
    NSMutableDictionary *projectInfo;
    NSArray *permissionList;
    // 保存排好序的列表数据，按照排序类型分组
    NSMutableDictionary *groupedData;
    // 选择的列表行数据
    NSDictionary *selectedSection;
    NSMutableArray *sortedList;
    // 弹出的控制点列表的根View
    UIView *popView;
    // 标记控制点列表是否显示
    BOOL listIsShow;
    // 最后一次选择的类型
    NSString *lastSelectedTemplateType;
    // 判断是否第一次加载
    BOOL isFirst;
    UIImage *selectedImage;
    UIImage *normalImage;
    // 保存收藏状态
    BOOL isFavorite;
    NSMutableArray *lastLoadContentList;
    
    FMDatabase *db;
    NSMutableString *isCheck;
    NSString *boTemplateDetailVerId;
    NSString *boContentName;
    NSString *boCheckProjectId;
    NSString *contentId;
    NSString *tmpProblemType;
}

@end

@implementation TableInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    db = [BaseFunction createDB];
    [db open];
    // Do any additional setup after loading the view from its nib.
    _table.delegate = self;
    _table.dataSource = self;
    
    [self updateBadgeNum];
    
    // 添加导航栏返回按钮
    [self addNavBackBtn];

    groupedData = [NSMutableDictionary dictionary];
    // 不显示没内容的Cell
    _table.tableFooterView = [[UIView alloc] init];
    //添加下拉view
    if (refreshHeaderView == nil) {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _table.bounds.size.height, _table.frame.size.width, _table.bounds.size.height)];
        refreshHeaderView.delegate = self;
        [_table addSubview:refreshHeaderView];
    }
    [refreshHeaderView refreshLastUpdatedDate];
    [self initEmptyViewWithFrame:CGRectMake(0, 0, _table.frame.size.width, _table.frame.size.height)];
    
    // 给table添加长按手势
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableCellLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1;
    [_table addGestureRecognizer:longPressGestureRecognizer];
    
    listIsShow = NO;
    lastSelectedTemplateType = @"";
    sortedList = [[NSMutableArray alloc] init];
    isFirst = YES;
    isInitLoading = YES;
    
    selectedImage = [UIImage imageNamed:@"favorite_selected.png"];
    normalImage = [UIImage imageNamed:@"favorite_normal.png"];
    
    [self initViews];
    [self loadDatas];
    [self reqData];
}

// 看过待办后减少badge的数量
- (void) updateBadgeNum {
    NSInteger badgeNum = [AppConfigure integerForKey:APP_ICON_BADGE_NUM];
    if(badgeNum <= 0) {
        return;
    }
    badgeNum--;
    [AppConfigure setInteger:badgeNum forKey:APP_ICON_BADGE_NUM];
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNum;
    [_delegate delOneBadge];
}

- (void)initViews {
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    if (_projectDict == nil) {
        // 根据工程ID获取工程
        _projectDict = [singleProjectManager getSinglerProjectInfoById:_projectID userid:[AppConfigure objectForKey:USERID]];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectDict = %@", _projectDict]];
    }
    
    _nameLabel.text = [_projectDict objectForKey:@"project_name"];
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectDict = %@", _projectDict]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectID = %@", _projectID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_type = %@", _type]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_sectionID = %@", _sectionID]];

    // 判断是否身份验证
    if (![self getLocationTimeIntervalSinceCurrentDateIsTimeOut]) {
        // 判断是否工程列表进入
        if (![_type isEqualToString:@"2"]) {
            [self SetNavRightBtnVisible:YES];
        }
    }
    // 获得项目信息
    projectInfo = (NSMutableDictionary *) [singleProjectManager getSinglerProjectInfoById:_projectID userid:[AppConfigure objectForKey:USERID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"projectInfo = %@", projectInfo]];
    NSString *favorite = [projectInfo objectForKey:@"favorite_status"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"favorite = %@", favorite]];
    // 判断是否收藏
    if ([@"1" isEqualToString:favorite]) {
        [_favoriteBtn setImage:[UIImage imageNamed:@"favorite_selected.png"] forState:UIControlStateNormal];
        isFavorite = YES;
    }
}

- (void)loadDatas {
    if(isInitLoading) {
        [self.view addSubview:emptyView];
        [emptyView showLoading];
    }
    
    // 获得控制点列表
    PhotoManager *photoManager = [[PhotoManager alloc] initWithDb:db];
    if (permissionList == nil || permissionList.count == 0) {
        permissionList = [self getPermissionList];
    }
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"permissionList = %@", permissionList]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_type = %@.", _type]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_sectionID = %@.", _sectionID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectID = %@.", _projectID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"userid = %@.", [AppConfigure objectForKey:USERID]]];
    
    if ([@"null" isEqualToString:_sectionID] || [@"(null)" isEqualToString:_sectionID] || IsStringEmpty(_sectionID)) {
        _sectionID = @"";
    }
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_sectionID = %@.", _sectionID]];
    NSMutableArray *contentList = [photoManager getContentListBySingleProjectId:_projectID boProjectSectionId:_sectionID type:_type auth:permissionList userid:[AppConfigure objectForKey:USERID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"contentListSize = %lu", (unsigned long)contentList.count]];
    lastLoadContentList = [[NSMutableArray alloc] initWithArray:contentList];
    // 按控制点类别分组排序显示
    groupedData = [self dataSortAndGroupByTypeWithData:contentList];
    [_table reloadData];
    
    isInitLoading = NO;
    [emptyView dismiss];
}

#pragma mark -
#pragma mark 下拉刷新回调的委托方法
- (void)reqData {
    if ([request isExecuting]) {
        [request clearDelegatesAndCancel];
    }
    
    [self updateDatas];
}

#pragma mark 更新数据
- (void)updateDatas {
    // 下拉刷新列表数据
    NSURL *url = [NSURL URLWithString:CONTENT_RECEIVE];
    request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    
    _sectionID = IsStringEmpty(_sectionID) ? @"null" : _sectionID;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"params _sectionID = %@.", _sectionID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"params projectID = %@.", _projectID]];
    NSDictionary *params = @{@"BO_SINGLE_PROJECT_ID":_projectID, @"BO_PROJECT_SECTION_ID":_sectionID};
    
    [request setPostBody:params];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(_table) weakTable = _table;
    __weak typeof(db) weakDb = db;
    [request setCompletionBlock:^{
        NSError *err;
        NSString *responseString = [weakRequest responseString];
        
        if ([responseString myContainsString:SESSION_TIMEOUT]) {
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"responseString = %@", responseString]];
            [weakSelf sessionTimeout];
        } else {
            NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"err = %@", err]];
            
            if (dic != nil) {
                //数据库更新
                // 获得ContentList
                NSArray *contentList = [dic objectForKey:@"CONTENTLIST"];
                [LogUtils Log:TAG content:[NSString stringWithFormat:@"contentList = %@", contentList]];
                ContentManager *contentManager = [[ContentManager alloc] initWithDb:weakDb];
                PhotoManager *photoManager = [[PhotoManager alloc] initWithDb:weakDb];
                // 遍历contentList
                for (NSDictionary *content in contentList) {
                    [LogUtils Log:TAG content:[NSString stringWithFormat:@"content = %@", content]];
                    // 判断是否是巡检类型
                    if ([@"1" isEqualToString:[content objectForKey:@"CONTENT_TYPE"]]) {
                        // 将本地巡检的BO_CONTENT_ID同步为服务器端的BO_CONTENT_ID，替换bo_content表和bo_photo表
                        NSArray *contentIds = [contentManager getContentIdByOths:content userid:[AppConfigure objectForKey:USERID]];
                        [LogUtils Log:TAG content:[NSString stringWithFormat:@"contentIds = %@", contentIds]];
                        if (contentIds.count > 0) {
                            NSString *boContentId = [[contentIds objectAtIndex:0] objectForKey:@"bo_content_id"];
                            [LogUtils Log:TAG content:[NSString stringWithFormat:@"boContentId = %@", boContentId]];
                            if (![boContentId isEqualToString:[content objectForKey:@"BO_CONTENT_ID"]]) {
                                NSString *newContentId = [content objectForKey:@"BO_CONTENT_ID"];
                                [LogUtils Log:TAG content:[NSString stringWithFormat:@"newContentId = %@", newContentId]];
                                [contentManager updateContentWithOldContentId:boContentId newContentId:newContentId];
                                [photoManager updateContent:boContentId newContentId:newContentId];
                            }
                        }
                    }
                }
                
                // 更新本地bo_content表
                BOOL saveResult = [contentManager saveDownloadContents:contentList userid:[AppConfigure objectForKey:USERID]];
                [LogUtils Log:TAG content:[NSString stringWithFormat:@"更新本地bo_content表%@", saveResult ? @"成功" : @"失败"]];
                
                // 获得照片预下载数据
                NSMutableArray *imageList = [NSMutableArray array];
                for (NSDictionary *dict in [dic objectForKey:@"DONWLOAD_IMAGE_LIST"]) {
                    [imageList addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
                }
                // 遍历imageList，对一些字段进行处理
                for (NSMutableDictionary *image in imageList) {
                    //                NSLog(@"image = %@", image);
                    NSString *imageDownloadUrl = [NSString stringWithFormat:@"%@%@%@", BASE_URL, Prefix, @"/imagedir"];
                    NSString *_photoPathUrl = [NSString stringWithFormat:@"%@%@", imageDownloadUrl, [image objectForKey:@"PHOTO_PATH"]];
                    //                [LogUtils Log:TAG content:[NSString stringWithFormat:@"before replace: %@", _photoPathUrl]];
                    _photoPathUrl = [_photoPathUrl stringByReplacingOccurrencesOfString:@"\\\\" withString:@"/"];
                    _photoPathUrl = [_photoPathUrl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
                    //                [LogUtils Log:TAG content:[NSString stringWithFormat:@"after replace: %@", _photoPathUrl]];
                    [image setObject:_photoPathUrl forKey:@"PHOTO_PATH"];
                    NSString *downloadUrl = [NSString stringWithFormat:@"%@%@%@", _photoPathUrl, [image objectForKey:@"FILE_PREFIX"], [image objectForKey:@"FILE_SUFFIX"]];
                    downloadUrl = [downloadUrl stringByReplacingOccurrencesOfString:@"/_SMALL" withString:@""];
                    [image setObject:downloadUrl forKey:@"DOWNLOAD_URL"];
                    NSString *isFormal = [image objectForKey:@"IS_FORMAL"];
                    if ([@"3" isEqualToString:isFormal]) {
                        [image setObject:@"1" forKey:@"TYPE"];
                    } else if ([@"1" isEqualToString:isFormal] || [@"2" isEqualToString:isFormal]) {
                        [image setObject:@"0" forKey:@"TYPE"];
                    }
                }
                
                // 保存到bo_photo表
                [photoManager savePreDownloadPhotos:imageList userid:[AppConfigure objectForKey:USERID]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
            }
            
            // 加载数据
            [weakSelf loadDatas];
        }
        
        [weakSelf doneLoadingTableView:weakTable height:UI_SCREEN_HEIGHT - 64];
    }];
    
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
        
        // 加载本地数据
        [weakSelf loadDatas];
        [weakSelf doneLoadingTableView:weakTable height:UI_SCREEN_HEIGHT - 64];
    }];
    
    [request startAsynchronous];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *headerArray = [groupedData objectForKey:@"sorted_keys"];
    return headerArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *headerArray = [groupedData objectForKey:@"sorted_keys"];
    NSString *header = [headerArray objectAtIndex:section];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = [self getKeyBySection:section withData:groupedData];
    NSArray *contentArray = [groupedData objectForKey:key];
    return contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = (int)indexPath.row;
    static NSString *CustomCellIdentifier = @"SectionCell";

    static BOOL nibsRegistered = NO;
    SectionCell *cell = (SectionCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell == nil) {
        nibsRegistered = NO;
    }
    if (!nibsRegistered) {
        NSLog(@"cell is nil");
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectDict = %@", _projectDict]];
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([SectionCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
        cell = (SectionCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    NSString *key = [self getKeyBySection:indexPath.section withData:groupedData];
    NSArray *contentArray = [groupedData objectForKey:key];
    [cell initViewWithData:[contentArray objectAtIndex:row] type:@"type_table_info"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *key = [self getKeyBySection:indexPath.section withData:groupedData];
    NSArray *contentArray = [groupedData objectForKey:key];
    NSDictionary *selectCellData = [contentArray objectAtIndex:indexPath.row];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"selectCellData = %@", selectCellData]];
    NSString *boContentId = [selectCellData objectForKey:@"bo_content_id"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"boContentId = %@", boContentId]];
    
    NSString *types = ([selectCellData objectForKey:@"types"]==nil)?@"":[selectCellData objectForKey:@"types"];
    NSString *contentType = [selectCellData objectForKey:@"content_type"];
    NSString *checkType = [selectCellData objectForKey:@"check_type"];
    NSString *boProblemId = ([selectCellData objectForKey:@"bo_problem_id"]==nil)?@"":[selectCellData objectForKey:@"bo_problem_id"];
    NSString *checkProjectId = ([selectCellData objectForKey:@"bo_check_project_id"]==nil)?@"":[selectCellData objectForKey:@"bo_check_project_id"];
    if([@"1" isEqualToString:contentType]){
        [self jumpToTableDetailWithContentId:boContentId types:types];
    }else if([@"2" isEqualToString:contentType]){
        //根据检查类型确定整改类型
        NSString *mytype = [[NSString alloc]init];
        if([@"3" isEqualToString:checkType]){
            mytype = @"4";
        }else if([@"4" isEqualToString:checkType]){
            mytype = @"1";
        }
        if([@"" isEqualToString:boProblemId] || [@"(null)" isEqualToString:boProblemId]){
//            ContentManager *contentManager = [[ContentManager alloc]initWithDb:db];
//            NSString *tempProblemId = [[NSUUID UUID] UUIDString];
//            NSMutableDictionary *record = [[NSMutableDictionary alloc]init];
//            [record setValue:boContentId forKey:@"BO_CONTENT_ID"];
//            [record setValue:tempProblemId forKey:@"BO_PROBLEM_ID"];
//            //将检查CONTENT变成草稿状态
//            BOOL flag = [contentManager updateContentInfo:record userid:[AppConfigure objectForKey:@"USERID"]];
//            //保存临时的整改记录
//            BOOL flag1 = [self saveTemporaryProblem:tempProblemId type:mytype];
//            if(flag && flag1){
//                [self jumpToRectifyWithContentId:boContentId types:mytype problemId:tempProblemId isZD:nil];
//            }
            tmpProblemType=mytype;
            contentId = boContentId;
            boCheckProjectId = checkProjectId;
            UIAlertView *checkAlert = [[UIAlertView alloc] initWithTitle:@"检查" message:@"检查是否有问题？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"有",@"没有",nil];
            [checkAlert setTag:CHECK_DIALOG];
            [checkAlert show];
        } else {
            [self jumpToRectifyWithContentId:nil types:types problemId:boProblemId isZD:nil];
        }
    }else if([@"3" isEqualToString:contentType]||[@"-1" isEqualToString:contentType]){
        [self jumpToRectifyWithContentId:nil types:types problemId:boProblemId isZD:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SectionCell *cell = (SectionCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGSize labelSize = [cell.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:cell.titleLabel.font}];
    [cell.titleLabel sizeToFit];
    
    float lines = labelSize.width / (UI_SCREEN_WIDTH - 20);
    int l = (int) lines;
    int lines_final = 0;
    if (lines - l > 0) {
        lines_final = lines + 1;
    } else {
        lines_final = l;
    }
    float part1 = cell.titleLabel.frame.origin.y + lines_final * labelSize.height;
    float part2 = 4 + cell.leftLabel.frame.size.height;
    float part3 = 11;
    float height = part1 + part2 + part3;

    return 1  + height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0f;
}

#pragma mark -
#pragma mark 点击加号
- (void)addSection {
    // 如果列表已经显示，则先隐藏
    [self hideList];
    if (permissionList == nil || permissionList.count == 0) {
        permissionList = [self getPermissionList];
    }
    UIActionSheet *photoTypeSheet;
    if (permissionList.count == 1) {
        photoTypeSheet = [[UIActionSheet alloc] initWithTitle:@"请选择拍照类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"巡检", nil];
        photoTypeSheet.tag = 1;
    } else if (permissionList.count == 2) {
        photoTypeSheet = [[UIActionSheet alloc] initWithTitle:@"请选择拍照类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"项目检查", @"签证检查", nil];
        photoTypeSheet.tag = 2;
    } else if (permissionList.count == 3) {
        photoTypeSheet = [[UIActionSheet alloc] initWithTitle:@"请选择拍照类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"巡检", @"项目检查", @"签证检查", nil];
        photoTypeSheet.tag = 3;
    }
    photoTypeSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [photoTypeSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"actionSheet.tag = %ld", actionSheet.tag]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"buttonIndex = %ld", buttonIndex]];
    switch (actionSheet.tag) {
        case 1:
            if (buttonIndex == 0) {// 巡检
                isCheck = @"1";
                [self showTemplateListWithTemplateType:@"0"];
            }
            break;
        case 2:
            if (buttonIndex == 0) {// 项目检查
                isCheck = @"2";
                [self showTemplateListWithTemplateType:@"1"];
            } else if (buttonIndex == 1) {// 签证检查
                isCheck = @"3";
                [self showTemplateListWithTemplateType:@"2"];
            }
            break;
        case 3:
            if (buttonIndex == 0) {// 巡检
                isCheck = @"1";
                [self showTemplateListWithTemplateType:@"0"];
            } else if (buttonIndex == 1) {// 项目检查
                isCheck = @"2";
                [self showTemplateListWithTemplateType:@"1"];
            } else if (buttonIndex == 2) {// 签证检查
                isCheck = @"3";
                [self showTemplateListWithTemplateType:@"2"];
            }
            break;
        default:
            break;
    }
}

/**
 *  添加或者删除导航栏右侧的加号按钮
 *
 *  @param isVisible 是否要显示按钮
 */
- (void)SetNavRightBtnVisible:(BOOL)isVisible {
    if (isVisible) {
        // 设置导航栏按钮的点击执行方法等
        UIBarButtonItem *addSectionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSection)];
        addSectionItem.tintColor = [UIColor whiteColor];
        NSArray *actionButtonItems = @[addSectionItem];
        self.navigationItem.rightBarButtonItems = actionButtonItems;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark 展现专业下的控制点列表
- (void)showTemplateListWithTemplateType:(NSString *)templateType {
    // 如果点击的类型和最后一次点击的类型相同，则直接显示列表，不用重新加载，如果不相同，则重新加载数据列表
    if (![templateType isEqualToString:lastSelectedTemplateType]) {
        // 保存最后一次的选择类型
        lastSelectedTemplateType = [NSString stringWithFormat:@"%@", templateType];
        
        NSString *boTemplateVerId = [_projectDict objectForKey:@"bo_template_ver_id"];
        NSString *boTemplateId = [_projectDict objectForKey:@"bo_template_id"];
        
        TemplateManager *templateManager = [[TemplateManager alloc] initWithDb:db];
        NSMutableArray *templateList = [templateManager getTemplateList:boTemplateVerId boTemplateId:boTemplateId boSingleProjectId:_projectID type:templateType userid:[AppConfigure objectForKey:USERID]];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"templateList = %@", templateList]];
        // 获得列表View
        UIView *listView = [popView viewWithTag:1];
        // 如果存在，则移除
        if (listView != nil) {
            [listView removeFromSuperview];
        }
        [popView removeFromSuperview];
        popView = nil;
        popView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        popView.backgroundColor = [UIColor clearColor];
        
        // 添加一个跟popView等大的Button，用来监听点击事件，隐藏popView
        UIButton *backGroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, popView.frame.size.width, popView.frame.size.height)];
        backGroundBtn.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
        [backGroundBtn addTarget:self action:@selector(clickPopViewBtn:) forControlEvents:UIControlEventTouchUpInside];
        [popView addSubview:backGroundBtn];
        
        // 获得专业名称
        NSString *majorName = [_projectDict objectForKey:@"major_name"];
        // 添加专业行，将majorName的key设置为BO_DICT_NAME，和列表控件里面获取的时候对应
        NSDictionary *major = [NSDictionary dictionaryWithObject:majorName forKey:@"BO_DICT_NAME"];
        
        NSMutableArray *objects = [NSMutableArray arrayWithObjects:@"NO", major, [NSMutableArray array], nil];
        NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"isOpened", @"major_dictionary", @"project_list", nil];
        NSMutableDictionary *majorDict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys];
        // 清空sortedList
        [sortedList removeAllObjects];
        [sortedList addObject:majorDict];
        
        // 排序分组数据
        NSString *headerName = @"";
        NSMutableArray *listArray = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *template in templateList) {
            NSString *boParentId = [template objectForKey:@"bo_parent_id"];
            if ([@"0" isEqualToString:boParentId]) {
                headerName = [template objectForKey:@"bo_name"];
            } else {
                NSString *boName = [template objectForKey:@"bo_name"];
                [template setObject:boName forKey:@"keyname"];
                [listArray addObject:template];
            }
        }
        
        // 按照bo_template_detail_ver_id排序
        [listArray sortUsingComparator:^NSComparisonResult(NSMutableDictionary *obj1, NSMutableDictionary *obj2) {
            return [[obj1 objectForKey:@"bo_template_detail_ver_id"] compare:[obj2 objectForKey:@"bo_template_detail_ver_id"]];
        }];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"after sort listArray = %@", listArray]];
        
        NSMutableDictionary *header = [NSMutableDictionary dictionaryWithObject:headerName forKey:@"BO_DICT_NAME"];
        NSMutableArray *listObjects = [NSMutableArray arrayWithObjects:@"YES", header, listArray, nil];
        NSMutableArray *listKeys = [NSMutableArray arrayWithObjects:@"isOpened", @"major_dictionary", @"project_list", nil];
        NSMutableDictionary *listDict = [NSMutableDictionary dictionaryWithObjects:listObjects forKeys:listKeys];
        [sortedList addObject:listDict];
        
//        NSLog(@"sortedList = %@", sortedList);
        MajorProjectListView *templateListView = [[MajorProjectListView alloc] initWithFrame:CGRectMake(0, 0, popView.frame.size.width, popView.frame.size.height * 0.8)];
        [templateListView setDatas:sortedList];
        templateListView.delegate = self;
        templateListView.tag = 1;
        [popView addSubview:templateListView];
        
        [self.view addSubview:popView];
        [self.view bringSubviewToFront:popView];
    }
    [self showList];
    
    // 隐藏导航栏加号按钮
    [self SetNavRightBtnVisible:NO];
}

- (void)clickPopViewBtn:(id)sender {
    NSLog(@"clickPopViewBtn");
    [self hideList];
}

/**
 *  显示列表
 */
- (void)showList {
    if (!listIsShow) {
        // 列表动画
        [UIView animateWithDuration:kDuration animations:^{
            popView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            listIsShow = YES;
        }];
    }
}

/**
 *  隐藏列表
 */
- (void)hideList {
    if (listIsShow) {
        // 列表动画
        [UIView animateWithDuration:kDuration animations:^{
            popView.frame = CGRectMake(0, -self.view.frame.size.height - 20, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            listIsShow = NO;
            // 显示加号按钮
            [self SetNavRightBtnVisible:YES];
        }];
    }
}

#pragma mark 列表点击回调
- (void)projectSelectAtIndexPath:(NSIndexPath *)indexPath {
    [self hideList];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"indexPath.row = %ld, indexPath.section = %ld", indexPath.row, indexPath.section]];
    NSDictionary *clickedTemplate = [[[sortedList objectAtIndex:indexPath.section] objectForKey:@"project_list"] objectAtIndex:indexPath.row];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"lastSelectedTemplateType = %@", lastSelectedTemplateType]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"clickedTemplate = %@", clickedTemplate]];
    // contentype = 1 不用传types
    // 判断拍照类型是否是巡检
    if ([@"0" isEqualToString:lastSelectedTemplateType]) {// 巡检
        // 遍历控制点list(控制点列表),取与选中行名称一样的控制点的BO_CONTENT_ID,此处操作与点击控制点列表是一样的(点击图一中的人手井,和图二中选人手井)
        NSString *clickedTemplateName = [clickedTemplate objectForKey:@"bo_name"];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"lastLoadContentList = %@", lastLoadContentList]];
        NSDictionary *content = [self getContentByName:clickedTemplateName];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"content = %@", content]];
        [self jumpToTableDetailWithContentId:[content objectForKey:@"bo_content_id"] types:@""];
    } else {
//        // 保存临时bo_content
//        ContentManager *contentManager = [[ContentManager alloc] initWithDb:db];
//        // UUID随机id
//        NSString *boContentId = [[NSUUID UUID] UUIDString];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"boContentId = %@", boContentId]];
//        NSString *verId = [clickedTemplate objectForKey:@"bo_template_detail_ver_id"];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"verId = %@", verId]];
//        // projectID
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"projectID = %@", _projectID]];
//        NSString *boContentName = [clickedTemplate objectForKey:@"bo_name"];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"boContentName = %@", boContentName]];
//        // BO_TOTAL_NUM：0，BO_CURRENT_NUM：0，CONTENT_TYPE：-1
//        NSArray *objects = [NSArray arrayWithObjects:boContentId, verId, _projectID, boContentName, @"0", @"0", @"-1", @"", @"", @"", @"", nil];
//        NSArray *keys = [NSArray arrayWithObjects:@"BO_CONTENT_ID", @"BO_TEMPLATE_DETAIL_VER_ID", @"BO_SINGLE_PROJECT_ID", @"BO_CONTENT_NAME", @"BO_TOTAL_NUM", @"BO_CURRENT_NUM", @"CONTENT_TYPE", @"BO_PROJECT_SECTION_ID", @"DOMAIN_ID", @"BO_CHECK_PROJECT_ID", @"BO_PROBLEM_ID", nil];
//        NSDictionary *record = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
//        
//        BOOL saveResult = [contentManager saveDownloadContent:record userid:[AppConfigure objectForKey:USERID]];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"保存：%@", saveResult ? @"成功" : @"失败"]];
//        // 根据之前拍照类型选择结果,传入不同参数
//        if ([@"1" isEqualToString:lastSelectedTemplateType]) {// 项目检查
//            [self jumpToTableDetailWithContentId:boContentId types:@"1"];
//        } else if ([@"2" isEqualToString:lastSelectedTemplateType]) {// 签证检查
//            [self jumpToTableDetailWithContentId:boContentId types:@"4"];
//        }
        boTemplateDetailVerId = [clickedTemplate objectForKey:@"bo_template_detail_ver_id"];
        boContentName = [clickedTemplate objectForKey:@"bo_name"];
        ProblemManager *problemManager = [[ProblemManager alloc]initWithDb:db];
        BOOL ret = [problemManager isRelativeOrgExists:_projectID userId:[AppConfigure objectForKey:@"USERID"]];
        if(ret){
            [self doIntent];
        }else{
            [self doDownLoadOrgList];
        }
    }
}

#pragma mark 点击收藏
- (IBAction)favoriteBtnClick:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    BOOL isChanged = [singleProjectManager changeFavoriteStatus:_projectID userid:[AppConfigure objectForKey:USERID]];
    // 原本已经收藏的且成功修改状态
    if (isFavorite && isChanged) {
        [_favoriteBtn setImage:normalImage forState:UIControlStateNormal];
        isFavorite = NO;
    } else if (isChanged) {// 可能原本没有收藏，但是成功修改状态
        [_favoriteBtn setImage:selectedImage forState:UIControlStateNormal];
        isFavorite = YES;
    }
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"isChanged = %@", isChanged ? @"YES" : @"NO"]];
}

#pragma mark -
/**
 *  判断最近一次定位是否在有效时间区间内（时间区间：24小时）
 *
 *  @return 定位是否超时
 */
- (BOOL)getLocationTimeIntervalSinceCurrentDateIsTimeOut {
    // 获取最近一次定位的时间
    NSString *GPS_DATE_CURRENT_USERID = [NSString stringWithFormat:@"%@_%@", GPS_DATE, [AppConfigure objectForKey:USERID]];
    NSString *lastLocation = [AppConfigure objectForKey:GPS_DATE_CURRENT_USERID];
    if (IsStringEmpty(lastLocation)) {
        [LogUtils Log:TAG content:@"lastLocation = null"];
        return true;
    }
    //    NSLog(@"lastLocation = %@", lastLocation);
    NSDate *currentDate = [NSDate date];
    //    NSLog(@"currentDate = %f", [currentDate timeIntervalSince1970]);
    NSDate *lastLocationDate = [BaseFunction dateFromString:lastLocation dateFormat:DATE_LONG];
    //    NSLog(@"lastLocationDate = %f", [lastLocationDate timeIntervalSince1970]);
    double timeDifference = [currentDate timeIntervalSinceDate:lastLocationDate];
    //    [LogUtils Log:TAG content:[NSString stringWithFormat:@"timeDifference = %f", timeDifference]];
    
    return [self isTimeOut:timeDifference];
}

/**
 *  判断时间差(秒)是否超过24小时
 *
 *  @param timeDifference 时间差
 *
 *  @return 时间差是否超过24小时
 */
- (BOOL)isTimeOut:(double)timeDifference {
    return timeDifference > 86400;
}

/**
 *  获取权限列表
 *
 *  @return 权限List
 */
- (NSArray *)getPermissionList {
    NSMutableArray *permList = [NSMutableArray array];
    NSString *strategy = [AppConfigure objectForKey:Strategy];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"strategy = %@", strategy]];
    // 判断是否有巡检角色
    if ([strategy myContainsString:SEE_UPLOAD]) {
        [permList addObject:@"巡检"];
    }
    // 判断是否有其他角色
    if ([strategy myContainsString:SEE_JC]) {
        [permList addObject:@"项目检查"];
        [permList addObject:@"签证检查"];
    }
    
    return permList;
}

#pragma mark 按照类别排序分组
- (NSMutableDictionary *)dataSortAndGroupByTypeWithData:(NSMutableArray *)pData {
    // 保存排序分组之后的结果
    NSMutableDictionary *resultDataDic = [NSMutableDictionary dictionary];
    // 保存pData的临时数据
    NSMutableArray *tempDataArray = [NSMutableArray arrayWithArray:pData];
    // 保存排序好的分组名和对应列表key
    NSMutableDictionary *headerDictionary = [NSMutableDictionary dictionary];
    // 默认从1开始，0用来判断是否已经存在
    int index = 1;
    // headerDictionary保存的key，随着类别来改变
    NSString *headerKey = @"";
    
    // 循环遍历临时数据，分组排序数据
    for (NSDictionary *content in tempDataArray) {
        // 先获取类别
        NSString *type = [content objectForKey:@"content_type"];
        NSString *otherVal = [BaseFunction safeGetValueByKey:content Key:@"other_type"];
        if([@"10" isEqualToString:otherVal]){
            type = otherVal;
        }
        // 比较类别，设置headerKey
        if ([@"1" isEqualToString:type]) {
            headerKey = @"巡检记录";
        } else if ([@"2" isEqualToString:type]) {
            headerKey = @"问题检查";
        } else if ([@"3" isEqualToString:type]) {
            headerKey = @"整改记录";
        } else if ([@"10" isEqualToString:otherVal]) {
            headerKey = @"整改草稿";
        }
        
        int headerValue = [[headerDictionary objectForKey:headerKey] intValue];
        if (headerValue == 0) {
            [headerDictionary setObject:[NSString stringWithFormat:@"%d", index] forKey:headerKey];
            headerValue = index++;
        }
        NSString *contentArrayKey = [NSString stringWithFormat:@"%d", headerValue];
        NSMutableArray *contentArray = [resultDataDic objectForKey:contentArrayKey];
        // 判断列表是否为空，为空说明不存在，则初始化deptArray，并添加到resultDataDic中
        if (contentArray == nil) {
            contentArray = [NSMutableArray array];
            [resultDataDic setObject:contentArray forKey:contentArrayKey];
        }
        // 将deptProject添加到对应的列表中
        [[resultDataDic objectForKey:contentArrayKey] addObject:content];
    }
    
    for (NSString *key in resultDataDic) {
        NSMutableArray *array = [resultDataDic objectForKey:key];
        // 按照时间降序排序
        [array sortUsingComparator:^NSComparisonResult(NSMutableDictionary *obj1, NSMutableDictionary *obj2) {
            return [[obj1 objectForKey:@"bo_template_detail_ver_id"] compare:[obj2 objectForKey:@"bo_template_detail_ver_id"]];
        }];
    }
    
    // 将headerDictionary中所有的key排序，并添加到resultDataDic中
    NSMutableArray *sortDistanceListkeys = [NSMutableArray arrayWithArray:[headerDictionary allKeys]];
    [sortDistanceListkeys sortUsingSelector:@selector(compare:)];
    //    [resultDataDic setObject:sortDeptListValues forKey:@"sorted_values"];
    [resultDataDic setObject:sortDistanceListkeys forKey:@"sorted_keys"];
    // 添加headerDictionary，用于在显示列表数据的时候用来获取对应的key
    [resultDataDic setObject:headerDictionary forKey:@"header_dict"];
//    NSLog(@"headerDictionary = %@", headerDictionary);
//    NSLog(@"resultDataDic = %@", resultDataDic);
    
    return resultDataDic;
}

#pragma mark 列表行长按事件
- (void)tableCellLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint tmpPointTouch = [gestureRecognizer locationInView:_table];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [_table indexPathForRowAtPoint:tmpPointTouch];
        if (indexPath == nil) {
            NSLog(@"not tableView");
        }else{
            NSString *key = [self getKeyBySection:indexPath.section withData:groupedData];
            NSArray *dataArray = [groupedData objectForKey:key];
            NSDictionary *rowData = [dataArray objectAtIndex:indexPath.row];
            selectedSection = [NSDictionary dictionaryWithDictionary:rowData];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"selectedSection = %@", selectedSection]];
            NSString *otherType = [rowData objectForKey:@"other_type"];
            // 是否是整改草稿
            if ([@"10" isEqualToString:otherType]) {
                UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"删除" message:@"确定要删除草稿？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [deleteAlert setTag:DELETE_DIALOG];
                [deleteAlert show];
            }
        }
    }
}

#pragma mark AlertView按钮点击回调事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"buttonIndex = %ld", buttonIndex]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"alertView.tag = %ld", alertView.tag]];
    if (alertView.tag == BASE_ALERT_TAG) {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    } else if (1 == buttonIndex && DELETE_DIALOG == alertView.tag) {// 确定删除
        NSLog(@"确定删除");
        [self deleteDraft];
    } else if (1 == buttonIndex && CHECK_DIALOG == alertView.tag){
        ContentManager *contentManager = [[ContentManager alloc]initWithDb:db];
        NSString *tempProblemId = [[NSUUID UUID] UUIDString];
        NSMutableDictionary *record = [[NSMutableDictionary alloc]init];
        [record setValue:contentId forKey:@"BO_CONTENT_ID"];
        [record setValue:tempProblemId forKey:@"BO_PROBLEM_ID"];
        //将检查CONTENT变成草稿状态
        BOOL flag = [contentManager updateContentInfo:record userid:[AppConfigure objectForKey:@"USERID"]];
        //保存临时的整改记录
        BOOL flag1 = [self saveTemporaryProblem:tempProblemId type:tmpProblemType];
        if(flag && flag1){
            [self jumpToRectifyWithContentId:contentId types:tmpProblemType problemId:tempProblemId isZD:nil];
        }
    } else if (2 == buttonIndex && CHECK_DIALOG == alertView.tag){
        [SVProgressHUD showWithStatus:@"正在提交数据，请稍后..."];
        [self doSubmit:contentId boCheckProjectId:boCheckProjectId];
    }
    
}

#pragma mark 删除草稿
- (void)deleteDraft {
    NSString *problemId = [selectedSection objectForKey:@"bo_problem_id"];
    ProblemManager *problemManager = [[ProblemManager alloc] initWithDb:db];
    BOOL isDeleted = [problemManager deleteProblemDraft:problemId userid:[AppConfigure objectForKey:USERID]];
    if (isDeleted) {
        NSLog(@"删除草稿成功");
        ContentManager *contentManager = [[ContentManager alloc] initWithDb:db];
        BOOL isUpdated = [contentManager updateOtherTypeStateWithBoContentId:[selectedSection objectForKey:@"bo_content_id"] userid:[AppConfigure objectForKey:USERID]];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"isUpdated = %@", isUpdated ? @"YES" : @"NO"]];
        [self loadDatas];
    } else {
        NSLog(@"删除草稿失败");
    }
}

#pragma mark 获取分组数据的key
- (NSString *)getKeyBySection:(NSInteger)section withData:(NSMutableDictionary *)gData{
    NSArray *headerArray = [gData objectForKey:@"sorted_keys"];
    NSDictionary *headerDict = [gData objectForKey:@"header_dict"];
    NSString *header = [headerArray objectAtIndex:section];
    NSString *key = [headerDict objectForKey:header];
    
    return key;
}

#pragma mark 跳转到TableDetail界面
- (void)jumpToTableDetailWithContentId:(NSString *)boContentId types:(NSString *)types {
    TableDetailViewController *tableDetailViewController = [[TableDetailViewController alloc] initWithNibName:@"TableDetailViewController" bundle:nil];
    tableDetailViewController.type = types;
    tableDetailViewController.contentID = boContentId;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableDetailViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark 跳转到RectifyJsToObjectiveC界面
- (void)jumpToRectifyWithContentId:(NSString *)boContentId types:(NSString *)types problemId:(NSString *)problemId isZD:(NSString *)isZD{
    RectifyJsToObjectiveC *rectifyJsToObjectiveC = [[RectifyJsToObjectiveC alloc] init];
    rectifyJsToObjectiveC.types = types;
    rectifyJsToObjectiveC.boContentId = boContentId;
    rectifyJsToObjectiveC.boProblemId = problemId;
    rectifyJsToObjectiveC.isZD = isZD;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rectifyJsToObjectiveC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

/**
 *  根据名称获取相同的列表项内容
 *
 *  @param name 名称
 *
 *  @return 相同名称的content数据
 */
- (NSDictionary *)getContentByName:(NSString *)name {
    NSDictionary *findContent;
    for (NSDictionary *content in lastLoadContentList) {
        NSString *contentName = [content objectForKey:@"bo_content_name"];
        if ([name isEqualToString:contentName]) {
            findContent = content;
        }
    }
    
    return findContent;
}

#pragma mark 点击返回按钮
- (void)back:(id)sender {
    NSLog(@"back button clicked");
    if (listIsShow) {
        [self hideList];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
    }
}

#pragma mark - 重新登录
// 登录成功
- (void)loginSuccess {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self updateDatas];
}

// 登录失败
- (void)loginFailed {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark -
- (void)viewDidAppear:(BOOL)animated {
    [db open];
    if (!isFirst) {
        NSLog(@"is not first, refresh datas");
        [self reqData];
    } else {
        NSLog(@"is first");
        isFirst = NO;
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    if ([request isExecuting]) {
        [request clearDelegatesAndCancel];
    }
    [db close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doIntent{
    ContentManager *contentManager = [[ContentManager alloc]initWithDb:db];
    NSString *boContentId = [[NSUUID UUID] UUIDString];
    NSString *boProblemId = [[NSUUID UUID] UUIDString];
    //保存临时content
    NSMutableDictionary *record = [[NSMutableDictionary alloc]init];
    [record setValue:boContentId forKey:@"BO_CONTENT_ID"];
    [record setValue:boTemplateDetailVerId forKey:@"BO_TEMPLATE_DETAIL_VER_ID"];
    [record setValue:_projectID forKey:@"BO_SINGLE_PROJECT_ID"];
    [record setValue:boContentName forKey:@"BO_CONTENT_NAME"];
    [record setValue:@"0" forKey:@"BO_TOTAL_NUM"];
    [record setValue:@"0" forKey:@"BO_CURRENT_NUM"];
    [record setValue:@"-1" forKey:@"CONTENT_TYPE"];
    [record setValue:@"10" forKey:@"OTHER_TYPE"];
    [record setValue:boProblemId forKey:@"BO_PROBLEM_ID"];
    BOOL flag = [contentManager saveDraftContent:record userid:[AppConfigure objectForKey:@"USERID"]];
    NSString *mytype = [[NSString alloc]init];
    if([@"2" isEqualToString:isCheck]){
        mytype = @"1";
    }else if([@"3" isEqualToString:isCheck]){
        mytype = @"4";
    }
    //整改草稿
    BOOL flag1 = [self saveTemporaryProblem:boProblemId type:mytype];
    if(flag && flag1){
        [self jumpToRectifyWithContentId:boContentId types:mytype problemId:boProblemId isZD:@"TRUE"];
    } else{
        [SVProgressHUD showErrorWithStatus:@"系统错误，请重试！"];
    }
//    
//    
//    //整改草稿
//    NSMutableDictionary *record1 = [[NSMutableDictionary alloc]init];
//    [record1 setValue:boProblemId forKey:@"BO_PROBLEM_ID"];
//    [record1 setValue:_projectID forKey:@"BO_SINGLE_PROJECT_ID"];
//    NSDate *currentDate = [NSDate date];
//    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"yyyy-MM-dd"];
//    NSString *searchDate = [dateformatter stringFromDate:[BaseFunction addDay:currentDate dayOfMonth:7]];
//    [record1 setValue:searchDate forKey:@"MEND_TIME_LIMIT"];
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"Init MEND_TIME_LIMIT = %@", searchDate]];
//    if([@"2" isEqualToString:isCheck]){
//        [record1 setValue:@"1" forKey:@"TYPES"];
//    }else if([@"3" isEqualToString:isCheck]){
//        [record1 setValue:@"4" forKey:@"TYPES"];
//    }
//    ProblemManager *problemManager = [[ProblemManager alloc]initWithDb:db];
//    BOOL flag1 = [problemManager saveDraftProblem:record1 userid:[AppConfigure objectForKey:@"USERID"]];
//    if(flag && flag1){
//        if([@"2" isEqualToString:isCheck]){
//            [self jumpToRectifyWithContentId:boContentId types:@"1" problemId:boProblemId isZD:@"TRUE"];
//        }else if([@"3" isEqualToString:isCheck]){
//            [self jumpToRectifyWithContentId:boContentId types:@"4" problemId:boProblemId isZD:@"TRUE"];
//        }
}

- (void) doDownLoadOrgList{
    NSURL *url = [NSURL URLWithString:REFERENCE_ORGS_URL];
    BaseAjaxHttpRequest *request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    NSDictionary *params = @{@"BO_SINGLE_PROJECT_ID" : _projectID};
    
    [request setPostBody:params];
    
    [request setCompletionBlock:^{
        NSError *err;
        NSString *responseString = [weakRequest responseString];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
        NSArray *orgList = [result objectForKey:@"ORG_LIST"];
        NSString *orgType = ([result objectForKey:@"ORG_TYPES"]==nil)?@"":[result objectForKey:@"ORG_TYPES"];
        if (result != nil && [result objectForKey:@"ORG_LIST"]) {
            ProblemManager *problemManager = [[ProblemManager alloc]initWithDb:db];
            BOOL ret = YES;
            for(NSDictionary *orgDict in orgList){
                 ret =ret && [problemManager saveRelativeOrg:orgDict];
            }
            if(ret){
                [self doIntent];
            }else{
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"数据获取失败，请重新尝试！"]];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"数据获取失败，请重新尝试！"]];
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
    }];
    [request startAsynchronous];
}

/**
 *  根据名称获取相同的列表项内容
 *
 *  @param name 名称
 *
 *  @return 相同名称的content数据
 */
-(BOOL) saveTemporaryProblem:(NSString *)boProblemId type:(NSString *)type{
    NSMutableDictionary *record1 = [[NSMutableDictionary alloc]init];
    [record1 setValue:boProblemId forKey:@"BO_PROBLEM_ID"];
    [record1 setValue:_projectID forKey:@"BO_SINGLE_PROJECT_ID"];
    //发起时初始化整改表单整改时限：当前时间7天以后
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *searchDate = [dateformatter stringFromDate:[BaseFunction addDay:currentDate dayOfMonth:7]];
    [record1 setValue:searchDate forKey:@"MEND_TIME_LIMIT"];
    [record1 setValue:type forKey:@"TYPES"];
    ProblemManager *problemManager = [[ProblemManager alloc]initWithDb:db];
    return [problemManager saveDraftProblem:record1 userid:[AppConfigure objectForKey:@"USERID"]];
}

/**
 *  提交
 *
 *  @param boContentId
 *
 */
- (void) doSubmit:(NSString *)boContentId boCheckProjectId:(NSString *)boCheckProjectId{
    NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
    PhotoManager *photoManager = [[PhotoManager alloc]initWithDb:db];
    NSDictionary *lastestRefPhotoMap = [photoManager getLastestRefPhoto];
    [map setValue:[lastestRefPhotoMap valueForKey:@"bo_photo_id"] forKey:@"REF_PHOTO_ID"];
    [map setValue:boContentId forKey:@"BO_CONTENT_ID"];
    [map setValue:boCheckProjectId forKey:@"BO_CHECK_PROJECT_ID"];
    [map setValue:@"FALSE" forKey:@"NEED_ZG"];
    [map setValue:@"" forKey:@"STATE"];
    //发送请求
    NSURL *url = [NSURL URLWithString:checkCompleteUrl];
    BaseAjaxHttpRequest *request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    
    [request setPostBody:map];
    
    [request setCompletionBlock:^{
        NSError *err;
        NSString *responseString = [weakRequest responseString];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
        NSString *flag1 = [result objectForKey:@"RESULT"];
        NSString *boContentId = [result objectForKey:@"BO_CONTENT_ID"];
        if(flag1.boolValue){
            ContentManager *contentManger = [[ContentManager alloc]initWithDb:db];
            [contentManger doCompleteTaskWithBoContentId:boContentId userid:[AppConfigure objectForKey:@"USERID"]];
            [SVProgressHUD showSuccessWithStatus:@"提交成功!"];
            [self loadDatas];
        }else{
            [SVProgressHUD showErrorWithStatus:@"提交失败!"];
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
    }];
    [request startAsynchronous];
}

@end
