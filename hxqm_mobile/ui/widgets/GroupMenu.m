//
//  GroupMenu.m
//  hxqm_mobile
//
//  Created by HelloWorld on 3/28/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "GroupMenu.h"
#import "AppDelegate.h"

#define GROUP_MENU_ROW_WIDTH 90
#define GROUP_MENU_ROW_HEIGHT 40

@interface GroupMenu()

@property (nonatomic, strong) UIImageView *menuBackgroundView;

@property (nonatomic, strong) UIButton *dateButton;
@property (nonatomic, strong) UIButton *distanceButton;
@property (nonatomic, strong) UIButton *majorButton;

@property (nonatomic, assign) BOOL isShow;

@end

@implementation GroupMenu {
    AppDelegate *appDelegate;
    CGRect btnFrame;
}

- (instancetype)initWithBtnFrame:(CGRect)frame {
    self = [super init];
    if (self){
        self.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT);
        
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        btnFrame = frame;
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    _menuBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(btnFrame.origin.x - btnFrame.size.width / 2, 0, GROUP_MENU_ROW_WIDTH, 150)];
    _menuBackgroundView.image = [UIImage imageNamed:@"group_menu_bg3"];
    _menuBackgroundView.userInteractionEnabled = YES;
    [self addSubview:_menuBackgroundView];
    
    _dateButton = [self buttonWithFrame:CGRectMake(0, 10, GROUP_MENU_ROW_WIDTH, GROUP_MENU_ROW_HEIGHT) ImageName:nil Action:@selector(dateButtonClick:) andTaget:self];
    [_dateButton setTitle:@"时间" forState:UIControlStateNormal];
    [_dateButton setBackgroundColor:[UIColor clearColor]];
    [_dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _dateButton.titleLabel.font = [UIFont systemFontOfSize:14];
    //    _threeDaysButton.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    [_menuBackgroundView addSubview:_dateButton];
    
    _distanceButton = [self buttonWithFrame:CGRectMake(0, 10 + GROUP_MENU_ROW_HEIGHT, GROUP_MENU_ROW_WIDTH, GROUP_MENU_ROW_HEIGHT) ImageName:nil Action:@selector(distanceButtonClick:) andTaget:self];
    [_distanceButton setTitle:@"距离" forState:UIControlStateNormal];
    [_distanceButton setBackgroundColor:[UIColor clearColor]];
    [_distanceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _distanceButton.titleLabel.font = [UIFont systemFontOfSize:14];
    //    _oneWeekButton.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    [_menuBackgroundView addSubview:_distanceButton];
    
    _majorButton = [self buttonWithFrame:CGRectMake(0, 15 + GROUP_MENU_ROW_HEIGHT * 2, GROUP_MENU_ROW_WIDTH, GROUP_MENU_ROW_HEIGHT) ImageName:nil Action:@selector(majorButtonClick:) andTaget:self];
    [_majorButton setTitle:@"大项" forState:UIControlStateNormal];
    [_majorButton setBackgroundColor:[UIColor clearColor]];
    [_majorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _majorButton.titleLabel.font = [UIFont systemFontOfSize:14];
    //    _oneMonthButton.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    [_menuBackgroundView addSubview:_majorButton];
}

- (void)dateButtonClick:(UIButton *)button {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self disMissView];
    if ([_delegate respondsToSelector:@selector(selectedBtnAtIndex:withBtnTitle:)]) {
        [_delegate selectedBtnAtIndex:0 withBtnTitle:@"时间"];
    }
}

- (void)distanceButtonClick:(UIButton *)button {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self disMissView];
    if ([_delegate respondsToSelector:@selector(selectedBtnAtIndex:withBtnTitle:)]) {
        [_delegate selectedBtnAtIndex:1 withBtnTitle:@"距离"];
    }
}

- (void)majorButtonClick:(UIButton *)button {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self disMissView];
    if ([_delegate respondsToSelector:@selector(selectedBtnAtIndex:withBtnTitle:)]) {
        [_delegate selectedBtnAtIndex:2 withBtnTitle:@"大项"];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self disMissView];
}

- (void)showMenuInSuperView:(UIView *)superView {
    [superView addSubview:self];
    _menuBackgroundView.alpha = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        _menuBackgroundView.alpha = 1;
    } completion:^(BOOL finished){
        _isShow = YES;
    }];
}

- (void)disMissView {
    if (_isShow == YES){
        _isShow = NO;
        [UIView animateWithDuration:0.25 animations:^{
            _menuBackgroundView.alpha = 0;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
        }];
    }
}

- (BOOL)isShow {
    return _isShow;
}

//图片按钮
- (UIButton *)buttonWithFrame:(CGRect)frame ImageName:(NSString *)imageName Action:(SEL)action andTaget:(id)taget
{
    UIImage *image = [UIImage imageNamed:imageName];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:taget action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    return button;
}

@end
