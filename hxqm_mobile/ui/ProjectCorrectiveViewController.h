//
//  ProjectCorrectiveViewController.h
//  hxqm_mobile
//
//  Created by HuaXin on 15/5/20.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BaseHomeViewController.h"

@interface ProjectCorrectiveViewController :  BaseHomeViewController<UIWebViewDelegate,ASIHTTPRequestDelegate,UIScrollViewDelegate>

@property (copy, nonatomic) NSString *boProblemReplyId;
@property (copy, nonatomic) NSString *boProblemId;
@property (copy, nonatomic) NSString *types;
@property (copy, nonatomic) NSString *isZD;
@property (copy, nonatomic) NSString *boContentId;

@end
