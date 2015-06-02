//
//  ProjectCell.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/19/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "ProjectCell.h"
#import "AppConfigure.h"

@implementation ProjectCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)initViewWithData:(NSDictionary *)data {
    if (data != nil) {
        _projectName.text = [data objectForKey:PROJECT_NAME];
        _projetNO.text = [NSString stringWithFormat:@"编号：%@", [data objectForKey:PROJECT_NUMBER]];
        NSString *upload_Amount = [data objectForKey:UPLOAD_AMOUNT];
        _projectTakePhotos.text = [NSString stringWithFormat:@"%@", upload_Amount];
        _projectDistance.text = [data objectForKey:PROJECT_DISTANCE];
        _projectTime.text = [data objectForKey:ENTER_DATE];
    } else {
        NSLog(@"data is nil");
    }
}

- (void)initViewForFavoriteWithData:(NSDictionary *)data {
    if (data != nil) {
        _projectName.text = [data objectForKey:PROJECT_NAME];
        _projetNO.text = [NSString stringWithFormat:@"%@", [data objectForKey:PROJECT_NUMBER]];
        NSString *upload_Amount = [data objectForKey:UPLOAD_AMOUNT];
        _projectTakePhotos.text = [NSString stringWithFormat:@"%@", upload_Amount];
        _projectDistance.text = [data objectForKey:@"relative_distance"];
        _projectTime.text = [data objectForKey:@"favorite_date"];
    } else {
        NSLog(@"data is nil");
    }
}

- (void)initViewForBrowseWithData:(NSDictionary *)data {
    if (data != nil) {
        _projectName.text = [data objectForKey:PROJECT_NAME];
        _projetNO.text = [NSString stringWithFormat:@"%@", [data objectForKey:PROJECT_NUMBER]];
        NSString *upload_Amount = [data objectForKey:UPLOAD_AMOUNT];
        _projectTakePhotos.text = [NSString stringWithFormat:@"%@", upload_Amount];
        _projectDistance.text = [data objectForKey:@"relative_distance"];
        _projectTime.text = [data objectForKey:@"enter_date"];
    } else {
        NSLog(@"data is nil");
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
