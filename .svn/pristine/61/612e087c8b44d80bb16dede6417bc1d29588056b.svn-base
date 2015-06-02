//
//  SectionViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 2/3/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "SectionViewController.h"
#import "SectionManager.h"
#import "AppConfigure.h"
#import "SectionCell.h"
#import "Constants.h"
#import "LogUtils.h"
#import "SVProgressHUD.h"
#import "TableInfoViewController.h"
#import "SingleProjectManager.h"
#import "BaseFunction.h"

#define TAG @"_SectionViewController"
#define ADD_ALERT_TAG 1
#define MODIFY_ALERT_TAG 2

@interface SectionViewController () {
    NSMutableArray *sectionList;
    NSMutableArray*sectionIDList;
    NSDictionary *selectedSection;
    // 判断是否第一次加载
    BOOL isFirst;
    FMDatabase *db;
}

@end

@implementation SectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    db = [BaseFunction createDB];
    [db open];
    // Do any additional setup after loading the view from its nib.
    _table.delegate = self;
    _table.dataSource = self;
    
    // 添加导航栏返回按钮
    [self addNavBackBtn];
    
    // 初始化
    sectionList = [NSMutableArray array];
    sectionIDList = [NSMutableArray array];
    // 不显示没内容的Cell
    _table.tableFooterView = [[UIView alloc] init];
    // 给table添加长按手势
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tableCellLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    [_table addGestureRecognizer:longPressGestureRecognizer];
    isFirst = YES;
    
    [self initViews];
}

#pragma mark 初始化视图
- (void)initViews {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectDict = %@", _projectDict]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectID = %@", _projectID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_type = %@", _type]];
    
    if (_projectDict == nil) {
        // 根据工程ID获取工程
        SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
        _projectDict = [singleProjectManager getSinglerProjectInfoById:_projectID userid:[AppConfigure objectForKey:USERID]];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"before close _projectDict = %@", _projectDict]];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"after close _projectDict = %@", _projectDict]];
    }
    
    // 判断是否工程列表进入
    if ([_type isEqualToString:@"1"]) {
        // 设置导航栏按钮的点击执行方法等
        UIBarButtonItem *addSectionItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSection)];
        addSectionItem.tintColor = [UIColor whiteColor];
        NSArray *actionButtonItems = @[addSectionItem];
        self.navigationItem.rightBarButtonItems = actionButtonItems;
    }
    
    [self getDatas];
}

#pragma mark 获取数据
- (void)getDatas {
    SectionManager *sectionManager = [[SectionManager alloc] initWithDb:db];
    sectionList = [sectionManager getSectionListByProjectId:_projectID userid:[AppConfigure objectForKey:USERID]];
    NSLog(@"sectionList = %@", sectionList);
    if (sectionList != nil && sectionList.count != 0) {
        for (NSDictionary *section in sectionList) {
            [sectionIDList addObject:[section objectForKey:@"bo_project_section_id"]];
        }
        NSLog(@"sectionIDList = %@", sectionIDList);
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sectionList.count;
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
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([SectionCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
        cell = (SectionCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    [cell initViewWithData:[sectionList objectAtIndex:row] type:@"type_section"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *selectedRowData = [sectionList objectAtIndex:indexPath.row];
    // 没有，则跳转到关键控制点界面
    TableInfoViewController *tableInfoViewController = [[TableInfoViewController alloc] initWithNibName:@"TableInfoViewController" bundle:nil];
    tableInfoViewController.projectDict = _projectDict;
    tableInfoViewController.projectID = _projectID;
    tableInfoViewController.type = _type;
    tableInfoViewController.sectionID = [selectedRowData objectForKey:@"bo_project_section_id"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableInfoViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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
//    NSLog(@"height = %f", height + 1);
    return 1  + height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62.0f;
}

#pragma mark -
#pragma mark AlertView按钮点击回调事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"show alert tag = %ld", alertView.tag);
    NSLog(@"buttonIndex = %ld", buttonIndex);
    UITextField *textField = [alertView textFieldAtIndex:0];
    NSString *sectionName = textField.text;
    NSLog(@"sectionName = %@", sectionName);
    if (ADD_ALERT_TAG == alertView.tag) {// 新增
        if (1 == buttonIndex) {// 确定新增
            NSLog(@"确定新增");
            [self addOrModifySectionWithName:sectionName isAdd:YES];
        }
    } else if (MODIFY_ALERT_TAG == alertView.tag) {// 修改
        if (1 == buttonIndex) {// 确定修改
            NSLog(@"确定修改");
            [self addOrModifySectionWithName:sectionName isAdd:NO];
        }
    }
}

#pragma mark 列表行长按事件
- (void)tableCellLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint tmpPointTouch = [gestureRecognizer locationInView:_table];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [_table indexPathForRowAtPoint:tmpPointTouch];
        if (indexPath == nil) {
            NSLog(@"not tableView");
        }else{
            NSDictionary *rowData = [sectionList objectAtIndex:indexPath.row];
            selectedSection = [NSDictionary dictionaryWithDictionary:rowData];
//            NSLog(@"selectedSection = %@", selectedSection);
            NSString *sectionName = [rowData objectForKey:@"section_name"];
            
            UIAlertView *modifyAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"确定要修改这条记录吗？本次操作后将无法删除！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [modifyAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *textField = [modifyAlert textFieldAtIndex:0];
            textField.text = sectionName;
            modifyAlert.tag = MODIFY_ALERT_TAG;
            [modifyAlert show];
        }
    }
}

#pragma mark -
#pragma mark 添加按钮的点击事件
- (void)addSection {
    // 获取sectionNum
    SectionManager *sectionManager = [[SectionManager alloc] initWithDb:db];
    int sectionNum = [sectionManager getCurrentSectionNumber:_projectID userid:[AppConfigure objectForKey:USERID]];
    UIAlertView *addAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"确定要新增这条记录吗？本次操作后将无法删除！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [addAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [addAlert textFieldAtIndex:0];
    textField.text = [NSString stringWithFormat:@"%d#%d#", sectionNum + 1, sectionNum + 2];
    addAlert.tag = ADD_ALERT_TAG;
    [addAlert show];
}

#pragma mark 添加或者修改Section
- (void)addOrModifySectionWithName:(NSString *)sectionName isAdd:(BOOL)isAdd {
    NSURL *url = [NSURL URLWithString:SAVE_SECTION_URL];
    BaseAjaxHttpRequest *request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    // BO_SINGLE_PROJECT_ID:所属工程ID
    // SECTION_NAME:编辑框内填写的分段名称
    // BO_PROJECT_SECTION_ID:空值(新增时),选中分段的ID(修改时)
//    NSLog(@"selectedSection = %@", selectedSection);
    NSString *sectionID = isAdd ? @"" : [selectedSection objectForKey:@"bo_project_section_id"];
//    NSLog(@"sectionID = %@", sectionID);
    NSDictionary *params = @{@"BO_SINGLE_PROJECT_ID" : _projectID, @"SECTION_NAME" : sectionName, @"BO_PROJECT_SECTION_ID" : sectionID};
    
    [request setPostBody:params];
    
    [request setCompletionBlock:^{
        NSError *err;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[weakRequest responseData] options:kNilOptions error:&err];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"result = %@", result]];
        NSLog(@"err = %@", err);
        
        if (result != nil) {
            SectionManager *sectionManager = [[SectionManager alloc] initWithDb:db];
            BOOL saveResult = [sectionManager saveSelection:result userid:[AppConfigure objectForKey:USERID]];
            if (saveResult) {
                [self getDatas];
                [_table reloadData];
            } else {
                NSLog(@"保存分段失败");
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@分段失败", isAdd ? @"新增" : @"修改"]];
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
    }];
    [request startAsynchronous];
}

#pragma mark -
- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

- (void)viewDidAppear:(BOOL)animated {
    [db open];
    
    if (!isFirst) {
        NSLog(@"is not first, refresh datas");
        [self getDatas];
        [_table reloadData];
    } else {
        isFirst = NO;
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [db close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
