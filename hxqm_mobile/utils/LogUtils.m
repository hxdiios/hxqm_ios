//
//  LogUtils.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/14.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "LogUtils.h"

@implementation LogUtils

+ (void) Log:(NSString *)tag content:(NSString *)content {
    if(LOG_ENABLED) {
        NSLog(@"%@-->%@",tag,content);
    }
}
@end
