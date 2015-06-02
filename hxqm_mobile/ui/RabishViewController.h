//
//  RabishViewController.h
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/28.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "BaseViewController.h"

@interface RabishViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *photoSize;
- (IBAction)changeDate:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *photoDate;
@property (weak, nonatomic) IBOutlet UIImageView *dateLine;

@property (weak, nonatomic) IBOutlet UIButton *clearDownloadBt;
- (IBAction)clearDownloadPhoto:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *clearDoodleBt;
- (IBAction)clearDoodlePhoto:(id)sender;
- (IBAction)clear:(id)sender;
@end


