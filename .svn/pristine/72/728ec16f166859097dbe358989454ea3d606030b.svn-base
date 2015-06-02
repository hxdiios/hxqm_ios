//
//  LoginViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "LoginViewController.h"
#import "Constants.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "AppDelegate.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 设置标题
    self.navigationItem.title = @"用户登录";
    // 设置标题文字的样式
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    // 设置背景图片
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"bg_main.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    _loginView.layer.masksToBounds = YES;
    _loginView.layer.cornerRadius = 5.0;
    _loginView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _loginView.layer.borderWidth = 1.0;
    
    _loginBtn.layer.masksToBounds = YES;
    _loginBtn.layer.cornerRadius = 5.0;
}

- (IBAction)loginClicked:(id)sender {
    if([self checkNameAndPsd]) {
        NSURL *url = [NSURL URLWithString:LOGIN];
        BaseFormDataRequest *request = [BaseFormDataRequest requestWithURL:url];
        [request setPostValue:_name.text forKey:@"j_username"];
        [request setPostValue:_psd.text forKey:@"j_password"];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

//检查用户名密码是否输入
- (BOOL) checkNameAndPsd {
    if(_name.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入用户名"];
        return NO;
    }
    
    if(_psd.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return NO;
    }
    
    return YES;
}

- (IBAction)hideKeyBoard:(id)sender {
    [self.view resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == _name) {
        [_name resignFirstResponder];
        [_psd becomeFirstResponder];
    } else {
        [_psd resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - asihttprequest delegate
- (void)requestStarted:(ASIHTTPRequest *)request {
    [SVProgressHUD showWithStatus:@"登陆中..."];
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    response = [response stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([response  isEqualToString:@"login_succeed"]) {
        [AppConfigure setValue:_name.text forKey:LOGIN_NAME];
        [AppConfigure setValue:_psd.text forKey:PASSWORD];
        
        //开启xmpp服务
        
        //请求用户信息
        NSURL *url = [NSURL URLWithString:LOGIN_FULLNAME];
        BaseFormDataRequest *request = [BaseFormDataRequest requestWithURL:url];
        __weak BaseFormDataRequest *weakRequest = request;
        [request setFailedBlock:^{
            [SVProgressHUD showErrorWithStatus:@"无法访问网络"];
        }];
        [request setCompletionBlock:^{
            [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
            NSString *result = [weakRequest responseString];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
            NSString *userid = [dic objectForKey:@"USERID"];
            NSString *uname = [dic objectForKey:@"USERNAME"];
            NSString *roleId = [dic objectForKey:@"ROLEIDS"];
            //保存用户数据
            [AppConfigure setObject:userid ForKey:USERID];
            [AppConfigure setObject:uname ForKey:USERNAME];
            [AppConfigure setObject:roleId ForKey:ROLEID];
            //进入导航页面
            [self dismissViewControllerAnimated:NO completion:nil];
            
            //连接xmpp服务器
            NSString *jid = [BaseFunction makeJabberdID:_name.text];
            [AppConfigure setObject:jid ForKey:JID];
            //登录成功后接着登录xmpp服务器
            AppDelegate *appdelegate = [self appDelegate];
            [appdelegate connect];
            
            [_delegate loginSuccess];
        }];
        [request startAsynchronous];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"用户名或者密码错误"];
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD showErrorWithStatus:@"网络异常"];
}

- (AppDelegate *) appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *) xmppStream {
    return [[self appDelegate] xmppStream];
}


@end
