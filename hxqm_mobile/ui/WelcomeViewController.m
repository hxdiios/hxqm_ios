//
//  WelcomeViewController.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/2/10.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"
#import "LogUtils.h"

#define TAG @"WelcomeViewController"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //隐藏导航条
    self.navigationController.navigationBar.hidden = YES;
    //检查更新
    [self checkUpdate];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.badgeNumDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - init tabbar
- (void) initTabBarController {
    //跳转到原先的Nav界面
//    NavigateViewController *rootController = [[NavigateViewController alloc] init];
    
    // 首页
    HomeViewController *navigateController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController *rootController = [[UINavigationController alloc] initWithRootViewController:navigateController];
    
    // 首页底部导航item
    UITabBarItem *homeItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:nil tag:0];
    homeItem.image = ImageNamed(@"icon_home_item_normal");
    UIImage *homeSelectedImg = ImageNamed(@"icon_home_item_selected");
    homeItem.selectedImage = [homeSelectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navigateController.tabBarItem = homeItem;
    
    // 工程列表页面
    ProjsViewController *projsController = [[ProjsViewController alloc] initWithNibName:@"ProjsViewController" bundle:nil];
    UINavigationController *projsNavController = [[UINavigationController alloc] initWithRootViewController:projsController];
    
    // 工程列表底部导航item
    UITabBarItem *projsItem = [[UITabBarItem alloc] initWithTitle:@"工程列表" image:nil tag:1];
    projsItem.image = ImageNamed(@"icon_projs_item_normal");
    UIImage *projsSelectedImg = ImageNamed(@"icon_projs_item_selected");
    projsItem.selectedImage =  [projsSelectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    projsController.tabBarItem = projsItem;
    
    // 待办页面
//    ScheduleViewController *scheController = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
//    UINavigationController *scheNavController = [[UINavigationController alloc] initWithRootViewController:scheController];
    ToDoListViewController *scheController = [[ToDoListViewController alloc] initWithNibName:@"ToDoListViewController" bundle:nil];
    UINavigationController *scheNavController = [[UINavigationController alloc] initWithRootViewController:scheController];
    
    // 待办底部导航item
    UITabBarItem *scheItem = [[UITabBarItem alloc] initWithTitle:@"待办" image:nil tag:2];
    scheItem.image = ImageNamed(@"icon_sche_item_normal");
    UIImage *scheSelectedImg = ImageNamed(@"icon_sche_item_selected");
    scheItem.selectedImage = [scheSelectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    scheController.tabBarItem = scheItem;
    // 显示未读消息数量
    NSInteger badgeNum = [AppConfigure integerForKey:APP_ICON_BADGE_NUM];
    if(badgeNum > 0) {
        scheItem.badgeValue = [NSString stringWithFormat:@"%ld",badgeNum];
    }
    
    // 设置页面
    SettingViewController *settingController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    settingController.delegate = self;
    UINavigationController *settingNavController = [[UINavigationController alloc] initWithRootViewController:settingController];
    
    // 设置底部导航item
    UITabBarItem *settingItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:nil tag:4];
    settingItem.image = ImageNamed(@"icon_setting_item_normal");
    UIImage *settingSelectedImg = ImageNamed(@"icon_setting_item_selected");
    settingItem.selectedImage = [settingSelectedImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingNavController.tabBarItem = settingItem;
    
    // 初始化tab tab controller
    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.viewControllers = @[rootController,projsNavController,scheNavController,settingNavController];
    _tabBarController.tabBar.tintColor = ColorWithRGB(75, 75, 75);
    // 设置tab bar item的字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ColorWithRGB(255, 131, 74),NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}

#pragma mark - check update
- (void) checkUpdate {
    NSURL *url = [NSURL URLWithString:CHECK_UPDATE];
    BaseAjaxHttpRequest *request = [BaseAjaxHttpRequest requestWithURL:url];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentSoftVer = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSInteger areaCode = [AppConfigure integerForKey:AREA_CODE];
    NSInteger majorCode = [AppConfigure integerForKey:MAJOR_CODE];
    NSInteger templateCode = [AppConfigure integerForKey:TEMPLATE_CODE];
    NSInteger examBasisIndexCode = [AppConfigure integerForKey:EXAM_BASIS_INDEX_CODE];
    NSDictionary *dic = @{VER_CODE:currentSoftVer,
                          AREA_CODE:[NSString stringWithFormat:@"%ld",areaCode],
                          MAJOR_CODE:[NSString stringWithFormat:@"%ld",majorCode],
                          TEMPLATE_CODE:[NSString stringWithFormat:@"%ld",templateCode],
                          EXAM_BASIS_INDEX_CODE:[NSString stringWithFormat:@"%ld",examBasisIndexCode],
                          @"USER-AGENT":@"IPHONE"};
    [request setPostBody:dic];
    request.delegate = self;
    [request startSynchronous];
}

#pragma mark - check update http delegate
- (void) requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"网络异常"];
    [self checkLoginStatus];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    Global((^{
        //解析数据
        NSString *result = [request responseString];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
        
        //提示更新下载
        Main(^{
            if([dic.allKeys containsObject:@"AREA_VER"]) {
                NSNumber *areaCode = [dic objectForKey:@"AREA_VER"];
                [AppConfigure setInteger:areaCode.integerValue forKey:AREA_CODE];
            }
            if([dic.allKeys containsObject:@"MAJOR_VER"]) {
                NSNumber *majorCode = [dic objectForKey:@"MAJOR_VER"];
                [AppConfigure setInteger:majorCode.integerValue forKey:MAJOR_CODE];
            }
            if([dic.allKeys containsObject:@"TEMPLATE_VER"]) {
                NSNumber *majorCode = [dic objectForKey:@"TEMPLATE_VER"];
                [AppConfigure setInteger:majorCode.integerValue forKey:TEMPLATE_CODE];
            }
            if([dic.allKeys containsObject:@"EXAM_BASIS_INDEX_VER"]) {
                NSNumber *majorCode = [dic objectForKey:@"EXAM_BASIS_INDEX_VER"];
                [AppConfigure setInteger:majorCode.integerValue forKey:EXAM_BASIS_INDEX_CODE];
            }
            NSNumber *vercode = [dic objectForKey:@"VER_CODE"];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *currentSoftVer = [infoDictionary objectForKey:@"CFBundleVersion"];
            NSString *currentSoftVerName = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            if(vercode.intValue > currentSoftVer.intValue) {
                NSString *verName = [dic objectForKey:@"VER_NAME"];
                NSString *verDetail = [dic objectForKey:@"VER_DETAIL"];
                [self showUpdateAlertView:currentSoftVerName newVerName:verName verDetail:verDetail];
            } else {
                [self checkLoginStatus];
            }
        });
       
        FMDatabaseQueue *queue = [BaseFunction createDBQueue];
        //更新关键点模版
        NSArray *templateList = [dic objectForKey:@"TEMPLATE_LIST"];
        if(templateList.count > 0) {
            [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                TemplateManager *templateManager = [[TemplateManager alloc] init];
                [templateManager sharedDatabase:db];
                for(NSInteger i = 0 ; i < templateList.count ; i ++) {
                    NSDictionary *item = [templateList objectAtIndex:i];
                    BOOL success = [templateManager saveTemplateInfo:item];
                    if(!success) {
                        *rollback = YES;
                        return ;
                    }
                }
            }];
        }
        
        //更新专业
        NSArray *majorList = [dic objectForKey:MAJOR_LIST];
        NSNumber *majorVer = [dic objectForKey:@"MAJOR_VER"];
        [AppConfigure setInteger:majorVer.integerValue forKey:MAJOR_VER];
        if(majorList.count > 0) {
            NSMutableString *majorListString = [self parseArrayToJsonString:majorList];
            [AppConfigure setObject:majorListString ForKey:MAJOR_LIST];
        }
        
        //更新区域
        NSArray *areaList = [dic objectForKey:@"AREA_LIST"];
        NSNumber *areaVer = [dic objectForKey:@"AREA_VER"];
        [AppConfigure setInteger:areaVer.integerValue forKey:AREA_VER];
        if(areaList.count > 0) {
            NSMutableString *areaListString = [self parseArrayToJsonString:areaList];
            [AppConfigure setObject:areaListString ForKey:AREA_LIST];
        }
        
        //更新考核依据
        NSArray *examBasisIndexList = [dic objectForKey:EXAM_BASIS_INDEX_LIST];
        if(examBasisIndexList.count > 0) {
            NSMutableString *examBasisIndexListString = [self parseArrayToJsonString:examBasisIndexList];
            [AppConfigure setObject:examBasisIndexListString ForKey:EXAM_BASIS_INDEX_LIST];
        }
        
        //更新距离
        NSString *distance = [dic objectForKey:DISTANCE];
        if(distance) {
            [AppConfigure setObject:distance ForKey:DISTANCE];
        }
        
        //更新拍照点数据
        NSArray *pointList = [dic objectForKey:@"POINT_LIST"];
        if(pointList.count > 0) {
            NSNumber *templateVerInt = [dic objectForKey:@"TEMPLATE_VER"];
            NSString *templateVerString = [[NSString alloc] initWithFormat:@"%ld",templateVerInt.integerValue];
            //更新拍照点版本号
            [AppConfigure setObject:templateVerString ForKey:TEMPLATE_VER];
            
            [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                TemplateManager *templateManager = [[TemplateManager alloc] init];
                [templateManager sharedDatabase:db];
                for(NSInteger i = 0 ; i < pointList.count; i ++) {
                    NSDictionary *item = [pointList objectAtIndex:i];
                    [templateManager savePointInfo:item];
                    //更新拍照
                    NSArray *images = [item objectForKey:@"IMAGELIST"];
                    if(images.count > 0) {
                        for (NSInteger j = 0; j < images.count; j++) {
                            BOOL success = [templateManager savePointImage:[images objectAtIndex:j] userid:@"1"];
                            if(!success) {
                                *rollback = YES;
                                return;
                            }
                        }
                    }
                }
            }];
        }
        
        [queue close];
    }));
    
}

//将解析得到的json array转化为nsstring
- (NSMutableString *) parseArrayToJsonString : (NSArray *) jsonArray {
    NSMutableString *jsonString = [[NSMutableString alloc] init];
    for(NSInteger i = 0 ; i < jsonArray.count ; i++) {
        NSDictionary *item = [jsonArray objectAtIndex:i];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:item
                                                           options:0
                                                             error:&error];
        NSString *itemString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [jsonString appendString:itemString];
        if(i != jsonArray.count - 1) {
            [jsonString appendString:@","];
        }
    }
    [jsonString insertString:@"[" atIndex:0];
    [jsonString appendString:@"]"];
    return jsonString;
}

#pragma mark 显示更新提示框
- (void) showUpdateAlertView :(NSString *)olderVer newVerName:(NSString *) newVerName verDetail : (NSString *) verDetail {
    NSString *title = [NSString stringWithFormat:@"本次更新将从版本%@更新到%@",olderVer,newVerName];
    UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:title message:verDetail delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"下载", nil];
    [updateAlert show];
}

#pragma mark - update alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        //打开网页下载
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BASE_URL]];
    }
    [self checkLoginStatus];
}

#pragma mark - login
//检查用户登录记录
- (void) checkLoginStatus {
    if([AppConfigure isUserLogined]) {
        [self tryLogin];
    } else {
        LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        loginController.delegate = self;
        UINavigationController *rootController = [[UINavigationController alloc] initWithRootViewController:loginController];
        //[self presentViewController:rootController animated:NO completion:nil];
        [self.view.window.rootViewController presentViewController:rootController animated:NO completion:nil];
    }
}

//尝试后台登录
- (void) tryLogin {
    NSURL *url = [NSURL URLWithString:LOGIN];
    BaseFormDataRequest *request = [BaseFormDataRequest requestWithURL:url];
    [request setPostValue:[AppConfigure objectForKey:LOGIN_NAME] forKey:@"j_username"];
    [request setPostValue:[AppConfigure objectForKey:PASSWORD] forKey:@"j_password"];
    [request setCompletionBlock:^{
        [self loginSuccess];
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问异常"];
        [self loginSuccess];
    }];
    [request startAsynchronous];
}

- (void) loginSuccess {
    _tabBarController = nil;
    [self initTabBarController];
    [self presentViewController:_tabBarController animated:NO completion:nil];
}

- (void) loginOut {
    //将此前登录用户的xmpp连接断开
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate disconnect];
    
    //显示登录页面
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginController.delegate = self;
    UINavigationController *rootController = [[UINavigationController alloc] initWithRootViewController:loginController];
    [self presentViewController:rootController animated:NO completion:nil];
}

- (void) addOneBadge {
    //更新待办下面的显示数字
    NSInteger badgeNum = [AppConfigure integerForKey:APP_ICON_BADGE_NUM];
    if(_tabBarController) {
        [AppConfigure setValue:@"1" forKey:NEED_REFRESH];
        UIViewController *controller = [_tabBarController.viewControllers objectAtIndex:2];
        controller.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",badgeNum];
    }
}
@end
