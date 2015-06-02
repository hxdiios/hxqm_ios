//
//  AboutViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/19/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "AboutViewController.h"
#import "Constants.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 设置标题栏文字
    self.navigationItem.title = @"关于";
    // 设置标题文字的样式
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // 添加导航栏返回按钮
    [self addNavBackBtn:@"返回"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *currentSoftVerName = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    _versionLabel.text = [NSString stringWithFormat:@"For iOS V%@", currentSoftVerName];
}

- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        
    }];
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
