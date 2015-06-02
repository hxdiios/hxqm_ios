//
//  PhotoBrowseController.m
//  hxqm_mobile
//
//  Created by 刘志 on 15/1/28.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//

#import "PhotoBrowseController.h"
#import "LogUtils.h"
#import "MyMacros.h"
#import "PhotoBrowseCell.h"
#import "PhotoManager.h"
#import "AppConfigure.h"
#import "BaseFunction.h"
#import "GTMNSString+URLArguments.h"
#import "RabishViewController.h"
#import "PhotoDetailViewController.h"
#import "Constants.h"
#import "SVProgressHUD.h"

#define TAG @"_PhotoBrowseController"
#define EDGEINSETS 10

@interface PhotoBrowseController () {
    NSMutableArray *photos;
    NSMutableArray *thumbs;
    float photoItemWidth;
    NSMutableArray *_photosArray;
    NSString *userid;
}

@end

static NSString *CellIdentifier = @"PhotoBrowseCell";

@implementation PhotoBrowseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"照片管理";
    [self addNavBackBtn];
    
    // 设置导航栏按钮的点击执行方法等
    UIBarButtonItem *trashBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashBtnClick)];
    trashBtnItem.tintColor = [UIColor whiteColor];
    NSArray *actionButtonItems = @[trashBtnItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    // 计算照片的宽高
    photoItemWidth = (UI_SCREEN_WIDTH - 40) / 3.0f;
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoItemWidth = %f", photoItemWidth]];
    _photosArray = [[NSMutableArray alloc] init];
    userid = [AppConfigure objectForKey:USERID];
    
    // 在ViewDidLoad方法中声明Cell的类，在ViewDidLoad方法中添加，此句不声明，将无法加载，程序崩溃
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"PhotoBrowseCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellIdentifier];
    
    [self loadDatas];
}

- (void)loadDatas {
    PhotoManager *photoManager = [[PhotoManager alloc] initWithDb];
    [photoManager openDB];
    _photosArray = [photoManager getPhotoList:userid];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"_photosArray = %@", _photosArray]];
    [photoManager closeDB];
    if (_photosArray == nil || _photosArray.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"当前还没有照片"];
    }
}

#pragma mark -
#pragma mark - UICollectionView Delegate
// 每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_photosArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"collectionView indexPath.row = %ld", indexPath.row]];
    
    int row = (int)indexPath.row;
    
    PhotoBrowseCell *cell = (PhotoBrowseCell *) [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell initCellWithWidth:[NSNumber numberWithFloat:photoItemWidth] height:[NSNumber numberWithFloat:photoItemWidth] Data:[_photosArray objectAtIndex:row]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"indexPath.section = %ld, indexPath.row = %ld", indexPath.section, indexPath.row]];
    NSMutableDictionary *photoDict = [_photosArray objectAtIndex:indexPath.row];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoDict = %@", photoDict]];
    // 进入照片查看页面PhotoScanActivity,
    // 参数{
    //      filepath:对应照片隐藏属性中的照片路径
    //      photoId:对应照片隐藏属性中的的照片ID
    //      type:对应照片隐藏属性中的的照片类型 }
    PhotoDetailViewController *photoDetailViewController = [[PhotoDetailViewController alloc] initWithNibName:@"PhotoDetailViewController" bundle:nil];
    photoDetailViewController.filePath = [BaseFunction getCurrentPathWithFilePath:[photoDict objectForKey:@"file_path"]];
    photoDetailViewController.photoId = [photoDict objectForKey:@"bo_photo_id"];
    photoDetailViewController.type = [photoDict objectForKey:@"photo_type"];
    photoDetailViewController.mode = MODE_SCAN;
    photoDetailViewController.isDoodle = [photoDict objectForKey:@"is_doodled"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photoDetailViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(photoItemWidth, photoItemWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(EDGEINSETS, EDGEINSETS, EDGEINSETS, EDGEINSETS);
}

#pragma mark -
- (void)trashBtnClick {
    NSLog(@"trashBtnClick");
    // 照片删除
    RabishViewController *rabishViewController = [[RabishViewController alloc] initWithNibName:@"RabishViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rabishViewController];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {}];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
