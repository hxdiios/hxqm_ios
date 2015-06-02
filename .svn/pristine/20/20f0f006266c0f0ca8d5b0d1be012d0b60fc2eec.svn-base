//
//  BaseViewController.m
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseFormDataRequest.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "AppConfigure.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(CURRENT_IOS_VER >= 7.0) {
        //设置标题栏不能覆盖下面viewcontroller的内容
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //设置标题的文字为白色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)setNavHiden:(BOOL)hiden {
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:hiden animated:YES];
    }
}

-(UIButton *)createNavBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL) action alignment:(UIControlContentHorizontalAlignment)alignment{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,60,40);
    if(title) {
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = FontWithSize(16);
    }
    if(icon) {
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
        if(title) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        }
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    btn.contentHorizontalAlignment = alignment;
    return btn;
}

/**
 *  添加nav左按钮
 *  @param title 按钮的标题
 *  @param icon 按钮的图片
 *  @param action 按钮的点击事件
 */
-(void) addNavLeftBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createNavBtnByTitle:title icon:icon action:action alignment:UIControlContentHorizontalAlignmentLeft]];
}

-(void) addNavBackBtn:(NSString *)title {
    [self addNavLeftBtnByTitle:title icon:@"icon_back" action:@selector(back:)];
}

-(void) addNavBackBtn {
    [self addNavBackBtn:@"返回"];
}

/**
 *	添加nav右按钮
 *
 *	@param 	title 	文字
 *	@param 	icon 	图片
 *	@param 	action 	动作
 */
- (void)addNavRightBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self createNavBtnByTitle:title icon:icon action:action alignment:UIControlContentHorizontalAlignmentRight]];
}

//navBar关闭按钮
- (void)addNavCloseBtn {
    [self addNavRightBtnByTitle:nil icon:@"icon_close" action:@selector(close:)];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        
    }];
}

#pragma mark 会话超时
- (void)sessionTimeout {
    UIAlertView *sessionTimeoutAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"登录超时，是否重新登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
    sessionTimeoutAlert.tag = BASE_ALERT_TAG;
    [sessionTimeoutAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView.tag = %ld", alertView.tag);
    NSLog(@"buttonIndex = %ld", buttonIndex);
    if (BASE_ALERT_TAG == alertView.tag && buttonIndex == 1) {
        [self reLogin];
    }
}

// 重新登录
- (void) reLogin {
    [SVProgressHUD showWithStatus:@"重新登录中..."];
    NSURL *url = [NSURL URLWithString:LOGIN];
    BaseFormDataRequest *request = [BaseFormDataRequest requestWithURL:url];
    [request setPostValue:[AppConfigure objectForKey:LOGIN_NAME] forKey:@"j_username"];
    [request setPostValue:[AppConfigure objectForKey:PASSWORD] forKey:@"j_password"];
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"登录成功"];
        [self loginSuccess];
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD showErrorWithStatus:@"无法访问服务或网络"];
        [self loginFailed];
    }];
    [request startAsynchronous];
}

@end
