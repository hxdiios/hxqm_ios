//
//  AppConfigure.m
//  ZheKou
//
//  Created by 陈煜 on 13-4-8.
//  Copyright (c) 2013年 runcom. All rights reserved.
//

#import "AppConfigure.h"

@implementation AppConfigure

#pragma mark - get set
//get方法

//object
+ (id)objectForKey:(NSString *)key {
    return [UserDefaults objectForKey:key];
}

//value
+ (NSString *)valueForKey:(NSString *)key {
    return [UserDefaults valueForKey:key] ? [UserDefaults valueForKey:key] : @"";
}

//int
+ (NSInteger) integerForKey:(NSString *)defaultName {
    return [UserDefaults integerForKey:defaultName];
}

//bool
+ (BOOL)boolForKey:(NSString *)defaultName {
    return [UserDefaults boolForKey:defaultName];
}

//set方法
//object
+ (void)setObject:(id)value ForKey:(NSString *)key {
    [UserDefaults setObject:value forKey:key];
}

//value
+ (void)setValue:(id)value forKey:(NSString *)key {
    [UserDefaults setValue:value forKey:key];
}

//int
+ (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [UserDefaults setInteger:value forKey:defaultName];
}

//bool
+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    [UserDefaults setBool:value forKey:defaultName];
}

//是否登录,YES为已登陆
+ (BOOL)isUserLogined {
    if ([UserDefaults valueForKey:LOGIN_NAME] && [UserDefaults valueForKey:PASSWORD]) {
        return YES;
    }
    return NO;
}

+ (void) loginOut {
    [AppConfigure setValue:nil forKey:LOGIN_NAME];
    [AppConfigure setValue:nil forKey:PASSWORD];
    [AppConfigure setObject:nil ForKey:USERID];
    [AppConfigure setObject:nil ForKey:USERNAME];
    [AppConfigure setObject:nil ForKey:JID];
}

@end
