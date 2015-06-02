//
//  LogUtils.h
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/14.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOG_ENABLED YES

@interface LogUtils : NSObject

+ (void) Log : (NSString *) tag content : (NSString *) content;
@end
