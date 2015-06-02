//
//  PhotoBrowseCell.h
//  hxqm_mobile
//
//  Created by HelloWorld on 3/12/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowseCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;

- (void)initCellWithWidth:(NSNumber *)width height:(NSNumber *)height Data:(NSDictionary *)data;

@end
