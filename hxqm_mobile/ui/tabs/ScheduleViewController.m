//
//  ScheduleViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ScheduleProjectCell.h"
#import "ValidateViewController.h"
#import "AppConfigure.h"
#import "MyMacros.h"
#import "BaseFunction.h"
#import "SingleProjectManager.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "GTMNSString+URLArguments.h"
#import "DeptManager.h"
#import "SectionManager.h"
#import "TemplateManager.h"
#import "CheckManager.h"
#import "CooperateManager.h"
#import "ProblemManager.h"
#import "FMDatabaseQueue.h"
#import "TableInfoViewController.h"
#import "LogUtils.h"
#import "PhotoManager.h"

#define TAG @"_ScheduleViewController"

@interface ScheduleViewController () {
    // 保存最近一次定位的时间
    NSString *lastLocationTime;
    NSString *GPS_DATE_CURRENT_USERID;
    // 判断是否第一次加载
    BOOL isFirst;
    BaseAjaxHttpRequest *request;
    
    FMDatabase *db;
}

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    db = [BaseFunction createDB];
    [db open];
    // Do any additional setup after loading the view from its nib.    
    // 初始化导航栏定位按钮
    UIImage *locationImage = [UIImage imageNamed:@"icon_location.png"];
    UIBarButtonItem *locationItem = [[UIBarButtonItem alloc] initWithImage:locationImage style:UIBarButtonItemStylePlain target:self action:@selector(location)];
    locationItem.tintColor = [UIColor whiteColor];
    NSArray *actionButtonItems = @[locationItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    // 判断是否需要添加返回按钮
    if ([@"YES" isEqualToString:_needBack]) {
        // 添加导航栏返回按钮
        [self addNavBackBtn];
    }
    
    // 初始化数据
    taskList = [NSMutableArray array];
    isInitLoading = YES;
    _table.delegate = self;
    _table.dataSource = self;
    // 不显示没内容的Cell
    _table.tableFooterView = [[UIView alloc] init];
    isFirst = YES;
    
    //添加下拉view
    if (refreshHeaderView == nil) {
        refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _table.bounds.size.height, _table.frame.size.width, _table.bounds.size.height)];
        refreshHeaderView.delegate = self;
        [_table addSubview:refreshHeaderView];
    }
    [refreshHeaderView refreshLastUpdatedDate];
    [self initEmptyViewWithFrame:CGRectMake(0, 0, _table.frame.size.width, _table.frame.size.height)];
    
    [self refreshLocation];
    
    //获取数据
    [self loadDatasWithShowAlert:YES];
    [self reqData];
}

#pragma mark 加载数据
-(void) loadDatasWithShowAlert:(BOOL)isShowAlert {
    if(isInitLoading) {
        [self.view addSubview:emptyView];
        [emptyView showLoading];
    }
    
    [self getTaskList];
    
    if (isShowAlert) {
        [self showLocationVerifyAlertView];
    }
}

#pragma mark 从本地数据库中获取任务列表
- (void)getTaskList {
    if(isInitLoading) {
        [self.view addSubview:emptyView];
        [emptyView showLoading];
    }
    
    // 获得任务列表所需输入参数
    float longitude = ((NSNumber *) ([AppConfigure objectForKey:LONGITUDE])).floatValue;
    float latitude = ((NSNumber *) ([AppConfigure objectForKey:LATITUDE])).floatValue;
    SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
    // 获取任务列表
    NSString *taskShowMode = [AppConfigure objectForKey:TASK_SHOW_MODE];
    if([@"3" isEqualToString:taskShowMode]){
        taskList = [singleProjectManager getTaskList:longitude latitude:latitude userid:[AppConfigure objectForKey:USERID] type:taskShowMode];
    }else if([@"4" isEqualToString:taskShowMode]){
        taskList = [singleProjectManager getTaskList:longitude latitude:latitude userid:[AppConfigure objectForKey:USERID] type:taskShowMode];
    }else if(taskShowMode==nil){
        taskList = [singleProjectManager getTaskList:longitude latitude:latitude userid:[AppConfigure objectForKey:USERID] type:@"3"];
        [taskList addObjectsFromArray:[singleProjectManager getTaskList:longitude latitude:latitude userid:[AppConfigure objectForKey:USERID] type:@"4"]];
    }
    //[LogUtils Log:TAG content:[NSString stringWithFormat:@"taskList = %@", taskList]];
    
    isInitLoading = NO;
    [emptyView dismiss];
    // 数据为空说明获取失败
    if (taskList == nil) {
        [SVProgressHUD showErrorWithStatus:@"数据加载失败"];
    } else if (taskList.count == 0) {// 账户没有任务
        [_table reloadData];
        [SVProgressHUD showErrorWithStatus:@"当前账户没有任务"];
    } else {// 数据不为空且有任务
        //加载数据
        [_table reloadData];
    }
    
    [self doneLoadingTableView:_table height:UI_SCREEN_HEIGHT - 64];

}

#pragma mark 判断时间差，是否显示位置校验提示框
- (void) showLocationVerifyAlertView {
    if ([self getLocationTimeIntervalSinceCurrentDateIsTimeOut]) {
        UIAlertView *verifyAlert = [[UIAlertView alloc] initWithTitle:@"位置校验" message:@"按照规范，进行巡检前要完成位置和身份验证。" delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"现在验证", nil];
        [verifyAlert show];
    }
}

#pragma mark 请求刷新数据
-(void) reqData {
    if ([request isExecuting]) {
        [request clearDelegatesAndCancel];
    }
    
    [self updateDatas];
}

#pragma mark 下拉刷新列表数据
- (void)updateDatas {
    // 设置请求URL
    NSURL *url = [NSURL URLWithString:TASK_LIST];
    request = [BaseAjaxHttpRequest requestWithURL:url];
    __weak BaseAjaxHttpRequest *weakRequest = request;
    // 设置请求参数
    NSDictionary *params = @{@"CHECK_TYPE":@"4,3"};
    [request setPostBody:params];
    
    __weak typeof(self) weakSelf = self;
    
    [request setCompletionBlock:^{
        NSError *err;
        NSString *responseString = [weakRequest responseString];
        // 判断返回值是否为登录超时
        if ([responseString myContainsString:SESSION_TIMEOUT]) {
            NSLog(@"sche %@",@"session time out");
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"responseString = %@", responseString]];
            [weakSelf sessionTimeout];
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
//            [LogUtils Log:TAG content:[NSString stringWithFormat:@"dic = %@", dic]];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"error = %@", err]];
            FMDatabaseQueue *queue = [BaseFunction createDBQueue];
            [queue inTransaction:^(FMDatabase *db1, BOOL *rollback) {
                //数据库更新
                for(NSString *keys in dic) {
                    if([keys myContainsString:@"List"]) {
                        id<IGsonDataSaver> dbManager = [weakSelf getDataManager:keys];
                        ClientDBManager *manager = (ClientDBManager *) dbManager;
                        [manager sharedDatabase:db1];
                        NSString *userid = [AppConfigure objectForKey:USERID];
                        NSArray *array = [dic objectForKey:keys];
                        for(NSInteger i = 0;i < array.count;i++) {
                            NSDictionary *oneRecord = [array objectAtIndex:i];
                            if([dbManager insertOneRecord:oneRecord userid:userid]) {
                                [LogUtils Log:TAG content:@"insert suceess"];
                            } else {
                                *rollback = YES;
                                return ;
                            }
                        }
                    }
                }
            }];
            [queue close];
            
            NSString *neednext = [dic objectForKey:NEED_NEXT];
            if(IsStringNotEmpty(neednext) && ![@"false" isEqualToString:neednext] && ![@"(null)" isEqualToString:neednext]) {
                [LogUtils Log:TAG content:@"需要下次请求"];
                //继续迭代请求
                [weakSelf updateDatas];
            }
        }

        // 刷新列表数据
        [weakSelf getTaskList];
        [weakSelf tableEndload];
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
        [weakSelf tableEndload];
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
- (id<IGsonDataSaver>) getDataManager : (NSString *) name{
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

- (void)tableEndload {
    isInitLoading = NO;
    [emptyView dismiss];
    [self doneLoadingTableView:_table height:UI_SCREEN_HEIGHT - 64];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return taskList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = (int)indexPath.row;
    static NSString *CustomCellIdentifier = @"ScheduleProjectCell";
    
    static BOOL nibsRegistered = NO;
    ScheduleProjectCell *cell = (ScheduleProjectCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell == nil) {
        nibsRegistered = NO;
    }
    if (!nibsRegistered) {
        [LogUtils Log:TAG content:@"cell is nil"];
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([ScheduleProjectCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
        cell = (ScheduleProjectCell *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    }
    
    [cell initViewWithData:[taskList objectAtIndex:row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // 跳转到TableInfoActivity（详见关键控制点.pdf）
    // Intent.putExtra("BO_SINGLE_PROJECT_ID", 列表item中的隐藏字段)
    // Intent.putExtra("TYPE", "2")//界面标识（用于判断是从工程列表进入（1），还是待办任务列表进入（2））
    NSDictionary *selectedCellData = [taskList objectAtIndex:indexPath.row];
    TableInfoViewController *tableInfoViewController = [[TableInfoViewController alloc] initWithNibName:@"TableInfoViewController" bundle:nil];
    tableInfoViewController.projectDict = selectedCellData;
    tableInfoViewController.projectID = [selectedCellData objectForKey:@"bo_single_project_id"];
    tableInfoViewController.type = @"2";
    tableInfoViewController.sectionID = @"null";
    tableInfoViewController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableInfoViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

// 动态计算列表cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleProjectCell *cell = (ScheduleProjectCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell.projectName sizeToFit];
    CGSize labelSize = [cell.projectName.text sizeWithAttributes:@{NSFontAttributeName:cell.projectName.font}];
    
    float lines = labelSize.width / (UI_SCREEN_WIDTH - 16);
    int l = (int) lines;
    int lines_final = 0;
    if (lines - l > 0) {
        lines_final = lines + 1;
    } else {
        lines_final = l;
    }
    float part1 = 10 + lines_final * labelSize.height;
    float part2 = 4 + cell.missionCount.frame.size.height;
    float part3 = 11;
    float height = part1 + part2 + part3;
    
    return 1  + height;
}

// 列表cell高度估算方法
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0f;
}

#pragma mark 点击定位按钮
- (void)location {
    if ([self getLocationTimeIntervalSinceCurrentDateIsTimeOut]) {
        [self jumpToLocation];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"位置校验" message:@"您已经进行了GPS验证，进入将覆盖之前的验证记录。" delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"重新验证", nil];
        [alertView show];
    }
}

- (void)refreshLocation {
    // 获取最近一次定位的时间
    GPS_DATE_CURRENT_USERID = [NSString stringWithFormat:@"%@_%@", GPS_DATE, [AppConfigure objectForKey:USERID]];
    lastLocationTime = [AppConfigure objectForKey:GPS_DATE_CURRENT_USERID];
    lastLocationTime = lastLocationTime == nil ? @"" : lastLocationTime;
    _lastLocationTimeLabel.text = [NSString stringWithFormat:@"最新定位时间：%@", lastLocationTime];
}

/**
 *  跳转到签到界面
 */
- (void)jumpToLocation {
    UIViewController *validateViewController = [[ValidateViewController alloc] initWithNibName:@"ValidateViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:validateViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

/**
 *  判断最近一次定位是否不在有效时间区间内（时间区间：24小时）
 *
 *  @return 定位是否超时
 */
- (BOOL)getLocationTimeIntervalSinceCurrentDateIsTimeOut {
    if (IsStringEmpty(lastLocationTime)) {
        [LogUtils Log:TAG content:@"lastLocationTime = null"];
        return true;
    }

    NSDate *currentDate = [NSDate date];
    NSDate *lastLocationDate = [BaseFunction dateFromString:lastLocationTime dateFormat:DATE_LONG];
    double timeDifference = [currentDate timeIntervalSinceDate:lastLocationDate];
    
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
    if (alertView.tag == BASE_ALERT_TAG) {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
    } else if(buttonIndex == 1) {
        // 打开签到界面
        [self jumpToLocation];
    }
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
- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

- (void)viewDidAppear:(BOOL)animated {
    BOOL isOpened = [db open];
    NSLog(@"she %@",isOpened ? @"opened" : @"not opened");
    if (!isFirst) {
        [LogUtils Log:TAG content:@"is not first, refresh datas"];
        [self reqData];
        [self refreshLocation];
    } else {
        isFirst = NO;
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [db close];
    if ([request isExecuting]) {
        [request clearDelegatesAndCancel];
    }
}

// tabbar上的数字减一
- (void) delOneBadge {
    NSString *badgeValue;
    NSInteger badgeNum = [AppConfigure integerForKey:APP_ICON_BADGE_NUM];
    if(badgeNum <= 0) {
        badgeValue = nil;
    } else {
        badgeValue = [NSString stringWithFormat:@"%ld",badgeNum];
    }
    self.navigationController.tabBarItem.badgeValue = badgeValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
