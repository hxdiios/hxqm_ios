//
//  ValidateViewController.h
//  hxqm_mobile
//
//  Created by HelloWorld on 1/20/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>

@protocol LocationDelegate <NSObject>
@required
-(void)getLocation:(float)longitude latitude:(float)latitude;
@end

@interface ValidateViewController : BaseViewController <CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
// iOS SDK中定位对象
@property (strong, nonatomic) CLLocationManager *locationManager;

@property id<LocationDelegate> delegate;
@end
