//
//  MyMacros.h
//  ZheKou
//
//  Created by 陈煜 on 13-4-3.
//  Copyright (c) 2013年 runcom. All rights reserved.
//

#ifndef ZheKou_MyMacros_h
#define ZheKou_MyMacros_h

//设备版本
#pragma mark - device

#define CURRENT_IOS_VER             [[[UIDevice currentDevice] systemVersion] floatValue]
#define CURRENT_SYSTEN_VER          [[UIDevice currentDevice] systemVersion]
#define CURRENT_SOFT_VER            [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]
#define CURRENT_LANGUAGE            [[NSLocale preferredLanguages] objectAtIndex:0]
#define IS_IOS7_LATER               (CURRENT_IOS_VER >= 7.0)

//屏幕、控件尺寸
#pragma mark - UI

#define UI_NAVIGATION_BAR_HEIGHT        44
#define UI_TOOL_BAR_HEIGHT              44
#define UI_TAB_BAR_HEIGHT               49
#define UI_STATUS_BAR_HEIGHT            20
#define UI_SCREEN_HEIGHT_IP4            480
#define UI_SCREEN_HEIGHT_IP5            568
#define UI_SCREEN_HEIGHT                ([[UIScreen mainScreen] bounds].size.height)
#define UI_SCREEN_WIDTH                 ([[UIScreen mainScreen] bounds].size.width)
#define UI_SCREEN_D_HEIGHT              UI_SCREEN_HEIGHT - UI_SCREEN_HEIGHT_IP4

#define isRetina                        ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define isIP5                           ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isPad                           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define BottomEdgeYOfView(view)             view.frame.origin.y + view.frame.size.height

//颜色
#pragma mark - color
#define ColorWithRGB(r,g,b)             [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ColorWithRGBA(r,g,b,a)          [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define ColorWithWhite(w)               [UIColor colorWithWhite:w alpha:1.0]
#define ColorWithWhiteAlpha(w,a)        [UIColor colorWithWhite:w alpha:a]

#define TABLE_HIGHLIGHT_COLOR           ColorWithRGBA(32, 154, 161, 0.8)
#define BACKGROUND_COLOR                ColorWithRGB(242,242,239)
#define ORANGE_COLOR                    ColorWithRGB(234,67,28)
#define CLEAR_COLOR                     [UIColor clearColor]
#define WHITE_COLOR                     [UIColor whiteColor]
#define BLACK_COLOR                     [UIColor blackColor]
#define TABLE_SELECTED_COLOR            ColorWithRGB(238,238,238)

#define NAVIGATE_BAR_COLOR              ColorWithRGB(22,165,215);

//字体
#pragma mark - font
#define FontWithNameSize(name, size)    [UIFont fontWithName:name size:size]
#define FontWithSize(size)              [UIFont systemFontOfSize:size]
#define BoldFontWithSize(size)          [UIFont boldSystemFontOfSize:size]
//是否为中文
#define IS_CH_SYMBOL(chr)               ((int)(chr)>127)

//图片
#pragma mark - iamge

#define ImageNamed(name)                [UIImage imageNamed:name]
#define ImageWithFile(fileName)         [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:fileName ofType:@"png"]]


//线程
#pragma mark - GCD

#define Global(block)                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define Main(block)                     dispatch_async(dispatch_get_main_queue(),block)
#define kTmpQueue                       dispatch_queue_create("zhijiantong", NULL)

//common
#define ApplicationDelegate             [UIApplication sharedApplication].delegate
#define UserDefaults                    [NSUserDefaults standardUserDefaults]

#define DocumentsDirectory              [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]  //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define AppDirectory                    [[NSBundle mainBundle] bundlePath]


#define StringByTrimWhiteSpace(text)    [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define IsStringEmpty(string)           (!string || [@"" isEqualToString:string])
#define IsStringNotEmpty(string)        (string && ![@"" isEqualToString:string])

//app sandbox
#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#endif
