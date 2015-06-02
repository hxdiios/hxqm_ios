//
//  SettingViewController.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "BaseViewController.h"
#import "ASIHTTPRequest.h"
#import "BaseAjaxHttpRequest.h"

@protocol LoginOutDelegate <NSObject>

- (void) loginOut;

@end

@interface SettingViewController : BaseViewController <ASIHTTPRequestDelegate, UIAlertViewDelegate>

@property id<LoginOutDelegate> delegate;

@end
