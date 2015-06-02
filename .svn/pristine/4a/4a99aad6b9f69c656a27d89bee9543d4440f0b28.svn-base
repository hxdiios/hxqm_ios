//
//  DetailCell.m
//  hxqm_mobile
//
//  Created by HelloWorld on 2/28/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "DetailCell.h"
#import "LogUtils.h"
#import "PhotoManager.h"
#import "TemplateManager.h"
#import "GTMNSString+URLArguments.h"
#import "UIImageView+WebCache.h"
#import "ContentManager.h"
#import "BaseFunction.h"
#import "MyMacros.h"
#import "SDWebImageDownloader.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "Haneke.h"

#define TAG @"_DetailCell"
#define DELETE_PHOTO_ALERT_TAG 1
#define EDGEINSETS 10
#define PHOTO_LOAD @"photo_load"
// 从服务端下载照片
#define IS_SERVER_PHOTO @"server"
// 从本地获取照片
#define IS_NATIVE_PHOTO @"native"
#define IS_PHOTO_EXIST @"photo_exist"
// 本地存在照片的小图
#define PHOTO_EXIST @"exist"
// 本地不存在照片的小图
#define PHOTO_NOT_EXIST @"not_exist"

@interface DetailCell () {
    // 当前行的下标
    NSInteger currentRow;
    NSString *currentCriticalPointVerId;
    NSString *contentId;
    NSString *userid;
    // 记录当前长按的照片信息
    NSDictionary *longPressedToDeletePhotoRecord;
    // 记录当前长按的照片行下标
    NSInteger longPressedToDeletePhotoRow;
    // 照片展示item的宽度，高度和宽度一致
    float photoItemWidthAndHeight;
    UIImage *downloadingImage;
//    UIImage *errorImage;
    NSFileManager *fileManager;
    NSString *qmFolderPath;
    NSString *downloadFailedImgPath;
    NSString *errorImgPath;
    SDWebImageDownloader *imageDownloader;
    PhotoManager *smallPhotoManager;
    TemplateManager *templateManager;
}

@end

@implementation DetailCell

static NSString * CellIdentifier = @"PhotoCell";

static BOOL isDownloading = NO;

- (void)initViewWithData:(NSDictionary *)data AtRow:(NSInteger)row {
    _detailData = data;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"data = %@, row = %ld", data, row]];
//    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_isLocated = %@", _isLocated]];
    currentRow = row;
    NSString *criticalPointVerId = [data objectForKey:@"bo_critical_point_ver_id"];
    currentCriticalPointVerId = criticalPointVerId;
    // 设置标题
    NSString *title = [data objectForKey:@"point_name"];
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange range = [title rangeOfString:@"*"];
    [titleString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    _titleLabel.attributedText = titleString;
    
    _photosCollectionView.delegate = self;
    _photosCollectionView.dataSource = self;
    //隐藏照片示例按钮
    NSString *counts = [data objectForKey:@"counts"];
    if([counts isEqualToString:@"0"]){
        _instanceBtn.hidden = YES;
    }else{
        _instanceBtn.hidden = NO;
    }
    // 在ViewDidLoad方法中声明Cell的类，在ViewDidLoad方法中添加，此句不声明，将无法加载，程序崩溃
    [_photosCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    smallPhotoManager = [[PhotoManager alloc] initWithDb:_db];
    
//    PhotoManager *photoManager = [[PhotoManager alloc] initWithDb:_db];
    contentId = [data objectForKey:@"bo_content_id"];
    userid = [data objectForKey:@"userid"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"criticalPointVerId = %@, contentId = %@, userid = %@", criticalPointVerId, contentId, userid]];
    
    _photosArray = [smallPhotoManager getPhotoListByPointId:criticalPointVerId boContentId:contentId userid:userid];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"before photosArray = %@", _photosArray]];
    
    qmFolderPath = [BaseFunction getQMSystemFolderPath];
    
    // 遍历照片list
    for (NSMutableDictionary *photo in _photosArray) {
        NSString *filePath = [photo objectForKey:@"file_path"];
        // List中的FILE_PATH包含Constants.SYSTEM_FOLDER_PATH
        if ([filePath myContainsString:@"/qm/"]) {
            NSString *isDownload = [photo objectForKey:@"is_download"];
            // List中的IS_DOWNLOAD是否等于2
            if ([@"2" isEqualToString:isDownload]) {
#warning 拍完照片之后会生成小图保存到qm下，避免使用原图显示，所以这里不用替换_SMall
                // 将List中的FILE_PATH的"_SMall"替换成""（在sql中默认拼了小图前缀，对于本地照片需要替换成空）
//                filePath = [filePath stringByReplacingOccurrencesOfString:@"_SMall" withString:@""];
//                [photo setObject:filePath forKey:@"file_path"];
            }
            NSLog(@"-----------native");
            // 根据List中的FILE_PATH从本地取得照片，若照片不存在手机本地，则使用资源不存在图片
            [photo setObject:IS_NATIVE_PHOTO forKey:PHOTO_LOAD];
        } else {
            NSLog(@"-----------server");
            // 根据List中的FILE_PATH从服务端下载小图
            [photo setObject:IS_SERVER_PHOTO forKey:PHOTO_LOAD];
        }
    }
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"after for() photosArray = %@", _photosArray]];
    
    // 给collectionView添加长按手势
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(photoLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1;
    [_photosCollectionView addGestureRecognizer:longPressGestureRecognizer];
    [_photosCollectionView setScrollEnabled:NO];
    
    // 计算照片的宽高
    photoItemWidthAndHeight = (UI_SCREEN_WIDTH - 50) / 4.0f;
    NSString *downloadImgPath = [[NSBundle mainBundle] pathForResource:@"icon_downloading" ofType:@"png"];
    downloadingImage = [UIImage imageWithContentsOfFile:downloadImgPath];// [UIImage imageNamed:@"icon_downloading.png"];
//  errorImage = [UIImage imageNamed:@"icon_error.png"];
    fileManager = [NSFileManager defaultManager];
    imageDownloader = [[SDWebImageDownloader alloc] init];
//    smallPhotoManager = [[PhotoManager alloc] initWithDb:_db];
    downloadFailedImgPath = [[NSBundle mainBundle] pathForResource:@"icon_download_failed" ofType:@"png"];
    errorImgPath = [[NSBundle mainBundle] pathForResource:@"icon_error" ofType:@"png"];
    [_photosCollectionView reloadData];
}

#pragma mark -
- (IBAction)cameraBtnClick:(UIButton *)sender {
    NSLog(@"%@, currentRow = %ld", NSStringFromSelector(_cmd), currentRow);
    if ([@"NO" isEqualToString:_isLocated]) {
//        [LogUtils Log:TAG content:@"is not locate"];
        return;
    }
    if ([_delegate respondsToSelector:@selector(clickCameraWithCurrentRow:)]) {
        [_delegate clickCameraWithCurrentRow:currentRow];
    }
}

- (IBAction)instanceBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(clickInstanceBtn:)]) {
        NSMutableArray *instanceImagesArray = [NSMutableArray arrayWithCapacity:10];
        templateManager = [[TemplateManager alloc] initWithDb:_db];
        NSMutableArray *instanceInfoArray = [templateManager getInstanceImageByPortId:currentCriticalPointVerId];
        for(NSMutableDictionary *instanceInfo in instanceInfoArray){
            NSString *instanceImageName = [instanceInfo objectForKey:@"photo_path"];
            UIImage *img = [UIImage imageNamed:instanceImageName];
            if(img != nil){
                [instanceImagesArray addObject:img];
            }else{
                [instanceImagesArray addObject:[[UIImage alloc]init]];
            }
        }
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"instanceImagesArray = %@", instanceImagesArray]];
        [_delegate clickInstanceBtn:instanceImagesArray];
    }
}

#pragma mark - UICollectionView Delegate
// 每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"collectionView cellForItemAtIndexPath indexPath.row = %ld", indexPath.row]];
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSLog(@"photo cell is nil");
        cell = [[UICollectionViewCell alloc] init];
    }

    NSMutableDictionary *photoDict = [_photosArray objectAtIndex:indexPath.row];
    NSString *filePath = [photoDict objectForKey:@"file_path"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"filePath = %@", filePath]];
    NSString *ServerOrNative = [photoDict objectForKey:PHOTO_LOAD];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"ServerOrNative = %@", ServerOrNative]];
    UIImageView *photo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, photoItemWidthAndHeight, photoItemWidthAndHeight)];
    NSString *fileFullName = [BaseFunction splitFileNameForPath:filePath];
    NSString *photoSuffix = [[fileFullName componentsSeparatedByString:@"."] lastObject];
    // 将照片大图的后缀替换为小写......避免大小写的原因找不到文件...-_-!!!
    fileFullName = [fileFullName stringByReplacingOccurrencesOfString:photoSuffix withString:[photoSuffix lowercaseString]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"fileFullName = %@", fileFullName]];
    
    if ([IS_SERVER_PHOTO isEqualToString:ServerOrNative]) {// 从服务器上下载
        NSURL *photoURL = [NSURL URLWithString:filePath];// @"http://www.ffpic.com/files/png/0307black/ffpic13061257102812.png"];
        [photo sd_setImageWithURL:photoURL placeholderImage:downloadingImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"error = %@", error]];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"imageURL = %@", imageURL]];
            if (image != nil && error == nil) {
                photo.image = image;
                // filePath = http://183.129.199.99:19080/imagedir/image/2014/09/10//_SMall6741410338367916.jpg
                
                NSString *fileName = [[fileFullName componentsSeparatedByString:@"."] objectAtIndex:0];
                [LogUtils Log:TAG content:[NSString stringWithFormat:@"fileName = %@", fileName]];
                // 将下载下来的照片小图保存到qm目录下面
                BOOL savePhotoResult = [BaseFunction saveImage:image toPath:qmFolderPath withName:fileName andExtension:[[fileFullName componentsSeparatedByString:@"."] lastObject]];
                [LogUtils Log:TAG content:[NSString stringWithFormat:@"照片小图: %@, 保存%@", fileName, savePhotoResult ? @"成功" : @"失败"]];
                if (savePhotoResult) {
                    [photoDict setObject:PHOTO_EXIST forKey:IS_PHOTO_EXIST];
                    [LogUtils Log:TAG content:@"photoDict set IS_PHOTO_EXIST to PHOTO_EXIST"];
//                    [smallPhotoManager openDB];
                    // 保存小图后，更新bo_photo表，PhotoManager.updateImageDir(Constants.SYSTEM_FOLDER_PATH, 对应list中的BO_PHOTO_ID)
                    BOOL updateImageDirResult = [smallPhotoManager updateImageDir:qmFolderPath boPhotoId:[photoDict objectForKey:@"bo_photo_id"] userid:userid];
                    [LogUtils Log:TAG content:[NSString stringWithFormat:@"更新bo_photo表: %@", updateImageDirResult ? @"成功" : @"失败"]];
                } else {
                    [photoDict setObject:PHOTO_NOT_EXIST forKey:IS_PHOTO_EXIST];
                    [LogUtils Log:TAG content:@"photoDict set IS_PHOTO_EXIST to PHOTO_NOT_EXIST"];
                }
            } else {
                [LogUtils Log:TAG content:@"照片小图下载失败..."];
                [photoDict setObject:PHOTO_NOT_EXIST forKey:IS_PHOTO_EXIST];
                [photo hnk_setImageFromFile:downloadFailedImgPath];
//                photo.image = [UIImage imageWithContentsOfFile:downloadFailedImgPath];
            }
            
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoDict = %@", photoDict]];
        }];
    } else {// 从本地获取
        // 将//替换为/
        filePath = [NSString stringWithFormat:@"%@/%@", qmFolderPath, fileFullName];
        // 判断是否已经涂鸦，是则显示合成小图，否则显示照片小图
        if ([@"1" isEqualToString:[photoDict objectForKey:@"is_doodled"]]) {
            filePath = [NSString stringWithFormat:@"%@/%@", [BaseFunction getMergedPicSystemFolderPath], fileFullName];
        }
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"-----filePath = %@", filePath]];
        
        if ([fileManager fileExistsAtPath:filePath]) {// 本地存在照片
            [LogUtils Log:TAG content:@"本地存在照片"];
            [photo hnk_setImageFromFile:filePath];
//            UIImage *nativePhoto = [UIImage imageWithContentsOfFile:filePath];
//            photo.image = nativePhoto;
            [photoDict setObject:PHOTO_EXIST forKey:IS_PHOTO_EXIST];
        } else {// 本地不存在照片，显示资源不存在图片
            [LogUtils Log:TAG content:@"本地不存在照片"];
            [photo hnk_setImageFromFile:errorImgPath];
//            photo.image = errorImage;
            [photoDict setObject:PHOTO_NOT_EXIST forKey:IS_PHOTO_EXIST];
        }
    }
    
//    if (indexPath.row == _photosArray.count - 1) {
//        [LogUtils Log:TAG content:@"smallPhotoManager closeDB"];
//        [LogUtils Log:TAG content:[NSString stringWithFormat:@"_photosArray = %@", _photosArray]];
//    }

    for (UIView *subView in [cell.contentView subviews]) {
        [subView removeFromSuperview];
    }
    
    [cell.contentView addSubview:photo];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"indexPath.section = %ld, indexPath.row = %ld", indexPath.section, indexPath.row]];
    if (isDownloading) {
        [LogUtils Log:TAG content:@"isDownloading..."];
        return;
    } else {
        NSMutableDictionary *photoDict = [_photosArray objectAtIndex:indexPath.row];
        //    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoDict = %@", photoDict]];
        NSString *photoExistStatus = [photoDict objectForKey:IS_PHOTO_EXIST];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoExistStatus = %@", photoExistStatus]];
        NSString *isDownload = [photoDict objectForKey:@"is_download"];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"isDownload = %@", isDownload]];
        NSString *isDoodled = [photoDict objectForKey:@"is_doodled"];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"isDoodled = %@", isDoodled]];
        
        PhotoManager *photoManager = [[PhotoManager alloc] initWithDb:_db];
        NSDictionary *photoInfo = [photoManager getProjectInfoByPhotoId:[photoDict objectForKey:@"bo_photo_id"] userid:userid];
        [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoInfo = %@", photoInfo]];
        NSString *isUpload = [photoInfo objectForKey:@"is_upload"];
        NSString *projectName = [photoInfo objectForKey:@"project_name"];
        // 判断图片是否存在
        if ([PHOTO_EXIST isEqualToString:photoExistStatus]) {
            // 拼装大图的本地路径
            NSString *fileFullName = [BaseFunction splitFileNameForPath:[photoDict objectForKey:@"download_url"]];
            NSString *photoSuffix = [[fileFullName componentsSeparatedByString:@"."] lastObject];
            // 将照片大图的后缀替换为小写......避免大小写的原因找不到文件...-_-!!!
            fileFullName = [fileFullName stringByReplacingOccurrencesOfString:photoSuffix withString:[photoSuffix lowercaseString]];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"fileFullName = %@", fileFullName]];
            NSString *fileName = [[fileFullName componentsSeparatedByString:@"."] objectAtIndex:0];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"fileName = %@", fileName]];
            NSString *bigPhotoPath = [NSString stringWithFormat:@"%@/%@", qmFolderPath, fileFullName];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"bigPhotoPath = %@", bigPhotoPath]];
            
            // 是否下载图片（图片隐藏属性中的IS_DOWNLOAD等于1）
            if ([@"1" isEqualToString:isDownload]) {
                // 大图是否已经下载到本地
                if ([fileManager fileExistsAtPath:bigPhotoPath]) {
                    [LogUtils Log:TAG content:@"本地已经存在大图"];
                    // 进入图片查看页面PhotoScanActivity，参数{filepath：手机本地照片路径, photoId：照片隐藏属性中的的照片ID, type：控制点信息Map.get("CONTENT_TYPE")}
                    [self jumpToPhotoDetailWithFilePath:bigPhotoPath photoId:[photoDict objectForKey:@"bo_photo_id"] type:[_detailData objectForKey:@"content_type"] mode:MODE_SCAN isDoodled:isDoodled projectName:projectName];
                } else {
                    //                NSString *imageUrl = @"http://b.hiphotos.baidu.com/image/pic/item/d788d43f8794a4c20c018f5e0df41bd5ad6e39a0.jpg";
                    //                NSString *imageUrl2 = @"http://mg.soupingguo.com/bizhi/big/10/231/895/10231895.jpg";
                    NSString *downloadUrl = [photoDict objectForKey:@"download_url"];
                    NSURL *photoURL = [NSURL URLWithString:downloadUrl];// indexPath.row % 2 == 0 ? imageUrl : imageUrl2];
                    NSString *fileSuffix = [[downloadUrl componentsSeparatedByString:@"."] lastObject];
                    // 显示下载进度条，下载大图到本地，大图下载路径：图片隐藏属性中的DOWNLOAD_URL// download_url, Than, goto YES
                    [LogUtils Log:TAG content:[NSString stringWithFormat:@"imageDownloader == nil: %@", imageDownloader == nil ? @"YES" : @"NO"]];
                    isDownloading = YES;
                    [LogUtils Log:TAG content:@"start downloading..."];
                    [imageDownloader downloadImageWithURL:photoURL options:SDWebImageDownloaderProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                        [LogUtils Log:TAG content:[NSString stringWithFormat:@"receivedSize = %ld, expectedSize = %ld", receivedSize, expectedSize]];
                        float percent = receivedSize / (float) expectedSize;
                        [SVProgressHUD showProgress:percent status:@"下载中..."];
                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                        if (error == nil) {
                            if (finished) {
                                isDownloading = NO;
                                // 将下载下来的照片保存到qm目录下面
                                BOOL savePhotoResult = [BaseFunction saveImage:image toPath:qmFolderPath withName:fileName andExtension:fileSuffix];
                                [LogUtils Log:TAG content:[NSString stringWithFormat:@"照片大图: %@, 保存%@", fileName, savePhotoResult ? @"成功" : @"失败"]];
                                [LogUtils Log:TAG content:[NSString stringWithFormat:@"bigPhotoPath = %@", bigPhotoPath]];
                                // 保存成功，则界面跳转
                                if (savePhotoResult) {
                                    [SVProgressHUD dismiss];
                                    [SVProgressHUD showWithStatus:@"正在打开..."];
                                    [smallPhotoManager updateBigImageDir:bigPhotoPath boPhotoId:[photoDict objectForKey:@"bo_photo_id"]];
                                    [self jumpToPhotoDetailWithFilePath:bigPhotoPath photoId:[photoDict objectForKey:@"bo_photo_id"] type:[_detailData objectForKey:@"content_type"] mode:MODE_SCAN isDoodled:isDoodled projectName:projectName];
                                }
                            }
                        } else {
                            [LogUtils Log:TAG content:[NSString stringWithFormat:@"error = %@", error]];
                            isDownloading = NO;
                            [SVProgressHUD dismiss];
                            [SVProgressHUD showErrorWithStatus:@"下载出错, 请重试"];
                        }
                    }];
                }
            } else {
                // 本地照片是否已上传
                if ([@"1" isEqualToString:isUpload]) {// 未上传
                    // 跳转到图片详情页面PhotoDetailActivity，参数{filepath：手机本地照片路径, photoId：照片隐藏属性中的的照片ID, type：控制点信息Map.get("CONTENT_TYPE")}
                    [self jumpToPhotoDetailWithFilePath:bigPhotoPath photoId:[photoDict objectForKey:@"bo_photo_id"] type:[_detailData objectForKey:@"content_type"] mode:MODE_DETAIL isDoodled:isDoodled projectName:projectName];
                } else {// 已上传
                    // 进入图片查看页面PhotoScanActivity，参数{filepath：手机本地照片路径, photoId：照片隐藏属性中的的照片ID, type：控制点信息Map.get("CONTENT_TYPE")}
                    [self jumpToPhotoDetailWithFilePath:bigPhotoPath photoId:[photoDict objectForKey:@"bo_photo_id"] type:[_detailData objectForKey:@"content_type"] mode:MODE_SCAN isDoodled:isDoodled projectName:projectName];
                }
            }
        } else {
            [LogUtils Log:TAG content:@"照片小图不存在"];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(photoItemWidthAndHeight, photoItemWidthAndHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(EDGEINSETS, EDGEINSETS, EDGEINSETS, EDGEINSETS);
}

#pragma mark -
#pragma mark 照片长按事件
- (void)photoLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if ([@"NO" isEqualToString:_isLocated]) {
        [LogUtils Log:TAG content:@"is not locate"];
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tmpPointTouch = [gestureRecognizer locationInView:_photosCollectionView];
        NSIndexPath *indexPath = [_photosCollectionView indexPathForItemAtPoint:tmpPointTouch];
        if (indexPath == nil){
            NSLog(@"couldn't find index path");
        } else {
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"photo cell indexPath.section = %ld, indexPath.row = %ld", indexPath.section, indexPath.row]];
            longPressedToDeletePhotoRow = indexPath.row;
            longPressedToDeletePhotoRecord = [_photosArray objectAtIndex:indexPath.row];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"gestureRecognizer longPressedToDeletePhotoRecord = %@, longPressedToDeletePhotoRow = %ld", longPressedToDeletePhotoRecord, longPressedToDeletePhotoRow]];
            UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"删除" message:@"确定要删除指定的照片？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            deleteAlert.tag = DELETE_PHOTO_ALERT_TAG;
            [deleteAlert show];
        }
    }
}

#pragma mark AlertView按钮点击回调事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"show alert tag = %ld", alertView.tag);
    NSLog(@"buttonIndex = %ld", buttonIndex);
    if (DELETE_PHOTO_ALERT_TAG == alertView.tag) {// 删除
        if (1 == buttonIndex) {// 确定删除
            NSLog(@"确定删除");
            [self deletePhotoRecord];
        }
    }
}

/**
 *  删除照片
 */
- (void)deletePhotoRecord {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"deletePhotoRecord longPressedToDeletePhotoRecord = %@", longPressedToDeletePhotoRecord]];
    NSString *photoId = [longPressedToDeletePhotoRecord objectForKey:@"bo_photo_id"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoId = %@", photoId]];
    PhotoManager *photoManager = [[PhotoManager alloc] initWithDb:_db];
    // 删除照片记录
    BOOL deletePhotoResult = [photoManager deletePhoto:photoId userid:userid];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"删除照片：%@", deletePhotoResult ? @"成功" : @"失败"]];
    // 更新控制点已完成巡检数量ContentManager.updateContentComplete(getIntent().getStringExtra("BO_CONTENT_ID"), new DateUtil().getDate(), PhotoManager.getPhotoCountList(getIntent().getStringExtra("BO_CONTENT_ID")).size(), Map.get("CONTENT_TYPE"))
    ContentManager *contentManager = [[ContentManager alloc] initWithDb:_db];
    
    NSUInteger photoCount = [photoManager getPhotoCountList:contentId userid:userid].count;
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoCount = %lu", photoCount]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"contentId = %@", contentId]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"[BaseFunction getToday] = %@", [BaseFunction getToday]]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"content_type = %@", [_detailData objectForKey:@"content_type"]]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"userid = %@", userid]];
    
    BOOL updateResult = [contentManager updateContentCompleteWithBoContentId:contentId updateDate:[BaseFunction getToday] currentNum:[NSString stringWithFormat:@"%lu", photoCount] type:[_detailData objectForKey:@"content_type"] userid:userid];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"更新控制点已完成巡检数量：%@", updateResult ? @"成功" : @"失败"]];
    if (deletePhotoResult && updateResult) {
        [_photosArray removeObjectAtIndex:longPressedToDeletePhotoRow];
        // 在拍照点列表中去掉照片
        [_photosCollectionView reloadData];
        
        // 拼装大图的本地路径
        NSString *bigPhotoPath = [self getFileCurrentPath:[longPressedToDeletePhotoRecord objectForKey:@"download_url"]];
        // 拼装小图的本地路径
        NSString *smallPhotoPath = [self getFileCurrentPath:[longPressedToDeletePhotoRecord objectForKey:@"file_path"]];
        
        // 删除手机中的照片的大图
        if ([fileManager fileExistsAtPath:bigPhotoPath]) {
            NSError *error;
            BOOL deleteResult = [fileManager removeItemAtPath:bigPhotoPath error:&error];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"removeItemAtPath:bigPhotoPath, error = %@", error]];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"删除照片大图：%@", deleteResult ? @"成功" : @"失败"]];
        }
        
        // 删除手机中的照片的小图
        if ([fileManager fileExistsAtPath:smallPhotoPath]) {
            NSError *error;
            BOOL deleteResult = [fileManager removeItemAtPath:smallPhotoPath error:&error];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"removeItemAtPath:smallPhotoPath, error = %@", error]];
            [LogUtils Log:TAG content:[NSString stringWithFormat:@"删除照片小图：%@", deleteResult ? @"成功" : @"失败"]];
        }
    } else {
        [SVProgressHUD showErrorWithStatus:@"照片删除失败"];
    }
    
}

// filepath：手机本地照片路径, photoId：照片隐藏属性中的的照片ID, type：控制点信息Map.get("CONTENT_TYPE")}
- (void)jumpToPhotoDetailWithFilePath:(NSString *)filePath photoId:(NSString *)photoId type:(NSString *)type mode:(NSString *)mode isDoodled:(NSString *)isDoodled projectName:(NSString *)projectName {
    if ([_delegate respondsToSelector:@selector(clickPhotoJumpToDetailWithFilePath:photoId:type:mode:isDoodled:currentRow:projectName:)]) {
        [_delegate clickPhotoJumpToDetailWithFilePath:filePath photoId:photoId type:type mode:mode isDoodled:isDoodled currentRow:currentRow projectName:projectName];
    }
}

/**
 *  获取该路径指定的文件在当前系统中的路径，忽略文件后缀大小写，只适用于qm目录下的文件
 *
 *  @param path 文件路径
 *
 *  @return 文件最新路径
 */
- (NSString *)getFileCurrentPath:(NSString *)path {
    // 拼装本地路径
    NSString *fileFullName = [BaseFunction splitFileNameForPath:path];
    NSString *fileSuffix = [[fileFullName componentsSeparatedByString:@"."] lastObject];
    // 将文件的后缀替换为小写......避免大小写的原因找不到文件...-_-!!!
    fileFullName = [fileFullName stringByReplacingOccurrencesOfString:fileSuffix withString:[fileSuffix lowercaseString]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"fileFullName = %@", fileFullName]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", qmFolderPath, fileFullName];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"filePath = %@", filePath]];
    
    return filePath;
}

#pragma mark -
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
