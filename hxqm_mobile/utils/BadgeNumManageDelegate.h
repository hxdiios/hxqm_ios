//
//  BadgeNumManageDelegate.h
//  hxqm_mobile
//
//  Created by 刘志 on 15/3/11.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BadgeNumManageDelegate <NSObject>

@optional
//数字提示＋1
- (void) addOneBadge;

//数字提示-1
- (void) delOneBadge;

@end
