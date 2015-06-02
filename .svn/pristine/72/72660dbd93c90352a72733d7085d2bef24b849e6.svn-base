//
//  AppDelegate.h
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "ProjsViewController.h"
#import "ScheduleViewController.h"
#import "SettingViewController.h"
#import "AppConfigure.h"
#import "FICImageCache.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "WelcomeViewController.h"
#import "BadgeNumManageDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSString *password;
    BOOL isOpen;
    XMPPReconnect *xmppReconnect;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,readonly,strong) XMPPStream *xmppStream;

@property (nonatomic,assign) id<BadgeNumManageDelegate> badgeNumDelegate;

/**
 *  跟xmpp服务器连接
 *
 *  @return YES表示连接成功否则是否
 */
- (BOOL) connect;

/**
 *  断开xmpp服务器连接
 */
- (void) disconnect;

@end
