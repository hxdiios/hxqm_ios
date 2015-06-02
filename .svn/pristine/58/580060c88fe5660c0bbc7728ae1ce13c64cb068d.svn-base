//
//  ShakeViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ShakeViewController.h"
#import "AudioToolbox/AudioToolbox.h"
#import "BaseFunction.h"
#import "SingleProjectManager.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "SVProgressHUD.h"
#import "SectionManager.h"
#import "SectionViewController.h"
#import "TableInfoViewController.h"


@interface ShakeViewController (){
    FMDatabase *db;
    NSString *projectId;
}

@end

@implementation ShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    db = [BaseFunction createDB];
    [db open];
    // 设置标题
    [self setTitle:@"摇一摇"];
    // 设置标题文字的样式
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // 添加导航栏返回按钮
    [self addNavBackBtn:@"返回"];
    //让该View成为第一	响应者
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

//能否成为第一响应者，默认是NO
-(BOOL)canBecomeFirstResponder {
    return YES;
}

//检测到摇动
- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
}

//摇动取消
- (void) motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
}

//摇动结束
- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    //摇动结束
    if (event.subtype == UIEventSubtypeMotionShake) {
        //放个声音
        static SystemSoundID soundID = 0;
        NSString * path = [[NSBundle mainBundle] pathForResource:@"shake" ofType:@"wav"];
        if (path) {
            AudioServicesCreateSystemSoundID( (__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
        }
        AudioServicesPlaySystemSound(soundID);
        //振你一下
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //选择随机的项目
        SingleProjectManager *singleProjectManager = [[SingleProjectManager alloc] initWithDb:db];
        NSMutableArray *projectDictArray = [singleProjectManager getRandomProjectInfo:[AppConfigure objectForKey:USERID]];
        if([BaseFunction isArrayEmpty:projectDictArray]){
            [SVProgressHUD showErrorWithStatus:@"未找到项目！"];
            return;
        }
        NSInteger randomNum = [BaseFunction random:[projectDictArray count]];
        NSDictionary *projectDict = [projectDictArray objectAtIndex:randomNum];
        NSString *projectName = [projectDict objectForKey:@"project_name"];
        projectId =[projectDict objectForKey:@"bo_single_project_id"];
        //再弹个窗
        UIAlertView *verifyAlert = [[UIAlertView alloc] initWithTitle:@"随机项目" message:projectName delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [verifyAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        SectionManager *sectionManager = [[SectionManager alloc] initWithDb:db];
        // 判断工程是否有分段存在
        BOOL hasSection = [sectionManager getHasSelectionByProjectId:projectId userid:[AppConfigure objectForKey:USERID]];
        if (hasSection) {
            SectionViewController *sectionViewController = [[SectionViewController alloc] initWithNibName:@"SectionViewController" bundle:nil];
            // 传入数据
            sectionViewController.projectID = projectId;
            sectionViewController.type = @"1";
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sectionViewController];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        } else {// 没有分段存在，则跳转到关键控制点界面
            TableInfoViewController *tableInfoViewController = [[TableInfoViewController alloc] initWithNibName:@"TableInfoViewController" bundle:nil];
            // 传入数据
            tableInfoViewController.projectID = projectId;
            tableInfoViewController.type = @"1";
            tableInfoViewController.sectionID = @"null";
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tableInfoViewController];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
}

@end
