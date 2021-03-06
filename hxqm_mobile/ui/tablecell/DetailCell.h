//
//  DetailCell.h
//  hxqm_mobile
//
//  Created by HelloWorld on 2/28/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@protocol DetailDelegate <NSObject>

@optional
- (void)clickCameraWithCurrentRow:(NSInteger)row;
- (void)clickInstanceBtn:(NSMutableArray *)instanceImage;
- (void)clickPhotoJumpToDetailWithFilePath:(NSString *)filePath photoId:(NSString *)photoId type:(NSString *)type mode:(NSString *)mode isDoodled:(NSString *)isDoodled currentRow:(NSInteger)currentRow projectName:(NSString *)projectName;
@end

@interface DetailCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *instanceBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (nonatomic, weak) id<DetailDelegate> delegate;
@property (nonatomic, copy) NSMutableArray *photosArray;
@property (nonatomic, copy) NSDictionary *detailData;

@property (nonatomic,assign) FMDatabase *db;

- (IBAction)cameraBtnClick:(UIButton *)sender;
- (IBAction)instanceBtnClick:(UIButton *)sender;

@property (nonatomic, copy) NSString *isLocated;
- (void)initViewWithData:(NSDictionary *)data AtRow:(NSInteger)row;

@end
