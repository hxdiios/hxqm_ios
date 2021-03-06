//
//  ValidateViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/20/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ValidateViewController.h"
#import "MyMacros.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "SVProgressHUD.h"
#import "PhotoManager.h"
#import "LogUtils.h"
#import "Constants.h"
#import "UIImage+FixOrientation.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "UploadLocationViewController.h"

#define TAG @"_ValidateViewController"
#define PHOTO_SAVE_TYPE @"jpg"

@interface ValidateViewController () {
    // 纬度
    NSNumber *latitude;
    // 经度
    NSNumber *longitude;
    // 照片
    UIImage *verifyPhoto;
    // 标记确认按钮是否已经显示，避免重复添加确认按钮
    BOOL isShowConfirmBtn;
    NSMutableArray *locatingImages;
    UIImageView *photo;
    UIView *newLine;
    BOOL isTakePhoto;
}

@property (weak, nonatomic) IBOutlet UIView *locationValidateRootView;
@property (weak, nonatomic) IBOutlet UIView *identityValidateRootView;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIImageView *locationOKBtn;
@property (weak, nonatomic) IBOutlet UIImageView *locating;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIImageView *cameraOKBtn;
@property (weak, nonatomic) IBOutlet UILabel *locationInfo;
@property (weak, nonatomic) IBOutlet UILabel *photoAboveLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *line;

@end

@implementation ValidateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置标题
    [self setTitle:@"签到"];
    // 设置标题文字的样式
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    // 添加导航栏返回按钮
    [self addNavBackBtn:@"返回"];
    _mainView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, _scrollView.frame.size.height);
    _scrollView.contentSize = CGSizeMake(0, _mainView.frame.size.height);
    [_scrollView addSubview:_mainView];
    
    isShowConfirmBtn = NO;
    isTakePhoto = NO;
    
    locatingImages = [NSMutableArray array];
    for (int i = 1; i <= 12; i++) {
        NSString *imgName = @"";
        // 02:表示2位，不够的用0来代替
        imgName = [NSString stringWithFormat:@"locate_%02d.png", i];
        // 这个方法有缓存（无法释放），只需要传文件名就可以了
        // UIImage *img = [UIImage imageNamed:imgName];
        // 全路径
        NSString *path = [[NSBundle mainBundle] pathForResource:imgName ofType:nil];
        // 这个方法无缓存（用完就会释放），需要传全路径
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
        
        [locatingImages addObject:img];
    }
}

#pragma mark 拍照按钮的点击方法
- (IBAction)takePhoto:(id)sender {
    
    //判断相机权限
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType :AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务不可用" message:LG_CAMERA_ERR delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 禁用拍照按钮，以免多次点击
        _cameraBtn.enabled = NO;
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 相机
        sourceType = UIImagePickerControllerSourceTypeCamera;
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        // 设置照片是否可编辑
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = sourceType;
        
        //此处的delegate是上层的ViewController，如果你直接在ViewController使用，直接self就可以了
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
}

#pragma mark 拍完照片且确定使用照片的回调委托方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        // 将显示照片的控件、身份验证成功的控件显示出来
        _cameraOKBtn.hidden = NO;
        _line.hidden = YES;
        
        // 获取拍摄的照片
        UIImage *image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
        // 赋值给verifyPhoto，用于完成两个验证之后点击确认按钮时保存
        verifyPhoto = [image fixOrientation];
        // 根据高度的缩放比，计算缩放之后的宽度
        int pWidth = image.size.width * (UI_SCREEN_WIDTH / image.size.height);
        // 照片显示的高度大小为屏幕的宽度大小
        int pHeight = UI_SCREEN_WIDTH;
        float photoY = _photoAboveLabel.frame.origin.y + _photoAboveLabel.frame.size.height + 10;
        NSData *photoCompressData = UIImageJPEGRepresentation(image, kCompressionQualityLow);
        if (isTakePhoto) {
            photo.frame = CGRectMake((UI_SCREEN_WIDTH - pWidth) / 2, photoY, pWidth, pHeight);
            photo.image = [UIImage imageWithData:photoCompressData];
            newLine.frame = CGRectMake(0, photoY + pHeight + 5, UI_SCREEN_WIDTH, 1);
            [_identityValidateRootView setNeedsDisplay];
        } else {
            photo = [[UIImageView alloc] initWithImage:[UIImage imageWithData:photoCompressData]];
            photo.frame = CGRectMake((UI_SCREEN_WIDTH - pWidth) / 2, photoY, pWidth, pHeight);
            [_identityValidateRootView insertSubview:photo belowSubview:[_identityValidateRootView viewWithTag:1]];
            newLine = [[UIView alloc] initWithFrame:CGRectMake(0, photoY + pHeight + 5, UI_SCREEN_WIDTH, 1)];
            newLine.backgroundColor = [UIColor lightGrayColor];
            [_identityValidateRootView insertSubview:newLine belowSubview:photo];
            isTakePhoto = YES;
        }
        
        image = nil;
        _cameraBtn.enabled = YES;
        // 如果之前完成了定位验证，则显示确认按钮
        if (!_locationOKBtn.isHidden) {
            [self showDoneBtn];
        }
    }];
}

#pragma mark 取消照片时回调的委托方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    _cameraBtn.enabled = YES;
}

#pragma mark 设置身份验证View的高度和View下方的分割线的Y轴位置
- (void)setViewWidth:(int)width height:(int)height {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"before line's frame = %@", NSStringFromCGRect(_line.frame)]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"before identityValidateRootView frame = %@", NSStringFromCGRect(_identityValidateRootView.frame)]];
    CGRect oldLineFrame = _line.frame;
    CGRect newLineFrame = CGRectMake(oldLineFrame.origin.x, oldLineFrame.origin.y + height, oldLineFrame.size.width, oldLineFrame.size.height);
    CGRect oldFrame = _identityValidateRootView.frame;
    CGRect newFrame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height + height);
    
    [UIView animateWithDuration:0.2 animations:^{
        _line.frame = newLineFrame;
        _identityValidateRootView.frame = newFrame;
    } completion:^(BOOL finished) {
        
    }];
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"after line's frame = %@", NSStringFromCGRect(_line.frame)]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"after identityValidateRootView frame = %@", NSStringFromCGRect(_identityValidateRootView.frame)]];
}

#pragma mark 定位按钮的点击方法
- (IBAction)location:(id)sender {
    if([self isLocationEnabled]) {
        // 显示定位动画控件
        _locating.hidden = NO;
        // 设置动画图片(有顺序的)
        _locating.animationImages = locatingImages;
        // 设置播放次数
        _locating.animationRepeatCount = 0;
        // 设置动画的持续时间
        _locating.animationDuration = 0.1 * locatingImages.count;
        // 开始动画
        [_locating startAnimating];
        // 将定位按钮设置为不可用状态
        _locationBtn.enabled = NO;
        if (nil == _locationManager) {
            _locationManager = [[CLLocationManager alloc] init];
        }
        
        if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [_locationManager requestAlwaysAuthorization]; // 永久授权
        }
        
        _locationManager.delegate = self;
        // 用来控制定位精度，精度越高耗电量越大，当前设置定位精度为最好的精度
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // 开始定位
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark 定位成功之后回调的委托方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // 获取最新定位的CLLocation对象
    CLLocation *location = [locations lastObject];
    _locationInfo.text = [NSString stringWithFormat:@"纬度：%f 经度：%f, 定位方式为%@", location.coordinate.latitude, location.coordinate.longitude, @"GPS"];
    latitude = [[NSNumber alloc] initWithFloat:location.coordinate.latitude];
    longitude = [[NSNumber alloc] initWithFloat:location.coordinate.longitude];
    // 显示定位信息的UILabel
    _locationInfo.hidden = NO;
    // 停止定位
    [manager stopUpdatingLocation];
    // 显示定位动画控件
    _locating.hidden = YES;
    // 结束动画
    [_locating stopAnimating];
    // 将定位按钮设置回可用状态
    _locationBtn.enabled = YES;
    // 显示定位验证成功的勾勾图片控件
    _locationOKBtn.hidden = NO;
    // 如果之前完成过身份验证，则显示确认按钮
    if (!_cameraOKBtn.isHidden) {
        [self showDoneBtn];
    }
}

#pragma mark 定位失败回调的委托方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // 显示定位动画控件
    _locating.hidden = YES;
    // 结束动画
    [_locating stopAnimating];
    // 如果定位失败，将定位按钮设置回可用状态
    _locationBtn.enabled = YES;
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务不可用" message:LG_LOCATION_ERR delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark 显示确认按钮
- (void)showDoneBtn {
    // 判断之前是否显示过确认按钮，没有则添加，有则不重复添加
    if (!isShowConfirmBtn) {
        [self addNavRightBtnByTitle:@"确认" icon:nil action:@selector(confirm)];
        isShowConfirmBtn = YES;
    }
}

#pragma mark 两个验证都完成之后点击确认按钮触发的事件
- (void)confirm {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [SVProgressHUD showWithStatus:@"身份验证中..."];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [_locationBtn setEnabled:NO];
    [_cameraBtn setEnabled:NO];
    Global((^{
        // 保存验证信息
        // 1.保存定位验证：当前定位的时间及userid、纬度、经度
        NSString *GPS_DATE_CURRENT_USERID = [NSString stringWithFormat:@"%@_%@", GPS_DATE, [AppConfigure objectForKey:USERID]];
        [AppConfigure setValue:[BaseFunction getToday] forKey:GPS_DATE_CURRENT_USERID];
        [AppConfigure setValue:latitude forKey:LATITUDE];
        [AppConfigure setValue:longitude forKey:LONGITUDE];
        // 2.保存身份验证：照片
        NSString *currentDate = [BaseFunction stringFromCurrent];
        // 图片名字按照日期_当前时间戳来拼接，如2015-01-21_1421833859
        NSString *photoName = [NSString stringWithFormat:@"%@_%d", currentDate, [BaseFunction getCurrentTime]];
        NSDictionary *currentDateDictionary = [BaseFunction getCurrentDateDictionary];
        NSArray *dateDirs = [NSArray arrayWithObjects:[currentDateDictionary objectForKey:@"YEAR"], [currentDateDictionary objectForKey:@"MONTH"], [currentDateDictionary objectForKey:@"DAY"], nil];
        NSString *userid = [AppConfigure objectForKey:USERID];
        if (IsStringEmpty(userid) || [@"(null)" isEqualToString:userid]) {
            userid = @"0";
        }
        
        // 要保存的路径文件夹数组
        NSArray *dirArray = [NSArray arrayWithObjects:PATH_OF_DOCUMENT, @"/images", [NSString stringWithFormat:@"/%@", userid], [NSString stringWithFormat:@"/%@", [dateDirs objectAtIndex:0]], [NSString stringWithFormat:@"/%@", [dateDirs objectAtIndex:1]], [NSString stringWithFormat:@"/%@", [dateDirs objectAtIndex:2]], nil];
//        // jpg格式的照片，iPhone5S拍摄的大概3M左右，png格式13M左右
//        NSString *photoPath = [self saveImage:verifyPhoto withFileName:photoName ofType:PHOTO_SAVE_TYPE inDirectoryArray:dirArray];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"photo path is %@", photoPath]];
        
        // 根据照片生成小图
        UIImage *smallPhoto = [BaseFunction scaleImage:verifyPhoto toSize:CGSizeMake(SMALL_PHOTO_SIZE, SMALL_PHOTO_SIZE)];
        // 将小图保存到大图目录下
        NSString *smallPhotoName = [NSString stringWithFormat:@"_SMall%@", photoName];
        NSString *saveSmallPhotoResult = [self saveImage:smallPhoto withFileName:smallPhotoName ofType:PHOTO_SAVE_TYPE inDirectoryArray:dirArray];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"照片小图 path is %@", saveSmallPhotoResult]];
        
        // 压缩照片并保存
        NSString *compressPhotoPath = [NSString stringWithFormat:@"%@/images/%@/%@/%@/%@", PATH_OF_DOCUMENT, userid, [NSString stringWithFormat:@"%@", [dateDirs objectAtIndex:0]], [NSString stringWithFormat:@"%@", [dateDirs objectAtIndex:1]], [NSString stringWithFormat:@"%@", [dateDirs objectAtIndex:2]]];
        BOOL saveRes = [BaseFunction compressImage:verifyPhoto AndSaveToPath:compressPhotoPath SaveFileName:photoName andExtension:PHOTO_SAVE_TYPE];
        [LogUtils Log:TAG content:saveRes ? @"压缩照片保存成功" : @"压缩照片保存失败"];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"照片 compressPhotoPath is %@", compressPhotoPath]];
        
        // 将照片记录保存到本地数据库bo_photo表
        PhotoManager *pm = [[PhotoManager alloc] initWithDb];
        [pm openDB];
        NSString *boPhotoId = [[NSUUID UUID] UUIDString];
        size_t imageSize = CGImageGetBytesPerRow(verifyPhoto.CGImage) * CGImageGetHeight(verifyPhoto.CGImage);
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"boPhotoId = %@", boPhotoId]];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"imageSize = %zu", imageSize]];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"userid = %@", [AppConfigure objectForKey:USERID]]];
        long long fileSize = [BaseFunction fileSizeAtPath:[NSString stringWithFormat:@"%@/%@.jpg", compressPhotoPath, photoName]];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"fileSize = %lld", fileSize]];
        __block BOOL result = [pm insertPhoto:boPhotoId photoName:photoName photoPath:compressPhotoPath boCriticalPointVerId:@"" pointName:@"" boSingleProjectId:@"" boProjectSelectionId:@"" boContentId:@"" filePrefix:photoName fileSuffix:@".jpg" description:@"" memo:@"" longitude:[NSString stringWithFormat:@"%@", longitude] latitude:[NSString stringWithFormat:@"%@", latitude] createDate:[BaseFunction stringFromCurrent] refMineImageId:@"" isFormal:@"" photoType:@"2" isUpload:@"1" photoSize:[NSString stringWithFormat:@"%lld", fileSize] serializeNum:@"" boProblemId:@"" boProblemReplyId:@"" userid:[AppConfigure objectForKey:USERID]];
        [pm closeDB];
        [LogUtils Log:TAG content:result ? @"数据库插入成功" : @"数据库插入失败"];
        [AppConfigure setValue:boPhotoId forKey:MINE_IMAGE_ID];
        Main(^{
            if (result) {
                [self.delegate getLocation:longitude.floatValue latitude:latitude.floatValue];
                [SVProgressHUD showSuccessWithStatus:@"验证通过"];
                // 返回上一个界面
                [self back:nil];
                [LogUtils Log:TAG content:@"Done."];
            } else {
                [SVProgressHUD showErrorWithStatus:@"验证失败"];
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
                [self.navigationItem.leftBarButtonItem setEnabled:YES];
                [_locationBtn setEnabled:YES];
                [_cameraBtn setEnabled:YES];
            }
        });
    }));
}

#pragma mark 保存照片到指定目录，返回保存的路径
-(NSString *) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectoryArray:(NSArray *)directoryArray {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableString *directoryPath = [[NSMutableString alloc] init];
    // 先依次判断文件夹是否存在，不存在则创建
    for (NSString *dir in directoryArray) {
        [directoryPath appendString:dir];
        // Create folder
        if (![fm fileExistsAtPath:directoryPath]) {
            [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"Create Foler: %@ Success.", directoryPath]];
        }
    }
    // 创建好目录之后，保存照片，可以保存PNG格式和JPG格式
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
        [LogUtils Log:TAG content:@"保存图片成功"];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
        [LogUtils Log:TAG content:@"保存图片成功"];
    } else {
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension]];
    }
    
    return directoryPath;
}

- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        verifyPhoto = nil;
        photo.image = nil;
    }];
}

- (BOOL)isLocationEnabled{
    NSString *errorString;
    if (([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return YES;
    }else if(![CLLocationManager locationServicesEnabled]){
        errorString = LG_LOCATION_ERR;
    }else{
        errorString = LG_LOCATION_ERR;
    }
    //[SIAlertView showSIAlertWithTitle:@"定位服务不可用" msg:errorString];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务不可用" message:errorString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
