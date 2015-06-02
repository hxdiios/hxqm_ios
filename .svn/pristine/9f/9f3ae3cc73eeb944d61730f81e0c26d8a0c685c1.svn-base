//
//  ViewController.m
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "CrystalTabBarController.h"
#import <QuartzCore/QuartzCore.h>

#define kTabBarHeight 40.0
#define TABBUTTON_X 10.0
#define NORMAL_BG_COLOR ColorWithRGB(37, 78, 156)
#define SELECTED_BG_COLOR ColorWithRGB(58,105,193)

@implementation CrystalTabBarController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.tabBarController.delegate = self;
    self.view.backgroundColor = NORMAL_BG_COLOR;
    // Do any additional setup after loading the view, typically from a nib.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        //iOS 5+
        [self.tabBar setFrame:CGRectMake(0, UI_SCREEN_HEIGHT - kTabBarHeight - 20, UI_SCREEN_WIDTH, kTabBarHeight + 1)];
        //[self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];//自定义背景图片
        [self.tabBar setBackgroundColor:NORMAL_BG_COLOR];
        for(UIView *view in self.view.subviews){
            if(![view isKindOfClass:[UITabBar class]]){
                view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - kTabBarHeight - 1);//试试改变
                break;
            }
        }
    }else {
        //iOS 4.whatever and below
        [self.view setBackgroundColor:NORMAL_BG_COLOR];
    }
    //新建一个tab按钮组
    self.tabBar.hidden = YES;
    tabButtonsView = [[UIView alloc]initWithFrame:CGRectMake(0, UI_SCREEN_HEIGHT - 20 - kTabBarHeight, UI_SCREEN_WIDTH, kTabBarHeight)];
    tabButtonsView.backgroundColor = NORMAL_BG_COLOR;
    [self.view addSubview:tabButtonsView];
    /*//背景效果
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, kTabBarHeight)];
    bg.backgroundColor = [UIColor clearColor];
    bg.image = [UIImage imageNamed:@"tabbar.png"];    
    //bg shadow
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, bg.bounds);
    bg.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    bg.layer.shadowColor = [UIColor blackColor].CGColor;
    bg.layer.shadowOffset = CGSizeMake(0, 0);
    bg.layer.shadowRadius = 0;
    bg.layer.shadowOpacity = 0.5;
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    bg.clipsToBounds = NO;
    
    [tabButtonsView addSubview:bg];*/
    
    //tab按钮
    buttons = [[NSMutableArray alloc] initWithCapacity:4];
    //tab super views
    bottomTabs = [[NSMutableArray alloc] initWithCapacity:4];
    labels = [[NSMutableArray alloc] initWithCapacity:4];
    imagesOn = @[@"ic_intro_selected",@"ic_mcustom_selected",@"ic_mchoose_selected",@"ic_setting_selected"];
    imagesOff = [NSMutableArray arrayWithObjects:@"ic_intro_unselected",@"ic_mcustom_unselected",@"ic_mchoose_unselected",@"ic_setting_unselected",nil];
    titles = [NSMutableArray arrayWithObjects:@"乐瑞优选",@"我的定制",@"我的自选",@"个人设定",nil];
    for (int i = 0; i < imagesOn.count; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(UI_SCREEN_WIDTH*i / 4, 0, UI_SCREEN_WIDTH / 4, kTabBarHeight)];
        view.backgroundColor = NORMAL_BG_COLOR;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH / 4, kTabBarHeight);
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = i;
        [btn setImage:[UIImage imageNamed:[imagesOff objectAtIndex:i]] forState:UIControlStateNormal];
        [btn setAdjustsImageWhenHighlighted:NO];
        [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30+ TABBUTTON_X, UI_SCREEN_WIDTH / 4, 19)];
        label.backgroundColor = NORMAL_BG_COLOR;
        label.text = [titles objectAtIndex:i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        
        [view addSubview:label];
        
        [view addSubview:btn];
        [buttons addObject:btn];
        [labels addObject:label];
        [bottomTabs addObject:view];
        [tabButtonsView addSubview:view];
    }
    //第一个按钮选中
    [self click:[buttons objectAtIndex:0]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}


#pragma mark - tab按钮事件

//tab选中事件
- (IBAction)click:(id)sender {
    UIButton *btn = sender;
    //设置tab切换
    [self clickAtIndex:btn.tag];
}

- (void) clickAtIndex:(NSInteger)index {
    /*if([AppConfigure isUserLogined]) {
        [self setSelectedIndex:index];
        [self setAllBtnsNormalExcept:index];
    } else {
        if(index == 1 || index == 2) {
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            login.delegate = self;
            LoginNavigationController *nav = [[LoginNavigationController alloc] initWithRootViewController:login];
            nav.investInfoDelegate = self;
            [self presentViewController:nav animated:YES completion:nil];
        } else {
            [self setSelectedIndex:index];
            [self setAllBtnsNormalExcept:index];
        }
    }*/
}

//按钮状态
- (void)setAllBtnsNormalExcept:(NSInteger)btnOn
{
    //其他off
    for (NSInteger i = btnOn + 1; i < btnOn + [buttons count]; i++) {
        [[buttons objectAtIndex:i%[buttons count]] setImage:[UIImage imageNamed:[imagesOff objectAtIndex:i%[buttons count]]] forState:UIControlStateNormal];
        [[bottomTabs objectAtIndex:i%[buttons count]] setBackgroundColor:NORMAL_BG_COLOR];
        [[labels objectAtIndex:i%[buttons count]] setBackgroundColor:NORMAL_BG_COLOR];
    }
    [[buttons objectAtIndex:btnOn] setImage:[UIImage imageNamed:[imagesOn objectAtIndex:btnOn]] forState:UIControlStateNormal];
    [[labels objectAtIndex:btnOn] setBackgroundColor:SELECTED_BG_COLOR];
    [[bottomTabs objectAtIndex:btnOn] setBackgroundColor:SELECTED_BG_COLOR];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{

}

- (void)hideTab:(BOOL)hide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    CGRect frame = tabButtonsView.frame;
    if (hide) {
        frame.origin.y = UI_SCREEN_HEIGHT;
    }else{
        frame.origin.y = UI_SCREEN_HEIGHT - frame.size.height;
    }
    
    tabButtonsView.frame = frame;
    [UIView commitAnimations];
}

@end
