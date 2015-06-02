//
//  LoginViewController.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/14/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "BaseViewController.h"
#import "SVProgressHUD.h"
#import "BaseFormDataRequest.h"

@protocol LoginDelegate <NSObject>

- (void) loginSuccess;

@end

@interface LoginViewController : BaseViewController<UITextFieldDelegate,ASIHTTPRequestDelegate>

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *psd;

@property (weak,nonatomic) id<LoginDelegate> delegate;
@end
