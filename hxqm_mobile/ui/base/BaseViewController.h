//
//  BaseViewController.h
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMacros.h"

#define BASE_ALERT_TAG -1

@interface BaseViewController : UIViewController <UIAlertViewDelegate>

- (void)setNavHiden:(BOOL)hiden;
- (void)addNavLeftBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action;
- (void)addNavRightBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action;
- (void)addNavBackBtn;
- (void)addNavBackBtn:(NSString *)title;
- (void)addNavCloseBtn;
- (IBAction)back:(id)sender;
-(UIButton *)createNavBtnByTitle:(NSString *)title icon:(NSString *)icon action:(SEL) action alignment:(UIControlContentHorizontalAlignment)alignment;
// 会话超时
- (void)sessionTimeout;
- (void)loginSuccess;
- (void)loginFailed;
@end
