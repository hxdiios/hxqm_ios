//
//  GroupMenu.h
//  hxqm_mobile
//
//  Created by HelloWorld on 3/28/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GroupMenuDelegate <NSObject>

- (void) selectedBtnAtIndex:(NSInteger)index withBtnTitle:(NSString *)btnTitle;

@end


@interface GroupMenu : UIView

- (instancetype)initWithBtnFrame:(CGRect)frame;

- (void)showMenuInSuperView:(UIView *)superView;

@property (assign,nonatomic) id<GroupMenuDelegate> delegate;

- (BOOL)isShow;

- (void)disMissView;

@end
