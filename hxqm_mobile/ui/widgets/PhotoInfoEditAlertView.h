//
//  PhotoInfoEditAlertView.h
//  hxqm_mobile
//
//  Created by HelloWorld on 3/6/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoInfoEditAlertView : UIView

@property (weak, nonatomic) IBOutlet UISegmentedControl *formalOrTempSegment;
@property (weak, nonatomic) IBOutlet UITextField *photoNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *memoTextField;

- (NSDictionary *)getAlertViewDatas;

- (id) initWithFrame:(CGRect)frame isFormal:(NSString *)isFormal photoName:(NSString *)photoName photoNameRule:(NSString *)photoNameRule memo:(NSString *)memo projectName:(NSString *)projectName contentName:(NSString *)contentName;

- (void)setInputDisable:(BOOL)disable;

@end
