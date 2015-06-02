//
//  ProjsViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ProjsViewController.h"
#import "ProjectCell.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "AppConfigure.h"
#import "SingleProjectManager.h"
#import "MajorManager.h"
#import "DeptManager.h"
#import "TemplateManager.h"
#import "SectionManager.h"
#import "CooperateManager.h"
#import "CheckManager.h"
#import "ProblemManager.h"
#import "ValidateViewController.h"
#import "BaseFunction.h"
#import "TableInfoViewController.h"
#import "SectionViewController.h"
#import "MajorProjectListView.h"
#import "LogUtils.h"
#import "GTMNSString+URLArguments.h"
#import "FMDatabaseQueue.h"
#import "PhotoManager.h"

// 动画执行的时间
#define kDuration 0.5
#define TAG @"_ProjsViewController"

@interface ProjsViewController () <ProjectSelectDelegate> {
    // 保存当前的专业ID
    NSString *_majorID;
    // 保存当前的大项ID
    NSString *_deptID;
    // 保存当前的专业名
    NSString *_majorName;
    // 保存当前的大项名
    NSString *_deptName;
    // 保存当前列表一共有多少条数据，包含未显示的数据
    int siteNum;
    // 保存增量刷新增加的数据
    NSArray *incremntDatas;
    // 标记当前专业和大项列表是否已显示
    BOOL listIsShow;
    // 弹出的专业和大项列表的根View
    UIView *popView;
    NSMutableDictionary *majorAndProjectDic;
    NSMutableArray *sortedList;
    // 保存搜索结果
    NSMutableArray *filteredProjectArray;
    // 保存最后一次选择的排序类型
    NSString *lastSelectedSortType;
    NSInteger lastSelectedSortTypeInt;
    // 保存工程列表当前的排序类型，在结束搜索的时候进行判断，是否重新将工程列表进行排序分组
    NSString *currentSortType;
    // 列表Section数组
    NSMutableArray *sectionArray;
    // 保存排好序的列表数据，按照排序类型分组
    NSMutableDictionary *searchGroupedData;
    // 短时间格式的NSDateFormatter
    NSDateFormatter *dateFormatterShort;
    // 长时间格式的NSDateFormatter
    NSDateFormatter *dateFormatterLong;
    NSCalendar *calendar;
    float tableHeight;
    // 判断是否第一次加载
    BOOL isFirst;
    BaseAjaxHttpRequest *request;
    
    FMDatabase *db;
}

@property (nonatomic, strong) GroupMenu *groupMenu;

@end

@implementation ProjsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    db = [BaseFunction createDB];
    [db open];
    
    // 初始化导航栏三个按钮
    UIImage *listImage = [UIImage imageNamed:@"icon_select.png"];
    UIImage *searchImage = [UIImage imageNamed:@"icon_search.png"];
    UIImage *locationImage = [UIImage imageNamed:@"icon_location.png"];
    UIImage *groupSortImage = [UIImage imageNamed:@"icon_group_sort1.png"];
    // 设置导航栏按钮的点击执行方法等
    UIBarButtonItem *projectListItem = [[UIBarButtonItem alloc] initWithImage:listImage style:UIBarButtonItemStylePlain target:self action:@selector(showProjectList)];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(searchProject)];
    UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithImage:locationImage style:UIBarButtonItemStylePlain target:self action:@selector(location)];
    UIBarButtonItem *groupSortItem = [[UIBarButtonItem alloc] initWithImage:groupSortImage style:UIBarButtonItemStylePlain target:self action:@selector(showGroupManu:forEvent:)];
    // 设置按钮的颜色
    projectListItem.tintColor = [UIColor whiteColor];
    searchItem.tintColor = [UIColor whiteColor];
    locationItem.tintColor = [UIColor whiteColor];
    groupSortItem.tintColor = [UIColor whiteColor];
    
    NSArray *actionButtonItems = @[locationItem, searchItem, projectListItem, groupSortItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    /* 初始化数据 */
    data = [NSMutableArray array];
    groupedData = [NSMutableDictionary dictionary];
    searchGroupedData = [NSMutableDictionary dictionary];
    _table.delegate = self;
    _table.dataSource = self;
    // 不显示没内容的Cell
    _table.tableFooterView = [[UIView alloc] init];
    // 设置搜索出来的列表项高度和工程列表的列表项高度相同
    self.searchDisplayController.searchResultsTableView.rowHeight = _table.rowHeight;
    // 点击状态栏回到顶部
    _table.scrollsToTop = YES;
    isFirst = YES;
    isInitLoading = YES;
    
    // 默认排序为时间
    lastSelectedSortType = @"时间";
    // 默认当前排序为时间
    currentSortType = @"时间";
    sectionArray = [NSMutableArray array];
    dateFormatterShort = [[NSDateFormatter alloc] init];
    dateFormatterLong = [[NSDateFormatter alloc] init];
    [dateFormatterShort setDateFormat:@"yyyy-MM-dd"];
    [dateFormatterShort setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatterLong setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatterLong setTimeZone:[NSTimeZone localTimeZone]];
    calendar = [NSCalendar currentCalendar];
    // 设置一周的开始日为周一
    calendar.firstWeekday = 2;
    
    UIView *targetView = (UIView *)[self.navigationItem.rightBarButtonItems[3] performSelector:@selector(view)];
    CGRect rect = targetView.frame;
    NSLog(@"targetView = %@", NSStringFromCGRect(rect));
    _groupMenu = [[GroupMenu alloc] initWithBtnFrame:rect];
    _groupMenu.delegate = self;
    
    //添加下拉view
    if (refreshHeaderView == nil) {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _table.bounds.size.height, _table.frame.size.width, _table.bounds.size.height)];
        refreshHeaderView.delegate = self;
        [_table addSubview:refreshHeaderView];
    }
    [refreshHeaderView refreshLastUpdatedDate];
    [self initEmptyViewWithFrame:CGRectMake(0, 0, _table.frame.size.width, _table.frame.size.height)];
    
    // 获取数据，并且判断是否已经定位
    [self loadDatasWithShowAlert:YES];
}

#pragma mark 下拉刷新回调的委托方法
- (void)reqData {
    // 如果当前正在进行网络请求，就先结束
    if ([request isExecuting]) {
        [request clearDelegatesAndCancel];
    }
    
    [self updateDatas];
}

#pragma mark 下拉刷新列表数据
- (void)updateDatas {
    // 初始化URL
    NSURL *url = [NSURL URLWithString:LATER_RECEIVE];
    request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    // 获取数据库中的TimeStamp
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    NSString *timeStamp = [singleProjectManager getLatestUpdateDate:[AppConfigure objectForKey:USERID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"USERNAME = %@", [AppConfigure objectForKey:LOGIN_NAME]]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"timeStamp = %@", timeStamp]];
    // 设置请求参数
    NSDictionary *params = @{@"USERNAME":[AppConfigure objectForKey:LOGIN_NAME], @"UPDATE_TIMESTAMP":timeStamp};
    [request setPostBody:params];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(_table) weakTable = _table;
    
    [request setCompletionBlock:^{
        NSError *err;
        NSString *responseString = [weakRequest responseString];
        // 如果返回结果是登录超时，则显示登录超时的对话框
        if ([responseString myContainsString:SESSION_TIMEOUT]) {
            NSLog(@"projs %@",@"session time out");
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"responseString = %@", responseString]];
            [weakSelf sessionTimeout];
            // 刷新列表数据
            [weakSelf getMajorData];
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
            //[LogUtils Log:TAG content:[NSString stringWithFormat:@"dic = %@", dic]];
            
            if (dic != nil) {
                //数据库更新
                FMDatabaseQueue *queue = [BaseFunction createDBQueue];
                [queue inTransaction:^(FMDatabase *db1, BOOL *rollback) {
                    [db1 setShouldCacheStatements:YES];
                    for(NSString *keys in dic) {
                        if([keys myContainsString:@"List"]) {
                            id<IGsonDataSaver> dbManager = [weakSelf getDataManager:keys];
                            ClientDBManager *manager = (ClientDBManager *) dbManager;
                            [manager sharedDatabase:db1];
                            NSString *userid = [AppConfigure objectForKey:USERID];
                            NSArray *array = [dic objectForKey:keys];
                            if(array.count == 0) {
                                continue;
                            }
                            for(NSInteger i = 0;i < array.count;i++) {
                                NSDictionary *oneRecord = [array objectAtIndex:i];
                                NSLog(@"insert one record");
                                if([dbManager insertOneRecord:oneRecord userid:userid]) {
                                    [LogUtils Log:TAG content:@"insert suceess"];
                                } else {
                                    *rollback = YES;
                                    return;
                                }
                            }
                        }
                    }
                }];
                [queue close];
                // 获取
                NSString *neednext = [dic objectForKey:NEED_NEXT];
                if(IsStringNotEmpty(neednext) && ![@"false" isEqualToString:neednext] && ![@"(null)" isEqualToString:neednext]) {
                    [LogUtils Log:TAG content:@"需要下次请求"];
                    //继续迭代请求
                    [weakSelf updateDatas];
                }
                if(weakSelf.navigationController.tabBarController.selectedIndex == 1) {
                    // 刷新列表数据
                    [weakSelf getMajorData];
                }
                
            } else {
                [SVProgressHUD showErrorWithStatus:@"获取数据失败"];
                [weakSelf doneLoadingTableView:weakTable height:UI_SCREEN_HEIGHT - 64];
            }
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
        [weakSelf doneLoadingTableView:weakTable height:UI_SCREEN_HEIGHT - 64];
    }];
    [request startAsynchronous];
}

/**
 *  获取插入数据库的操作类
 *
 *  @param name List名
 *
 *  @return 数据库操作类
 */
- (id<IGsonDataSaver>) getDataManager : (NSString *) name {
    id<IGsonDataSaver> dbManager;
    if([name isEqualToString:@"singleList"]) {
        dbManager = [[SingleProjectManager alloc] init];
    } else if([name isEqualToString:@"deptList"]) {
        dbManager = [[DeptManager alloc] init];
    } else if([name isEqualToString:@"selectionList"]) {
        dbManager = [[SectionManager alloc] init];
    } else if([name isEqualToString:@"excludeTemplateList"]) {
        dbManager = [[TemplateManager alloc] init];
    } else if([name isEqualToString:@"checkProjectList"]) {
        dbManager = [[CheckManager alloc] init];
    } else if([name isEqualToString:@"problemList"] || [name isEqualToString:@"problemDelayList"]|| [name isEqualToString:@"relativeOrgList"]) {
        dbManager = [[ProblemManager alloc] init];
    } else if([name isEqualToString:@"cooperateList"]) {
        dbManager = [[CooperateManager alloc] init];
    } else if([name isEqualToString:@"photoList"]) {
        dbManager = [[PhotoManager alloc] init];
    }  else {
        return nil;
    }
    return dbManager;
}

#pragma mark 加载数据，是否判断定位超时显示对话框
-(void) loadDatasWithShowAlert:(BOOL)isShowAlert {
    if(isInitLoading) {
        [self.view addSubview:emptyView];
        [emptyView showLoading];
    }
    
    [self getMajorData];
    
    if (isShowAlert) {
        [self showLocationVerifyAlertView];
    }
}

#pragma mark 判断是否本地已经保存最近一次选择的专业和大项
- (void)getMajorData {
    NSLog(@"getMajorData");
    DeptManager *deptManager = [[DeptManager alloc] initWithDb:db];
    NSArray *deptList = [deptManager getDeptProjectList:[AppConfigure objectForKey:USERID]];
    Global((^{
        if (IsStringEmpty([AppConfigure objectForKey:CHOOSE_MAJOR_ID])) {// 最近一次没有选择的专业和大项
            // 获取专业Array
            NSArray *majorList = [[[MajorManager alloc] init] getMajorList:[AppConfigure objectForKey:MAJOR_LIST]];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"majorList = %@", majorList]];
            
            if (majorList == nil || majorList.count == 0) {
                return;
            }
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"userid = %@", [AppConfigure objectForKey:USERID]]];
            // 获取大项List
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"majorList = %@", majorList]];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"deptList = %@", deptList]];
            if (deptList == nil || deptList.count == 0) {
                return;
            }
            // 取得第一个专业和其下第一个大项的名称
            _majorName = [[majorList objectAtIndex:0] objectForKey:BO_DICT_NAME];
            _deptName = [[deptList objectAtIndex:0] objectForKey:KEYNAME];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"_majorName = %@, _deptName = %@", _majorName, _deptName]];
            // 保存名称
            [AppConfigure setObject:_majorName ForKey:CHOOSE_MAJOR_NAME];
            [AppConfigure setObject:_deptName ForKey:CHOOSE_DEPT_PROJECT_NAME];
            // 专业ID
            _majorID = [[majorList objectAtIndex:0] objectForKey:BO_DICT_VAL];
            // 大项ID
            _deptID = [[deptList objectAtIndex:0] objectForKey:KEYID];
            // 保存ID
            [AppConfigure setObject:_majorID ForKey:CHOOSE_MAJOR_ID];
            [AppConfigure setObject:_deptID ForKey:CHOOSE_DEPT_PROJECT_ID];
//            NSLog(@"最近一次没有选择的专业和大项, _majorName = %@, _deptName = %@, _majorID = %@, _deptID = %@", _majorName, _deptName, _majorID, _deptID);
        } else {// 最近一次有选择的专业和大项
            _majorID = [AppConfigure objectForKey:CHOOSE_MAJOR_ID];
            _deptID = [AppConfigure objectForKey:CHOOSE_DEPT_PROJECT_ID];
            _majorName = [AppConfigure objectForKey:CHOOSE_MAJOR_NAME];
            _deptName = [AppConfigure objectForKey:CHOOSE_DEPT_PROJECT_NAME];
//            NSLog(@"最近一次有选择的专业和大项, _majorName = %@, _deptName = %@, _majorID = %@, _deptID = %@", _majorName, _deptName, _majorID, _deptID);
        }
        
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"CHOOSE_MAJOR_ID = %@", CHOOSE_MAJOR_ID]];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"CHOOSE_DEPT_PROJECT_ID = %@", CHOOSE_DEPT_PROJECT_ID]];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"CHOOSE_MAJOR_NAME = %@", CHOOSE_MAJOR_NAME]];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"CHOOSE_DEPT_PROJECT_NAME = %@", CHOOSE_DEPT_PROJECT_NAME]];

        Main((^{
            // 非增量获取数据
            [self searchDatasIsIncrement:NO];
            // 获取最近一次定位的时间
            NSString *GPS_DATE_CURRENT_USERID = [NSString stringWithFormat:@"%@_%@", GPS_DATE, [AppConfigure objectForKey:USERID]];
            NSString *lastLocation = [AppConfigure objectForKey:GPS_DATE_CURRENT_USERID];
            // 设置列表上方的信息
            if (IsStringEmpty(lastLocation)) {
                _currentDept.text = [NSString stringWithFormat:@"当前专业和大项：%@ - %@", _majorName, _deptName];
            } else {
                _currentDept.text = [NSString stringWithFormat:@"当前专业和大项：%@ - %@\n最新定位时间：%@", _majorName, _deptName, lastLocation];
            }
            
            // 数据不为空
            if (data != nil && data.count != 0) {
                // 分组排序数据
                groupedData = [self dataSortAndGroupWithData:data sortType:currentSortType];
                // 如果还有未显示的数据，且refreshFooterView为空，则添加上拉刷新FooterView，一次默认增加50条数据
                if (siteNum > data.count) {
                    if (refreshFooterView == nil) {
                        refreshFooterView = [[EGORefreshTableFooterView alloc] init];
                        refreshFooterView.delegate = self;
                        [_table addSubview:refreshFooterView];
                        [LogUtils Log:TAG content:@"refreshFooterView is nil, add refreshFooterView"];
                    }
                } else {
                    // 如果没有未显示的数据，则去掉上拉刷新FooterView
                    if (refreshFooterView != nil) {
                        // 去掉上拉view
                        [refreshFooterView removeFromSuperview];
                        refreshFooterView = nil;
                        [LogUtils Log:TAG content:@"remove refreshFooterView"];
                    }
                }
            } else {
                [SVProgressHUD showErrorWithStatus:@"数据加载失败！"];
            }
            isInitLoading = NO;
            [emptyView dismiss];
            [self doneLoadingTableView:_table height:UI_SCREEN_HEIGHT - 64];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"groupedData = %@", groupedData]];
            // 重新加载数据
            [_table reloadData];
        }));
    }));
}

#pragma mark 从数据库中获取工程数据列表，是否需要增量获取
- (void)searchDatasIsIncrement:(BOOL)isIncrement {
    // 获取经纬度
    float longitude = ((NSNumber *) ([AppConfigure objectForKey:LONGITUDE])).floatValue;
    float latitude = ((NSNumber *) ([AppConfigure objectForKey:LATITUDE])).floatValue;
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"LONGITUDE = %@", [AppConfigure objectForKey:LONGITUDE]]];
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"LATITUDE = %@", [AppConfigure objectForKey:LATITUDE]]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"longitude = %f, latitude = %f", longitude, latitude]];
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    if (isIncrement) {// 增量查询，默认增量50条
        // 获取当前已经显示了多少条数据，然后从这个下标开始往后查询50条数据
        int offSet = (int) data.count;
        incremntDatas = [singleProjectManager searchSitesIncrement:_majorID deptProjectId:_deptID keyinfo:@"" longtitude:longitude latitude:latitude offSetNum:offSet endNum:DEFAULT_INCREMENT_NUM userid:[AppConfigure objectForKey:USERID]];
    } else {// 默认查询前20条数据
//        NSLog(@"searchDatasIsIncrement, _majorName = %@, _deptName = %@, _majorID = %@, _deptID = %@", _majorName, _deptName, _majorID, _deptID);
        data = [singleProjectManager searchSites:_majorID deptProjectId:_deptID keyinfo:@"" longtitude:longitude latitude:latitude endNum:DEFAULT_END_NUM userid:[AppConfigure objectForKey:USERID]];
    }
    // 查询一共有几条数据
    siteNum = [singleProjectManager searchSiteNum:_majorID deptProjectId:_deptID keyinfo:@"" longtitude:longitude latitude:latitude userid:[AppConfigure objectForKey:USERID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"siteNum = %d", siteNum]];
}

#pragma mark 上拉刷新回调的委托方法，增量刷新数据
- (void)egoRefreshTableFooterDidTriggerRefresh:(EGORefreshTableFooterView *)view {
//    NSLog(refreshFooterView == nil ? @"refreshFooterView = nil" : @"refreshFooterView != nil");
    if (refreshFooterView != nil) {
        Global((^{
            // 增量获取数据
            [self searchDatasIsIncrement:YES];
            Main((^{
                // 数据不为空
                if (incremntDatas != nil && incremntDatas.count != 0) {
                    // 更新数据
                    [data addObjectsFromArray:incremntDatas];
                    groupedData = [self dataSortAndGroupWithData:data sortType:currentSortType];
                    // 刷新列表
                    [_table reloadData];
                    
                    // 如果没有未显示的数据，则去掉上拉刷新FooterView
                    if (siteNum <= data.count && refreshFooterView != nil) {
                        // 去掉上拉view
                        [refreshFooterView removeFromSuperview];
                        refreshFooterView = nil;
                        [LogUtils Log:TAG content:@"remove refreshFooterView"];
                    }
                } else {
                    [SVProgressHUD showErrorWithStatus:@"数据加载失败！"];
                }
                [self doneLoadingTableView:_table height:UI_SCREEN_HEIGHT - 64];
            }));
        }));
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *headerArray;
    if (tableView == self.searchDisplayController.searchResultsTableView) {// 搜索列表
        headerArray = [searchGroupedData objectForKey:@"sorted_keys"];
    } else {// 工程列表
        headerArray = [groupedData objectForKey:@"sorted_keys"];
    }
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"numberOfSectionsInTableView = %ld", headerArray.count]];
    return headerArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *headerArray;
    // 按照当前实现的列表获取header array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        headerArray = [searchGroupedData objectForKey:@"sorted_keys"];
    } else {
        headerArray = [groupedData objectForKey:@"sorted_keys"];
    }
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"headerArray = %@", headerArray]];
    NSString *header = [headerArray objectAtIndex:section];
    // 如果header有按照"_"来设置编号
    if ([header myContainsString:@"_"]) {
        // 根据“_”来分割字符串，然后取第二个，不要第一个“编号”
        header = [header componentsSeparatedByString:@"_"][1];
    }
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"numberOfRowsInSection section %ld", section]];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *key = [self getKeyBySection:section withData:searchGroupedData];
        NSArray *projectArray = [searchGroupedData objectForKey:key];
        return projectArray.count;
    } else {
        NSString *key = [self getKeyBySection:section withData:groupedData];
        NSArray *projectArray = [groupedData objectForKey:key];
        return projectArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"cellForRowAtIndexPath section %ld, row %ld", indexPath.section, indexPath.row]];
    int row = (int)indexPath.row;
    // 列表项标识
    static NSString *CustomCellIdentifier = @"ProjectCell";
    static BOOL nibsRegistered = NO;
    // 通过标识来获取列表cell
    ProjectCell *cell = (ProjectCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell == nil) {
        nibsRegistered = NO;
    }
    if (!nibsRegistered) {// 初始化并注册cell
        [LogUtils Log:TAG content:@"cell is nil"];
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([ProjectCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        // 搜索列表也需要注册
        [self.searchDisplayController.searchResultsTableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
        // 重新获取cell
        cell = (ProjectCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    // 不同的列表展示不同的数据
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *key = [self getKeyBySection:indexPath.section withData:searchGroupedData];
        NSArray *projectArray = [searchGroupedData objectForKey:key];
        [cell initViewWithData:[projectArray objectAtIndex:row]];
    } else {
        NSString *key = [self getKeyBySection:indexPath.section withData:groupedData];
        NSArray *projectArray = [groupedData objectForKey:key];
        [cell initViewWithData:[projectArray objectAtIndex:row]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"selected section %ld, row %ld", indexPath.section, indexPath.row]];
    // 保存点击的列表所点击的列表项数据
    NSDictionary *selectedCellData;
    NSInteger row = indexPath.row;
    // 获取当前显示的列表项数据
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *key = [self getKeyBySection:indexPath.section withData:searchGroupedData];
        NSArray *projectArray = [searchGroupedData objectForKey:key];
        selectedCellData = [projectArray objectAtIndex:row];
    } else {
        NSString *key = [self getKeyBySection:indexPath.section withData:groupedData];
        NSArray *projectArray = [groupedData objectForKey:key];
        selectedCellData = [projectArray objectAtIndex:row];
    }
//    NSLog(@"selectedCellData = %@", selectedCellData);
    NSString *projectID = [selectedCellData objectForKey:@"bo_single_project_id"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"projectID = %@", projectID]];
    SectionManager *sectionManager = [[SectionManager alloc] initWithDb:db];
    // 判断工程是否有分段存在
    BOOL hasSection = [sectionManager getHasSelectionByProjectId:projectID userid:[AppConfigure objectForKey:USERID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"hasSection = %@", hasSection ? @"YES" : @"NO"]];
    //如果chooseFlag是1，那么结束并发送项目ID的委托
    if(_chooseFlag!=nil&&[@"1" isEqualToString:_chooseFlag]){
        [self.projectDelegate getProjectId:projectID];
        [self back:nil];
        return;
    }
    // 修改点击的工程的时间日期
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    BOOL modifyResult = [singleProjectManager modifyEnterDate:projectID];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"modifyResult = %@", modifyResult ? @"YES" : @"NO"]];
    
    // 有分段存在，跳转到分段界面
    //type: 界面标识（用于判断是从工程列表进入（1），还是待办任务列表进入（2））
    if (hasSection) {
        SectionViewController *sectionViewController = [[SectionViewController alloc] initWithNibName:@"SectionViewController" bundle:nil];
        // 传入数据
        sectionViewController.projectDict = selectedCellData;
        sectionViewController.projectID = [selectedCellData objectForKey:@"bo_single_project_id"];
        sectionViewController.type = @"1";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sectionViewController];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    } else {// 没有分段存在，则跳转到关键控制点界面
        TableInfoViewController *tableInfoViewController = [[TableInfoViewController alloc] initWithNibName:@"TableInfoViewController" bundle:nil];
        // 传入数据
        tableInfoViewController.projectDict = selectedCellData;
        tableInfoViewController.projectID = [selectedCellData objectForKey:@"bo_single_project_id"];
        tableInfoViewController.type = @"1";
        tableInfoViewController.sectionID = @"null";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableInfoViewController];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 获取当前行的cell
    ProjectCell *cell = (ProjectCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    // 计算cell.projectName的文字大小
    CGSize labelSize = [cell.projectName.text sizeWithAttributes:@{NSFontAttributeName:cell.projectName.font}];
    // 工程名label，大小适应文字内容
    [cell.projectName sizeToFit];
    // 计算cell.projectName的文字在当前手机屏幕的宽度减去左右间隔之后有几行
    float lines = labelSize.width / (UI_SCREEN_WIDTH - 16);
    // 转成整数，用来计算是否有非零的小数位
    int l = (int) lines;
    int lines_final = 0;
    // 如果有非零的小数位，说明超过l行，应该加1
    if (lines - l > 0) {
        lines_final = lines + 1;
    } else {
        lines_final = l;
    }
    // 动态计算cell的高度
    float part1 = 13 + lines_final * labelSize.height + (lines - 1) * 3;
    float part2 = 4 + cell.projetNO.frame.size.height;
    float part3 = 4 + cell.projectTakePhotos.frame.size.height;
    float part4 = 10;
    float height = part1 + part2 + part3 + part4;
    NSLog(@"ProjectCell的高度是%f",height);
    return 1  + height;
}

// 列表项高度估算方法，为了提高效率，未显示的cell不用调用cellForRowAtIndexPath，直接返回一个估计的高度
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0f;
}

#pragma mark 点击标题栏分组按钮
- (void)showGroupManu:(id)sender forEvent:(UIEvent*)event {
    NSLog(@"showGroupManu");
    if ([_groupMenu isShow]) {
        [_groupMenu disMissView];
    } else {
        [_groupMenu showMenuInSuperView:self.view];
    }
}

#pragma mark 点击标题栏列表按钮
- (void)showProjectList {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"listIsShow = %@", listIsShow ? @"YES" : @"NO"]];
    if (!listIsShow) {
        if (popView == nil) {// popView为空则为第一次显示，不为空则直接显示
            NSLog(@"popView = nil");
            // 获取数据
            NSArray *majorList = [[[MajorManager alloc] init] getMajorList:[AppConfigure objectForKey:MAJOR_LIST]];
            //    NSLog(@"majorList = %@", majorList);
            
            DeptManager *deptManager = [[DeptManager alloc] initWithDb:db];
            NSMutableArray *projectList = [deptManager getDeptProjectList:[AppConfigure objectForKey:USERID]];
            //    NSLog(@"projectList = %@", projectList);
            majorAndProjectDic = [NSMutableDictionary dictionary];
            // 默认列表项不展开，改为“YES”则为默认展开
            NSMutableString *opened = [NSMutableString stringWithString:@"YES"];
            // 设置majorAndProjectDic内容
            for (NSDictionary *major in majorList) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:major forKey:@"major_dictionary"];
                [dict setObject:opened forKey:@"isOpened"];
                [dict setObject:[NSMutableArray array] forKey:@"project_list"];
                NSString *key = [major objectForKey:@"BO_DICT_VAL"];
                [majorAndProjectDic setObject:dict forKey:key];
            }
            
            for (NSDictionary *project in projectList) {
                NSString *parentId = [project objectForKey:@"parentid"];
                NSMutableArray *projectArray = [[majorAndProjectDic objectForKey:parentId] objectForKey:@"project_list"];
                [projectArray addObject:project];
            }
            // 设置popView初始位置
            popView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
            popView.backgroundColor = [UIColor darkGrayColor];
            // 排序
            NSMutableArray *sortedKeys = [NSMutableArray arrayWithArray:[[majorAndProjectDic allKeys] sortedArrayUsingSelector: @selector(compare:)]];
//            [LogUtils Log:TAG content:[NSString stringWithFormat:@"sortedKeys = %@", sortedKeys]];
            sortedList = [NSMutableArray array];
            for (NSString *key in sortedKeys) {
                [sortedList addObject:[majorAndProjectDic objectForKey:key]];
            }
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"before check sortedList = %@, sortedList.count = %ld", sortedList, sortedList.count]];
            MajorProjectListView *majorProjectListView = [[MajorProjectListView alloc] initWithFrame:CGRectMake(0, 0, popView.frame.size.width, popView.frame.size.height)];
            // 过滤掉没有大项的专业
            NSMutableArray *removeObjs = [[NSMutableArray alloc] init];
            for (NSDictionary *projectDict in sortedList) {
                NSArray *projectList = [projectDict objectForKey:@"project_list"];
                if (projectList.count == 0) {
                    [removeObjs addObject:projectDict];
                }
            }
            for (int i = 0; i < removeObjs.count; i++) {
                [sortedList removeObject:removeObjs[i]];
            }
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"after check sortedList = %@, sortedList.count = %ld", sortedList, sortedList.count]];
            [majorProjectListView setDatas:sortedList];
            majorProjectListView.delegate = self;
            [popView addSubview:majorProjectListView];
            
            [self.view addSubview:popView];
        }
        // 将popView“拉到”界面最前面
        [self.view bringSubviewToFront:popView];
        // 列表动画
        [UIView animateWithDuration:kDuration animations:^{
            popView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            listIsShow = YES;
        }];
    } else {// 隐藏列表view
        [UIView animateWithDuration:kDuration animations:^{
            popView.frame = CGRectMake(0, -self.view.frame.size.height - 20, self.view.frame.size.width, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            listIsShow = NO;
        }];
    }
}

#pragma mark 点击标题栏搜索按钮
- (void)searchProject {
    _currentMajorView.hidden = YES;
    [_searchBar.superview bringSubviewToFront:_searchBar];
    [UIView animateWithDuration:kDuration animations:^{
        // 如果下拉展示的列表正在显示，则先隐藏
        if (listIsShow) {
            [self showProjectList];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            // 然后展示搜索view
            [self.searchBar becomeFirstResponder];
        }
    }];
}

#pragma mark 点击标题栏定位按钮
- (void)location {
    [UIView animateWithDuration:kDuration animations:^{
        // 如果下拉展示的列表正在显示，则先隐藏
        if (listIsShow) {
            [self showProjectList];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            if ([self getLocationTimeIntervalSinceCurrentDateIsTimeOut]) {
                [self jumpToLocation];
            } else {// 如果已经定位并且没有超过24小时，则提示用户
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"位置校验" message:@"您已经进行了GPS验证，进入将覆盖之前的验证记录。" delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"重新验证", nil];
                [alertView show];
            }
        }
    }];
}

// 跳转到签到界面
- (void)jumpToLocation {
    UIViewController *validateViewController = [[ValidateViewController alloc] initWithNibName:@"ValidateViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:validateViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark 判断时间差，是否显示位置校验提示框
- (void) showLocationVerifyAlertView {
    if ([self getLocationTimeIntervalSinceCurrentDateIsTimeOut]) {
        UIAlertView *verifyAlert = [[UIAlertView alloc] initWithTitle:@"位置校验" message:@"按照规范，进行巡检前要完成位置和身份验证。" delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"现在验证", nil];
        [verifyAlert show];
    }
}

/**
 *  判断最近一次定位是否不在有效时间区间内（时间区间：24小时）
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
 *  @return 是否超过24小时
 */
- (BOOL)isTimeOut:(double)timeDifference {
    return timeDifference > 86400;
}

#pragma mark - update alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex = %ld", buttonIndex);
    NSLog(@"alertView.tag = %ld", alertView.tag);
    if (alertView.tag == BASE_ALERT_TAG) {// 登录超时对话框
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    } else if(buttonIndex == 1) {
        // 打开签到界面
        [self jumpToLocation];
    }
}

#pragma mark 专业和大项列表选择回调的委托方法
- (void)projectSelectAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *majorDic = [[sortedList objectAtIndex:indexPath.section] objectForKey:@"major_dictionary"];
    NSDictionary *projectDic = [[[sortedList objectAtIndex:indexPath.section] objectForKey:@"project_list"] objectAtIndex:indexPath.row];
    // 取得第一个专业和其下第一个大项的名称
    _majorName = [majorDic objectForKey:BO_DICT_NAME];
    _deptName = [projectDic objectForKey:KEYNAME];
    // 保存名称
    [AppConfigure setObject:_majorName ForKey:CHOOSE_MAJOR_NAME];
    [AppConfigure setObject:_deptName ForKey:CHOOSE_DEPT_PROJECT_NAME];
    // 专业ID
    _majorID = [majorDic objectForKey:BO_DICT_VAL];
    // 大项ID
    _deptID = [projectDic objectForKey:KEYID];
    // 保存ID
    [AppConfigure setObject:_majorID ForKey:CHOOSE_MAJOR_ID];
    [AppConfigure setObject:_deptID ForKey:CHOOSE_DEPT_PROJECT_ID];
    // 隐藏列表
    [self showProjectList];
    // 列表不为空则滚动到顶部
    if (groupedData != nil && [groupedData objectForKey:@"sorted_keys"] != nil) {
        // 滚动到table得顶部
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
//    NSLog(@"_majorName = %@, _deptName = %@, _majorID = %@, _deptID = %@", _majorName, _deptName, _majorID, _deptID);
    // 更新工程列表数据
    [self loadDatasWithShowAlert:NO];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Return YES to cause the search result table view to be reloaded.
    // 每次改变搜索内容都按照大项来排序
    [self filterContentForSearchString:searchString searchOption:@"大项"];
    [controller.searchBar setSelectedScopeButtonIndex:2];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    if ([self isLocated] || searchOption != 1) {
        NSString *sortType = [[controller.searchBar scopeButtonTitles] objectAtIndex:searchOption];
        lastSelectedSortType = sortType;
        lastSelectedSortTypeInt = searchOption;
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"lastSelectedSortType = %@, lastSelectedSortTypeInt = %ld", lastSelectedSortType, lastSelectedSortTypeInt]];
        // 将结果进行排序分组
        searchGroupedData = [self dataSortAndGroupWithData:filteredProjectArray sortType:sortType];
        return YES;
    } else {
        [SVProgressHUD showErrorWithStatus:@"当前没有定位，无法按照距离排序"];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"searchOption = %@, search text = %@", [[controller.searchBar scopeButtonTitles] objectAtIndex:searchOption], controller.searchBar.text]];
        return NO;
    }
}

#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    _currentMajorView.hidden = YES;
    [self setIsListeningScrolling:NO];
    
    self.searchDisplayController.searchBar.showsCancelButton = YES;
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    UIView *viewTop = IS_IOS7 ? searchBar.subviews[0] : searchBar;
    NSString *classString = IS_IOS7 ? @"UINavigationButton" : @"UIButton";
    
    for (UIView *subView in viewTop.subviews) {
        if ([subView isKindOfClass:NSClassFromString(classString)]) {
            UIButton *cancelButton = (UIButton*)subView;
            [cancelButton setTitle:@"确定" forState:UIControlStateNormal];
        }
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"Will End Search");
    _currentMajorView.hidden = NO;
    NSInteger searchOption = [controller.searchBar selectedScopeButtonIndex];
//    NSString *sortType = [[controller.searchBar scopeButtonTitles] objectAtIndex:searchOption];
    // 如果工程当前的排序分组类型和退出搜索时选择的排序分组类型一样的话，则不重新加载工程列表
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"currentSortType = %@, lastSelectedSortType = %@", currentSortType, lastSelectedSortType]];
    if (![currentSortType isEqualToString:lastSelectedSortType]) {
        // 退出搜索，刷新工程列表
        if ([self isLocated] || searchOption != 1) {
            if (groupedData != nil) {
                groupedData = [self dataSortAndGroupWithData:data sortType:lastSelectedSortType];
                //加载数据
                [_table reloadData];
                [LogUtils Log:TAG content:@"当前排序分组类型与退出搜索时选择的排序分组类型不一样，重新排序分组"];
                currentSortType = [NSString stringWithString:lastSelectedSortType];
            }
        }
    }
    
    [_searchBar.superview bringSubviewToFront:_currentMajorView];
    [_searchBar.superview bringSubviewToFront:_table];
    [self setIsListeningScrolling:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [LogUtils Log:TAG content:@"Search Button Clicked"];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [LogUtils Log:TAG content:@"Search Canceled"];
}

#pragma mark - 切换分组排序
- (void)selectedBtnAtIndex:(NSInteger)index withBtnTitle:(NSString *)btnTitle {
    [self changeGroupType:btnTitle];
}

- (void)changeGroupType:(NSString *)groupType {
    if ([self isLocated] || ![@"距离" isEqualToString:groupType]) {
        if (groupedData != nil) {
            groupedData = [self dataSortAndGroupWithData:data sortType:groupType];
            //加载数据
            [_table reloadData];
            currentSortType = [NSString stringWithString:groupType];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"当前没有定位，无法按照距离排序"];
    }
}

#pragma mark -
#pragma mark Content Filtering
-(void)filterContentForSearchString:(NSString*)searchString searchOption:(NSString*)searchOption {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"searchString = %@, searchOption = %@", searchString, searchOption]];
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [filteredProjectArray removeAllObjects];
    float longitude = ((NSNumber *) ([AppConfigure objectForKey:LONGITUDE])).floatValue;
    float latitude = ((NSNumber *) ([AppConfigure objectForKey:LATITUDE])).floatValue;
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    // 获得搜索的结果
    filteredProjectArray = [singleProjectManager searchSites:_majorID deptProjectId:_deptID keyinfo:searchString longtitude:longitude latitude:latitude endNum:DEFAULT_END_NUM userid:[AppConfigure objectForKey:USERID]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"filteredProjectArray.count = %lu", filteredProjectArray.count]];
//    NSLog(@"filteredProjectArray = %@", filteredProjectArray);
    // 将结果进行排序分组
    searchGroupedData = [self dataSortAndGroupWithData:filteredProjectArray sortType:searchOption];
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"searchGroupedData = %@", searchGroupedData]];
}

/**
 *  判断是否已经定位
 *
 *  @return 是否已经定位过
 */
- (BOOL)isLocated {
    // 获取最近一次定位的时间
    NSString *GPS_DATE_CURRENT_USERID = [NSString stringWithFormat:@"%@_%@", GPS_DATE, [AppConfigure objectForKey:USERID]];
    NSString *lastLocation = [AppConfigure objectForKey:GPS_DATE_CURRENT_USERID];
    
    return IsStringNotEmpty(lastLocation);
}

#pragma mark - 列表数据排序分组
#pragma mark 按照排序类型排序分组
- (NSMutableDictionary *)dataSortAndGroupWithData:(NSMutableArray *)pData sortType:(NSString *)sortType {
    NSMutableDictionary *sortedAndGroupedDic = [NSMutableDictionary dictionary];
    if ([@"时间" isEqualToString:sortType]) {
        NSLog(@"时间分组");
        sortedAndGroupedDic = [self dataSortAndGroupByDateWithData:pData];
    } else if ([@"距离" isEqualToString:sortType]) {
        NSLog(@"距离分组");
        sortedAndGroupedDic = [self dataSortAndGroupByDistanceWithData:pData];
    } else if ([@"大项" isEqualToString:sortType]) {
        NSLog(@"大项分组");
        sortedAndGroupedDic = [self dataSortAndGroupByDeptProjectWithData:pData];
    }
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"sortedAndGroupedDic = %@", sortedAndGroupedDic]];
    return sortedAndGroupedDic;
}

#pragma mark 按照时间排序分组
- (NSMutableDictionary *)dataSortAndGroupByDateWithData:(NSMutableArray *)pData {
    // 保存排序分组之后的结果
    NSMutableDictionary *resultDataDic = [NSMutableDictionary dictionary];
    //    [headerDictionary removeAllObjects];
    // 保存pData的临时数据
    NSMutableArray *tempDataArray = [NSMutableArray arrayWithArray:pData];
    // 保存排序好的分组名和对应列表key
    NSMutableDictionary *headerDictionary = [NSMutableDictionary dictionary];
    // 默认从1开始，0用来判断是否已经存在
    int index = 1;
    // headerDictionary保存的key，随着时间的区间来改变
    NSString *headerKey = @"";
    // 初始化时间，用来进行比较
    NSDate *today = [self getTodayStartTime];
    NSDate *yesterday = [today dateByAddingTimeInterval:-86400];
    NSDate *currentWeekMonday = [self getCurrentWeekStartTime];
    NSDate *lastWeekMonday = [self getLastWeekStartTimeWithCurrentWeekStartTime:currentWeekMonday];
    NSDate *currentMonthFirstDay = [self getCurrentMonthFirstDay];
    NSDate *lastMonthFirstDay = [self getLastMonthFirstDay];
    
    // 循环遍历临时数据，分组排序数据
    for (NSMutableDictionary *deptProject in tempDataArray) {
        // 先获取这个Project的时间
        NSString *projectEnterDate = [deptProject objectForKey:@"enter_date"];
        NSDate *enterDate = [self getDateFromString:projectEnterDate];
//        NSLog(@"projectEnterDate = %@, enterDate = %@", projectEnterDate, enterDate);
        
        // 比较时间，设置headerKey，前面加编号是为了容易排序
        if ([self isDate1LaterThanDate2:enterDate date2:today]) {
            headerKey = @"1_今天";
        } else if ([self isDate1LaterThanDate2:enterDate date2:yesterday]) {
            headerKey = @"2_昨天";
        } else if ([self isDate1LaterThanDate2:enterDate date2:currentWeekMonday]) {
            headerKey = @"3_本周";
        } else if ([self isDate1LaterThanDate2:enterDate date2:lastWeekMonday]) {
            headerKey = @"4_上周";
        } else if ([self isDate1LaterThanDate2:enterDate date2:currentMonthFirstDay]) {
            headerKey = @"5_本月";
        } else if ([self isDate1LaterThanDate2:enterDate date2:lastMonthFirstDay]) {
            headerKey = @"6_上月";
        } else {
            headerKey = @"7_更早";
        }
        // 获取headerKey对应的headerValue
        int headerValue = [[headerDictionary objectForKey:headerKey] intValue];
        // 如果headerValue为0，则说明headerkey不存在于headerDictionary中，则添加
        if (headerValue == 0) {
            [headerDictionary setObject:[NSString stringWithFormat:@"%d", index] forKey:headerKey];
            headerValue = index++;
        }
        NSString *deptArrayKey = [NSString stringWithFormat:@"%d", headerValue];
        NSMutableArray *deptArray = [resultDataDic objectForKey:deptArrayKey];
        // 判断列表是否为空，为空说明不存在，则初始化deptArray，并添加到resultDataDic中
        if (deptArray == nil) {
            deptArray = [NSMutableArray array];
            [resultDataDic setObject:deptArray forKey:deptArrayKey];
        }
        // 将deptProject添加到对应的列表中
        [[resultDataDic objectForKey:deptArrayKey] addObject:deptProject];
    }
    // 将resultDataDic中的列表排序
    for (NSString *key in resultDataDic) {
        NSMutableArray *array = [resultDataDic objectForKey:key];
        // 按照时间降序排序
        [array sortUsingComparator:^NSComparisonResult(NSMutableDictionary *obj1, NSMutableDictionary *obj2) {
            return [[obj2 objectForKey:@"enter_date"] compare:[obj1 objectForKey:@"enter_date"]];
        }];
    }
    
    // 将headerDictionary中所有的key排序，并添加到resultDataDic中
    NSMutableArray *sortDistanceListkeys = [NSMutableArray arrayWithArray:[headerDictionary allKeys]];
    [sortDistanceListkeys sortUsingSelector:@selector(compare:)];
    //    [resultDataDic setObject:sortDeptListValues forKey:@"sorted_values"];
    [resultDataDic setObject:sortDistanceListkeys forKey:@"sorted_keys"];
    // 添加headerDictionary，用于在显示列表数据的时候用来获取对应的key
    [resultDataDic setObject:headerDictionary forKey:@"header_dict"];
//        NSLog(@"headerDictionary = %@", headerDictionary);
//        NSLog(@"resultDataDic = %@", resultDataDic);
    
    return resultDataDic;
}

#pragma mark 按照距离排序分组
- (NSMutableDictionary *)dataSortAndGroupByDistanceWithData:(NSMutableArray *)pData {
    // 保存排序分组之后的结果
    NSMutableDictionary *resultDataDic = [NSMutableDictionary dictionary];
    // 保存pData的临时数据
    NSMutableArray *tempDataArray = [NSMutableArray arrayWithArray:pData];
    // 保存排序好的分组名和对应列表key
    NSMutableDictionary *headerDictionary = [NSMutableDictionary dictionary];
    // 默认从1开始，0用来判断是否已经存在
    int index = 1;
    // headerDictionary保存的key，随着distance来改变
    NSString *headerKey = @"";
    // 循环遍历临时数据，分组排序数据
    for (NSDictionary *deptProject in tempDataArray) {
        // 先获取这个Project的距离
        NSString *projectDistance = [deptProject objectForKey:@"PROJECT_DISTANCE"];
        float distance = 0.0;
        // 大于1000米，KM结尾
        if ([projectDistance hasSuffix:@"KM"]) {
            NSString *distanceString = [projectDistance componentsSeparatedByString:@"KM"][0];
            // 获取距离，单位米
            distance = [distanceString floatValue] * 1000;
        } else {// 小于1000米，只有一个M结尾
            NSString *distanceString = [projectDistance componentsSeparatedByString:@"M"][0];
            // 获取距离，单位米
            distance = [distanceString floatValue];
        }
        // 判断距离，设置headerKey，加上前缀“x_”是为了自动排序
        if (distance <= 500) {// 500M以内
            headerKey = @"1_500M以内";
        } else if (distance <= 1000) {// 1公里以内
            headerKey = @"2_1公里以内";
        } else if (distance <= 5000) {// 5公里以内
            headerKey = @"3_5公里以内";
        } else if (distance <= 20000) {// 20公里以内
            headerKey = @"4_20公里以内";
        } else if (distance <= 100000) {// 100公里以内
            headerKey = @"5_100公里以内";
        } else {// 大于100公里
            headerKey = @"6_大于100公里";
        }
        
        int headerValue = [[headerDictionary objectForKey:headerKey] intValue];
        if (headerValue == 0) {
            [headerDictionary setObject:[NSString stringWithFormat:@"%d", index] forKey:headerKey];
            headerValue = index++;
        }
        NSString *deptArrayKey = [NSString stringWithFormat:@"%d", headerValue];
        NSMutableArray *deptArray = [resultDataDic objectForKey:deptArrayKey];
        // 判断列表是否为空，为空说明不存在，则初始化deptArray，并添加到resultDataDic中
        if (deptArray == nil) {
            deptArray = [NSMutableArray array];
            [resultDataDic setObject:deptArray forKey:deptArrayKey];
        }
        // 将deptProject添加到对应的列表中
        [[resultDataDic objectForKey:deptArrayKey] addObject:deptProject];
    }
    
    for (NSString *key in resultDataDic) {
        NSMutableArray *array = [resultDataDic objectForKey:key];
        // 按照距离升序排序
        [array sortUsingComparator:^NSComparisonResult(NSMutableDictionary *obj1, NSMutableDictionary *obj2) {
            return [[obj1 objectForKey:PROJECT_DISTANCE] compare:[obj2 objectForKey:PROJECT_DISTANCE]];
        }];
    }
    
    // 将headerDictionary中所有的key排序，并添加到resultDataDic中
    NSMutableArray *sortDistanceListkeys = [NSMutableArray arrayWithArray:[headerDictionary allKeys]];
    [sortDistanceListkeys sortUsingSelector:@selector(compare:)];
    [resultDataDic setObject:sortDistanceListkeys forKey:@"sorted_keys"];
    // 添加headerDictionary，用于在显示列表数据的时候用来获取对应的key
    [resultDataDic setObject:headerDictionary forKey:@"header_dict"];
//    NSLog(@"headerDictionary = %@", headerDictionary);
//    NSLog(@"resultDataDic = %@", resultDataDic);
    
    return resultDataDic;
}

#pragma mark 按照大项排序分组
- (NSMutableDictionary *)dataSortAndGroupByDeptProjectWithData:(NSMutableArray *)pData {
    // 保存排序分组之后的结果
    NSMutableDictionary *resultDataDic = [NSMutableDictionary dictionary];
//    [headerDictionary removeAllObjects];
    // 保存pData的临时数据
    NSMutableArray *tempDataArray = [NSMutableArray arrayWithArray:pData];
    // 保存排序好的分组名和对应列表key
    NSMutableDictionary *headerDictionary = [NSMutableDictionary dictionary];
    // 默认从1开始，0用来判断是否已经存在
    int index = 1;
    // 循环遍历临时数据，分组排序数据
    for (NSDictionary *deptProject in tempDataArray) {
        // 先获取这个大项的名称
        NSString *deptName = [deptProject objectForKey:@"dept_project_name"];
        // 获取这个大项名称在headerDictionary中对应的value，这个value就是resultDataDic中对应列表的key
        int deptNameIndex = [[headerDictionary objectForKey:deptName] intValue];
        // 判断是否为0，为0说明不存在，则创建
        if (deptNameIndex == 0) {
            [headerDictionary setObject:[NSString stringWithFormat:@"%d", index] forKey:deptName];
            // 创建之后更改deptNameIndex，index自增，避免和其他的deptName对应的value冲突
            deptNameIndex = index++;
        }
        // 按照deptNameIndex获取对应的列表在resultDataDic中的key
        NSString *deptArrayKey = [NSString stringWithFormat:@"%d", deptNameIndex];
        // 按照这个key来获取列表
        NSMutableArray *deptArray = [resultDataDic objectForKey:deptArrayKey];
        // 判断列表是否为空，为空说明不存在，则初始化deptArray，并添加到resultDataDic中
        if (deptArray == nil) {
            deptArray = [NSMutableArray array];
            [resultDataDic setObject:deptArray forKey:deptArrayKey];
        }
        // 将deptProject添加到对应的列表中
        [[resultDataDic objectForKey:deptArrayKey] addObject:deptProject];
    }
    
    // 将headerDictionary中所有的key排序，并添加到resultDataDic中
    NSMutableArray *sortDeptListkeys = [NSMutableArray arrayWithArray:[headerDictionary allKeys]];
    [sortDeptListkeys sortUsingSelector:@selector(compare:)];
    [resultDataDic setObject:sortDeptListkeys forKey:@"sorted_keys"];
    // 添加headerDictionary，用于在显示列表数据的时候用来获取对应的key
    [resultDataDic setObject:headerDictionary forKey:@"header_dict"];
//    NSLog(@"headerDictionary = %@", headerDictionary);
//    NSLog(@"resultDataDic = %@", resultDataDic);
    return resultDataDic;
}

#pragma mark -
#pragma mark 获取分组数据的key
- (NSString *)getKeyBySection:(NSInteger)section withData:(NSMutableDictionary *)gData{
    NSArray *headerArray = [gData objectForKey:@"sorted_keys"];
    NSDictionary *headerDict = [gData objectForKey:@"header_dict"];
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"getKeyBySection headerArray = %@", headerArray]];
    NSString *header;
    if ([headerArray count] < (section + 1)) {
        header = [headerArray objectAtIndex:[headerArray count] - 1];
    } else {
        header = [headerArray objectAtIndex:section];
    }
    
    NSString *key = [headerDict objectForKey:header];
    
    return key;
}

#pragma mark - 获取各分组时间区间函数，需要注意的是，NSDate存储的是GMT的标准时间
#pragma mark 获得当天的开始时间，比如：2012-01-01 00:00:00，但是是时区是伦敦时区
- (NSDate *)getTodayStartTime {
    NSDate *todayStartTime = [dateFormatterShort dateFromString:[self getTodayShortString]];
    todayStartTime = [todayStartTime dateByAddingTimeInterval:8 * 3600];
    return todayStartTime;
}

#pragma mark 获得本周的开始时间
- (NSDate *)getCurrentWeekStartTime {
    NSDate *now = [NSDate date];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                              |NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:now];
    // 得到星期几
    // 1(星期天) 2(星期一) 3(星期二) 4(星期三) 5(星期四) 6(星期五) 7(星期六)
    NSInteger weekDay = [comp weekday];
    // 得到几号
    NSInteger day = [comp day];
    
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff;
    if (weekDay == 1) {
        firstDiff = 1;
    }else{
        firstDiff = [calendar firstWeekday] - weekDay;
    }
    
    NSDateComponents *comp2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [comp2 setDay:day + firstDiff];
    NSDate *currentWeekStartTime= [calendar dateFromComponents:comp2];
    
    currentWeekStartTime = [currentWeekStartTime dateByAddingTimeInterval:8 * 3600];
    
    return currentWeekStartTime;
}

#pragma mark 获得上周的开始时间
- (NSDate *)getLastWeekStartTimeWithCurrentWeekStartTime:(NSDate *)currentWeekStartTime {
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekdayOrdinal|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekOfYear fromDate:currentWeekStartTime];

    comp.day = comp.day -7;
    NSDate *lastWeekStartTime = [calendar dateFromComponents:comp];
    lastWeekStartTime = [lastWeekStartTime dateByAddingTimeInterval:8 * 3600];
    return lastWeekStartTime;
}

#pragma mark 获得本月的开始时间
- (NSDate *)getCurrentMonthFirstDay {
    NSString *currentTime = [self getStringFromDate:[NSDate date]];
    NSRange range = {0, 7};
    NSString *yearAndMonth = [currentTime substringWithRange:range];
    NSString *currentMonthFirstDayString = [NSString stringWithFormat:@"%@-01 00:00:00", yearAndMonth];
    NSDate *currentMonthFirstDay = [dateFormatterLong dateFromString:currentMonthFirstDayString];
    currentMonthFirstDay = [currentMonthFirstDay dateByAddingTimeInterval:8 * 3600];
    return currentMonthFirstDay;
}

#pragma mark 获得上月的开始时间
- (NSDate *)getLastMonthFirstDay {
    NSDateComponents *comps1 = [NSDateComponents new];
    comps1.month = -1;
    NSDate *date = [calendar dateByAddingComponents:comps1 toDate:[NSDate date] options:0];
    NSDateComponents *comps2 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSInteger year = [comps2 year];
    NSInteger month = [comps2 month];
    NSString *lastMonthFirstDayString = [NSString stringWithFormat:@"%lu-%lu-01 00:00:00", year, month];
    NSDate *lastMonthFirstDay = [dateFormatterLong dateFromString:lastMonthFirstDayString];
    lastMonthFirstDay = [lastMonthFirstDay dateByAddingTimeInterval:8 * 3600];
    return lastMonthFirstDay;
}

/**
 *  获取当天时间的短格式字符串
 *
 *  @return 短格式的时间字符串
 */
- (NSString *) getTodayShortString {
    NSDate *currentDate = [NSDate date];
    NSString *currDateString = [dateFormatterShort stringFromDate:currentDate];
    return currDateString;
}

/**
 *  将日期转成长格式的字符串
 *
 *  @param date 要转换的时间
 *
 *  @return 转化之后的时间字符串
 */
- (NSString *)getStringFromDate:(NSDate *)date {
    NSString *dateString = [dateFormatterLong stringFromDate:date];
    return dateString;
}

/**
 *  将字符串转成长格式的日期类型
 *
 *  @param dateString 要转换的时间字符串
 *
 *  @return 转换之后的时间
 */
- (NSDate *)getDateFromString:(NSString *)dateString {
    NSDate *date = [dateFormatterLong dateFromString:dateString];
    date = [date dateByAddingTimeInterval:8 * 3600];
    return date;
}

/**
 *  判断第一个时间是否比第二个时间要迟
 *
 *  @param date1 要比较的第一个时间
 *  @param date2 要比较的第二个时间
 *
 *  @return 比较结果
 */
- (BOOL)isDate1LaterThanDate2:(NSDate *)date1 date2:(NSDate *)date2 {
    BOOL result = date2 == [date2 earlierDate:date1];
    return result;
    
}

#pragma mark - 重新登录
// 登录成功
- (void)loginSuccess {
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
        [LogUtils Log:TAG content:@"is not first, refresh datas"];
        [self reqData];
    } else {
        isFirst = NO;
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [db close];
    if ([request isExecuting]) {
       [request clearDelegatesAndCancel];
    }
    
    // 如果下拉展示的列表正在显示，则先隐藏
    if (listIsShow) {
        [self showProjectList];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

@end
