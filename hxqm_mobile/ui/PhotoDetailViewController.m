//
//  PhotoDetailViewController.m
//  hxqm_mobile
//
//  Created by HelloWorld on 3/6/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "LogUtils.h"
#import "PhotoManager.h"
#import "AppConfigure.h"
#import "CustomIOS7AlertView.h"
#import "PhotoInfoEditAlertView.h"
#import "RegexKitLite.h"
#import "SVProgressHUD.h"
#import "MyMacros.h"
#import "BaseFunction.h"
#import "Constants.h"
#import "GTMNSString+URLArguments.h"

#define TAG @"_PhotoDetailViewController"
#define SET_MEMO_ALERT_TAG 1
#define BACK_ALERT_TAG 2

@interface PhotoDetailViewController () <CustomIOS7AlertViewDelegate, UIScrollViewDelegate> {
    // 保存照片信息
    NSDictionary *photoInfo;
    NSString *userid;
    NSString *oldMemo;
    // 自定义对话框
    CustomIOS7AlertView *customAlertView;
    PhotoInfoEditAlertView *infoEditView;
    CGSize photoSize;
    UIImage *photo;
    BOOL isDoodling;
    BOOL isRotate;
    UIImage *undoAble;
    UIImage *undoDisable;
    UIImage *redoAble;
    UIImage *redoDisable;
    float photoWidth;
    float photoHeight;
    NSString *doodleImagePath;
}

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD dismiss];
    // Do any additional setup after loading the view from its nib.
    [self addNavBackBtn:@"返回"];
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_filePath = %@", _filePath]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_photoId = %@", _photoId]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_type = %@", _type]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_mode = %@", _mode]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_isDoodle = %@", _isDoodle]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_projectName = %@", _projectName]];
    
    photo = [UIImage imageWithContentsOfFile:_filePath];
    photoSize = photo.size;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoSize.width = %f, photoSize.height = %f", photoSize.width, photoSize.height]];
    
    // 初始化隐藏撤销和再做view
    _undoAndRedoView.hidden = YES;
    // 照片查看
    if ([MODE_SCAN isEqualToString:_mode]) {
        [_doodleBtn setHidden:YES];
    }
    
    if ((int) photoSize.width <= 0 || (int) photoSize.height <= 0) {
        [SVProgressHUD showErrorWithStatus:@"照片读取出错，请返回重试"];
        [_editInfoBtn setEnabled:NO];
        [_doodleBtn setEnabled:NO];
        return;
    }
    
    _photoView.tag = 2;
    
    // 如果图片的宽大于高，转置显示
    if (photoSize.width > photoSize.height) {
        _photoView.image = [UIImage imageWithCGImage:photo.CGImage scale:1.0 orientation:UIImageOrientationRight];
        isRotate = YES;
    } else {
        _photoView.image = photo;
        isRotate = NO;
    }
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photo.image.width = %f, photo.image.height = %f", _photoView.image.size.width, _photoView.image.size.height]];
//    float photoWidthScale = _scrollView.frame.size.width / (_photoView.image.size.width);//  + 40);
//    float photoHeightScale = _scrollView.frame.size.height / (_photoView.image.size.height);//  + 40);
//    if (photoWidthScale < photoHeightScale) {
//        photoWidth = _photoView.image.size.width * photoWidthScale;
//        photoHeight = _photoView.image.size.height * photoWidthScale;
//    } else {
//        photoWidth = _photoView.image.size.width * photoHeightScale;
//        photoHeight = _photoView.image.size.height * photoHeightScale;
//    }
    
    photoWidth = UI_SCREEN_WIDTH;// self.view.frame.size.width;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"UI_SCREEN_WIDTH = %f", UI_SCREEN_WIDTH]];
    float photoWidthScale = photoWidth / _photoView.image.size.width;
    photoHeight = _photoView.image.size.height * photoWidthScale;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoWidth = %f, photoHeight = %f", photoWidth, photoHeight]];
    float photoHeightScale = photoWidthScale;// photoHeight / _photoView.image.size.height;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoWidthScale = %f, photoHeightScale = %f", photoWidthScale, photoHeightScale]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_scrollView.frame.size.width = %f, _scrollView.frame.size.height = %f", _scrollView.frame.size.width, _scrollView.frame.size.height]];
    
    userid = [AppConfigure objectForKey:USERID];
    
    _doodleView.delegate = self;
    _doodleView.userInteractionEnabled = NO;
    _scaleRootView.frame = CGRectMake(0, 0, photoWidth, photoHeight);
    
    if ([@"1" isEqualToString:_isDoodle]) {
        _oldDoodlePathImg.frame = CGRectMake(0, 0, photoWidth, photoHeight);
        doodleImagePath = [NSString stringWithFormat:@"%@/%@.png", [BaseFunction getDoodlePicSystemFolderPath], _photoId];
        _oldDoodlePathImg.image = [UIImage imageWithContentsOfFile:doodleImagePath];
    } else {
        [_oldDoodlePathImg setHidden:YES];
    }
    
//    [_scrollView setContentInset:UIEdgeInsetsMake(20, 20, 20, 20)];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_scaleRootView.frame.size.width = %f, _scaleRootView.frame.size.height = %f", _scaleRootView.frame.size.width, _scaleRootView.frame.size.height]];
    
    // 去掉水平、垂直方向上的滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    [_scrollView addSubview:_scaleRootView];
    
    // 设置scorll的代理对象
    _scrollView.delegate = self;
    // 设置最大的缩放比
    _scrollView.maximumZoomScale = 1.7;
    float minPhotoScale = photoWidthScale > photoHeightScale ? photoWidthScale : photoHeightScale;
    float minZoomScale = minPhotoScale < 0.75 ? 0.75 : (1.0 - minPhotoScale);
    // 设置最小的缩放比
    _scrollView.minimumZoomScale = minZoomScale;
//    _scrollView.zoomScale = minZoomScale;
    _scrollView.delaysContentTouches = NO;
    
    _scrollView.contentSize = _scaleRootView.frame.size;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_scrollView.contentSize.width = %f, _scrollView.contentSize.height = %f", _scrollView.contentSize.width, _scrollView.contentSize.height]];
    
    undoAble = [UIImage imageNamed:@"icon_undo_light.png"];
    undoDisable = [UIImage imageNamed:@"icon_undo_gray.png"];
    redoAble = [UIImage imageNamed:@"icon_redo_light.png"];
    redoDisable = [UIImage imageNamed:@"icon_redo_gray.png"];
    
    [self createDoodleAndMergeFolder];
}

- (void)viewDidLayoutSubviews {
    _doodleView.frame = CGRectMake(0, 0, photoWidth, photoHeight);
    _photoView.frame = CGRectMake(0, 0, photoWidth, photoHeight);
    _oldDoodlePathImg.frame = CGRectMake(0, 0, photoWidth, photoHeight);
}

#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _scaleRootView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

#pragma mark 点击编辑按钮
- (IBAction)editInfoBtnClick:(UIButton *)sender {
    // 获得照片详细信息
    PhotoManager *photoManager = [[PhotoManager alloc] initWithDb];
    [photoManager openDB];
    photoInfo = [photoManager getPhotoInfoById:_photoId userid:userid];
    [photoManager closeDB];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoInfo = %@", photoInfo]];
    
    NSString *memo = [photoInfo objectForKey:@"memo"];
    if ([@"null" isEqualToString:memo] || [@"(null)" isEqualToString:memo] || memo == nil) {
        memo = @"";
    }
    oldMemo = memo;
    
    if ([@"1" isEqualToString:_type]) {
        // 展示编辑框（如图），填充信息，正式/临时：Map.get("IS_FORMAL"),1为正式，2为临时照片名称：Map.get("PHOTO_NAME")若值为空，则显示背景文字：命名规范：+ Map.get("PHOTO_NAME_RULE")备注：Map.get("MEMO")，若值为空，显示背景文字：备注
        
        //初始化弹出框
        infoEditView = [[PhotoInfoEditAlertView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH - 40, 168) isFormal:[photoInfo objectForKey:@"is_formal"] photoName:[photoInfo objectForKey:@"photo_name"] photoNameRule:[photoInfo objectForKey:@"photo_name_rule"] memo:memo projectName:_projectName contentName:_contentName];
        customAlertView = [[CustomIOS7AlertView alloc] init];
        
        [customAlertView setContainerView:infoEditView];
        if ([@"2" isEqualToString:_mode]) {
            [customAlertView setButtonTitles:[NSMutableArray arrayWithObjects:@"确定", nil]];
            [infoEditView setInputDisable:YES];
        } else {
            [customAlertView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"确定", nil]];
            [infoEditView setInputDisable:NO];
        }
        [customAlertView setDelegate:self];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(photoInfo) weakPhotoInfo = photoInfo;
        __weak typeof(infoEditView) weakInfoEditView = infoEditView;
        
        // You may use a Block, rather than a delegate.
        [customAlertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
            if (buttonIndex == 1) {// 确定
                NSDictionary *datas = [weakInfoEditView getAlertViewDatas];
                NSString *photoName = [datas objectForKey:@"photo_name"];
                // 验证照片名称是否符合命名规则
                NSString *photoNameRegex = [weakPhotoInfo objectForKey:@"photo_name_regex"];
                if ([@"*" isEqualToString:photoNameRegex]) {
                    photoNameRegex = @".*";
                }
                [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoName = %@, photoNameRegex = %@", photoName, photoNameRegex]];
                BOOL regexResult = [photoName isMatchedByRegex:photoNameRegex];// [BaseFunction string:photoName MatchRegex:photoNameRegex];
                [LogUtils Log:TAG content:[NSString stringWithFormat:@"regexResult：%@", regexResult ? @"YES" : @"NO"]];
//                [LogUtils Log:TAG content:[NSString stringWithFormat:@"regexRange = %@, [photoName length] = %ld", NSStringFromRange(regexRange), [photoName length]]];
                if (!regexResult) {
                    [SVProgressHUD showErrorWithStatus:@"照片名称不符合规范"];
                }
                // 未填photoName，则为空值
                [alertView close];
                [weakSelf dealAlertViewDatas:datas];
            } else {
                [alertView close];
            }
        }];
        
        [customAlertView setUseMotionEffects:true];
        
        [customAlertView showHasButtons];
    } else {
        if ([@"2" isEqualToString:_type] || [@"3" isEqualToString:_type]) {
            // 展示编辑框（如图），填充信息，备注：Map.get("MEMO")，若值为空，显示背景文字：备注；隐藏字段{Map.get("IS_FORMAL")}
            UIAlertView *addAlert = [[UIAlertView alloc] initWithTitle:@"照片详细信息" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [addAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *textField = [addAlert textFieldAtIndex:0];
            textField.text = memo;
            textField.placeholder = @"备注";
            addAlert.tag = SET_MEMO_ALERT_TAG;
            [addAlert show];
        }
    }
}

#pragma mark 点击涂鸦按钮
- (IBAction)doodleBtnClick:(UIButton *)sender {
    if (!isDoodling) {
        NSLog(@"start doodling");
        isDoodling = YES;
        [self addNavBarBtns];
        _doodleView.userInteractionEnabled = YES;
    }
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_doodleView.userInteractionEnabled  = %@", _doodleView.isUserInteractionEnabled ? @"YES" : @"NO"]];
}

#pragma mark AlertView按钮点击回调事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == BACK_ALERT_TAG) {
        //尚未保存，选择是保存并返回，选择否放弃修改
        if(buttonIndex == 0) {
            //保存涂鸦后返回
            [self saveDoodleResult:YES];
        } else {
            _photoView.image = nil;
            _oldDoodlePathImg.image = nil;
            [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
        }
    } else{
        NSLog(@"show alert tag = %ld", alertView.tag);
        NSLog(@"buttonIndex = %ld", buttonIndex);
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *memoString = textField.text;
        NSLog(@"memoString = %@", memoString);
        if (SET_MEMO_ALERT_TAG == alertView.tag) {
            if (1 == buttonIndex) {
                NSLog(@"确定");
                if (![oldMemo isEqualToString:memoString]) {
                    [self updateDataBaseWithMemo:memoString isFormal:@"" photoName:@""];
                }
            }
        }
    }
    
}

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (void)dealAlertViewDatas:(NSDictionary *)datas {
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"datas = %@", datas]];
    NSString *selectedIndex = [datas objectForKey:@"selected_index"];
    NSString *photoName = [datas objectForKey:@"photo_name"];
    NSString *memo = [datas objectForKey:@"memo"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"selectedIndex = %@", selectedIndex]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoName = %@", photoName]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"memo = %@", memo]];
    NSString *isFormal = [NSString stringWithFormat:@"%d", [selectedIndex intValue] + 1];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"isFormal = %@", isFormal]];
    
    [self updateDataBaseWithMemo:memo isFormal:isFormal photoName:photoName];
}

#pragma mark 更新数据库
- (BOOL)updateDataBaseWithMemo:(NSString *)memo isFormal:(NSString *)isFormal photoName:(NSString *)photoName {
    PhotoManager *photoManager = [[PhotoManager alloc] initWithDb];
    [photoManager openDB];
    BOOL updateResult;
    if ([@"1" isEqualToString:_type]) {
        updateResult = [photoManager updatePhotoMemo:_photoId memo:memo quality:@"" isFormal:isFormal photoName:photoName userid:userid];
    } else if ([@"2" isEqualToString:_type] || [@"3" isEqualToString:_type]) {
        updateResult = [photoManager updateMemoByPhotoId:_photoId memo:memo userid:userid];
    }
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"数据库更新：%@", updateResult ? @"成功" : @"失败"]];
    [photoManager closeDB];
    
    return updateResult;
}

#pragma mark 添加导航栏按钮
- (void)addNavBarBtns {
    // 设置导航栏按钮的点击执行方法等
    UIImage *saveImage = [UIImage imageNamed:@"icon_save.png"];
    UIImage *exitImage = [UIImage imageNamed:@"icon_exit.png"];
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithImage:saveImage style:UIBarButtonItemStylePlain target:self action:@selector(saveDoodleResult:)];
    saveItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *exitItem = [[UIBarButtonItem alloc] initWithImage:exitImage style:UIBarButtonItemStylePlain target:self action:@selector(exitDoodle)];
    exitItem.tintColor = [UIColor whiteColor];
    NSArray *actionButtonItems = @[saveItem, exitItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    _undoAndRedoView.hidden = NO;
}

#pragma mark 删除导航栏右侧的按钮
- (void)removeNavBtns {
    self.navigationItem.rightBarButtonItems = nil;
    _undoAndRedoView.hidden = YES;
}

// undo
- (IBAction)undoBtnClick:(UIButton *)sender {
    [_doodleView undo];
}

// redo
- (IBAction)redoBtnClick:(UIButton *)sender {
    [_doodleView redo];
}

#pragma mark DoodleView Delegate
- (void)currentDrawLinesCount:(NSInteger)drawLinesCount clearLinesCount:(NSInteger)clearLinesCount {
    if (drawLinesCount > 0) {
        [_undoBtn setBackgroundImage:undoAble forState:UIControlStateNormal];
        [_undoBtn setEnabled:YES];
    } else {
        [_undoBtn setBackgroundImage:undoDisable forState:UIControlStateNormal];
        [_undoBtn setEnabled:NO];
    }
    
    if (clearLinesCount > 0) {
        [_redoBtn setBackgroundImage:redoAble forState:UIControlStateNormal];
        [_redoBtn setEnabled:YES];
    } else {
        [_redoBtn setBackgroundImage:redoDisable forState:UIControlStateNormal];
        [_redoBtn setEnabled:NO];
    }
}

#pragma mark - 导航栏按钮点击方法
/**
 *  保存涂鸦
 *
 *  @param exiting 为yes时表示在可涂鸦状态下用户选择保存涂鸦退出的标记，为no时表示拥护点击保存涂鸦
 */
- (void)saveDoodleResult : (BOOL) exiting {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"%@", NSStringFromSelector(_cmd)]];
    [self setSaveStatus:YES];
    [SVProgressHUD showWithStatus:@"正在保存中..."];
    _doodleView.userInteractionEnabled = NO;

    Global((^{
        // 先根据照片的尺寸和是否旋转保存涂鸦，然后将涂鸦图片与照片合成
        UIImage *doodleImage = [self getDoodleImage];
        
        NSString *doodlePicFolderPath = [BaseFunction getDoodlePicSystemFolderPath];
        NSString *mergedPicFolderPath = [BaseFunction getMergedPicSystemFolderPath];
        
        BOOL saveDoodleImageResult = [BaseFunction saveImage:doodleImage toPath:doodlePicFolderPath withName:_photoId andExtension:@"png"];
        // 压缩涂鸦轨迹图片并保存
//        BOOL saveDoodleImageResult = [BaseFunction compressImage:doodleImage AndSaveToPath:doodlePicFolderPath SaveFileName:_photoId andExtension:@"png"];
        [LogUtils Log:TAG content:saveDoodleImageResult ? @"压缩涂鸦图片保存成功" : @"压缩涂鸦图片保存失败"];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"doodlePicFolderPath is %@", doodlePicFolderPath]];
        
        // 合成
        UIImage *compoundImage = [BaseFunction compoundImageWithPhoto:photo andDoodle:doodleImage];
        // 根据合成照片生成小图
        UIImage *smallCompoundImage = [BaseFunction scaleImage:compoundImage toSize:CGSizeMake(SMALL_PHOTO_SIZE, SMALL_PHOTO_SIZE)];
        
        BOOL saveCompoundImageResult = [BaseFunction saveImage:smallCompoundImage toPath:mergedPicFolderPath withName:[NSString stringWithFormat:@"%@", _photoId] andExtension:@"jpg"];
        NSLog(@"保存合成图片：%@, mergedPicFolderPath = %@", saveCompoundImageResult ? @"成功" : @"失败", mergedPicFolderPath);
        
        // 保存成功，则更新数据库
        if (saveDoodleImageResult && saveCompoundImageResult) {
            PhotoManager *photoManager = [[PhotoManager alloc] initWithDb];
            [photoManager openDB];
            BOOL updateResult = [photoManager updataPhotoDoodleStatus:_photoId status:@"1" userid:userid];
            [photoManager closeDB];
            NSLog(@"更新数据库：%@", updateResult ? @"成功" : @"失败");
        }
        
        doodleImage = nil;
        compoundImage = nil;
        smallCompoundImage = nil;
        
        Main((^{
            [SVProgressHUD dismiss];
            if (saveDoodleImageResult && saveCompoundImageResult) {
                [SVProgressHUD showSuccessWithStatus:@"保存成功"];
                
                doodleImagePath = [NSString stringWithFormat:@"%@/%@.png", doodlePicFolderPath, _photoId];
                [LogUtils Log:TAG content:[NSString stringWithFormat:@"doodleImagePath = %@", doodleImagePath]];
                [_oldDoodlePathImg setHidden:NO];
                _oldDoodlePathImg.image = [UIImage imageWithContentsOfFile:doodleImagePath];
                
                [self exitDoodle];
            } else {
                [SVProgressHUD showErrorWithStatus:@"涂鸦与照片合成失败"];
                _doodleView.userInteractionEnabled = YES;
            }
            [self setSaveStatus:NO];
            
            if(exiting) {
                _photoView.image = nil;
                _oldDoodlePathImg.image = nil;
                [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
            }
        }));
    }));
}

/**
 *  退出涂鸦模式
 */
- (void)exitDoodle {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"%@", NSStringFromSelector(_cmd)]];
    [self removeNavBtns];
    _doodleView.userInteractionEnabled = NO;
    [_doodleView clearAllLines];
    isDoodling = NO;
}

/**
 *  根据照片的尺寸获取涂鸦图片
 *
 *  @return 涂鸦轨迹图片
 */
- (UIImage *)getDoodleImage {
    CGSize doodleSize;
    if (isRotate) {
        doodleSize = CGSizeMake(photoSize.height, photoSize.width);
    } else {
        doodleSize = photoSize;
    }
    // 先根据_doodleView的原始大小获取涂鸦图片，然后缩放为照片的大小
    UIGraphicsBeginImageContext(_doodleView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_doodleView.layer renderInContext:context];
    UIImage *doodleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    doodleImage = [BaseFunction scaleImage:doodleImage toSize:doodleSize];
    
    // 如果照片是旋转之后显示的，要将涂鸦图片旋转回来
    if (isRotate) {
        doodleImage = [UIImage imageWithCGImage:doodleImage.CGImage scale:1.0 orientation:UIImageOrientationLeft];
    }
    
    return doodleImage;
}

/**
 *  设置当前界面的状态
 *
 *  @param isSaving 是否为保存状态
 */
- (void)setSaveStatus:(BOOL)isSaving {
    [self.navigationItem.leftBarButtonItem setEnabled:!isSaving];
    for (UIBarButtonItem *item in self.navigationItem.rightBarButtonItems) {
        [item setEnabled:!isSaving];
    }
    [_editInfoBtn setEnabled:!isSaving];
    [_doodleBtn setEnabled:!isSaving];
    [_undoBtn setEnabled:!isSaving];
    [_redoBtn setEnabled:!isSaving];
    [_undoAndRedoView setHidden:!isSaving];
}

/**
 *  判断保存涂鸦和合成照片的文件夹是否存在，不存在则创建
 */
- (void)createDoodleAndMergeFolder {
    NSString *doodlePicFolderPath = [BaseFunction getDoodlePicSystemFolderPath];
    NSString *mergedPicFolderPath = [BaseFunction getMergedPicSystemFolderPath];
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"doodlePicFolderPath = %@", doodlePicFolderPath]];
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"mergedPicFolderPath = %@", mergedPicFolderPath]];
    NSFileManager *fm = [NSFileManager defaultManager];
    // Create folder
    if (![fm fileExistsAtPath:doodlePicFolderPath]) {
        BOOL result = [fm createDirectoryAtPath:doodlePicFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"Create Foler: %@ %@.", doodlePicFolderPath, result ? @"Success" : @"Failed"]];
    }
    
    if (![fm fileExistsAtPath:mergedPicFolderPath]) {
        BOOL result = [fm createDirectoryAtPath:mergedPicFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"Create Foler: %@ %@.", doodlePicFolderPath, result ? @"Success" : @"Failed"]];
    }
}

#pragma mark -
#pragma mark 点击返回按钮
- (void)back:(id)sender {
    if(isDoodling) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"尚未保存，选择“是”保存并返回，选择“否”放弃修改" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        alert.tag = BACK_ALERT_TAG;
        [alert show];
        return;
    }
    
    _photoView.image = nil;
    _oldDoodlePathImg.image = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
