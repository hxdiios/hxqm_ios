//
//  EmptyView.h
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Refresh <NSObject>

- (void) refresh:(UIView *) empty;

@end

@interface EmptyView : UIControl
@property (weak, nonatomic) IBOutlet UIView *loading;
@property (weak, nonatomic) IBOutlet UIControl *netErr;
@property (weak, nonatomic) IBOutlet UIView *empty;

@property (assign,nonatomic) id<Refresh> delegate;

- (void) showLoading;
- (void) showNetErr;
- (void) showEmpty;
- (id) initWithFrame:(CGRect)frame;
- (void) dismiss;

@end


