//
//  ViewController.h
//  hxqm_mobile
//
//  Created by huaxin_mac2 on 15-1-5.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

//#import "AppConfigure.h"
#import <UIKit/UIKit.h>
#import "MyMacros.h"


@interface CrystalTabBarController : UITabBarController{
    NSArray *imagesOn;
    NSMutableArray *imagesOff;
    NSMutableArray *buttons;
    UIView *tabButtonsView;
    NSMutableArray *titles;
    
    NSMutableArray *bottomTabs;
    NSMutableArray *labels;
}

- (IBAction)click:(id)sender;
- (void)hideTab:(BOOL)hide;

- (void) clickAtIndex : (NSInteger) index;

@end
