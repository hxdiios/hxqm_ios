//
//  RectifyViewController.h
//  Rectify-iOS
//
//  Created by Fury on 5/8/15.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseHomeViewController.h"
#import "BadgeNumManageDelegate.h"

@interface RectifyJsToObjectiveC :  BaseHomeViewController<UIWebViewDelegate,ASIHTTPRequestDelegate,UIScrollViewDelegate>

@property (copy, nonatomic) NSString *boProblemReplyId;
@property (copy, nonatomic) NSString *boProblemId;
@property (copy, nonatomic) NSString *types;
@property (copy, nonatomic) NSString *isZD;
@property (copy, nonatomic) NSString *boContentId;

@property (nonatomic,assign) id<BadgeNumManageDelegate> delegate;

@end
