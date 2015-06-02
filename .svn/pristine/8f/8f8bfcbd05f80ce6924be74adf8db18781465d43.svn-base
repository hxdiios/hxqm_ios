//
//  PhotoBrowseCell.m
//  hxqm_mobile
//
//  Created by HelloWorld on 3/12/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "PhotoBrowseCell.h"
#import "LogUtils.h"
#import "BaseFunction.h"
#import "GTMNSString+URLArguments.h"
#import "Haneke.h"
#import "AppConfigure.h"

#define TAG @"_PhotoBrowseCell"

@implementation PhotoBrowseCell

- (void)initCellWithWidth:(NSNumber *)width height:(NSNumber *)height Data:(NSDictionary *)data {
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, [width floatValue], [height floatValue])];
    
    NSString *photoName = [data objectForKey:@"photo_name"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"photoName = %@", photoName]];
    NSString *smallPhotoPath = [data objectForKey:@"download_small_path"];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"smallPhotoPath = %@", smallPhotoPath]];
    
    NSString *qmPath = [BaseFunction getQMSystemFolderPath];
    NSMutableString *fileFullName = [[NSMutableString alloc] initWithString:[BaseFunction splitFileNameForPath:smallPhotoPath]];
    NSString *photoSuffix;
    if ([fileFullName myContainsString:@"."]) {
        photoSuffix = [[fileFullName componentsSeparatedByString:@"."] lastObject];
    } else {
        photoSuffix = [fileFullName substringFromIndex:([fileFullName length] - 3)];
        [fileFullName insertString:@"." atIndex:[fileFullName length] - 3];
    }
    // 将照片大图的后缀替换为小写......避免大小写的原因找不到文件...-_-!!!
    [fileFullName stringByReplacingOccurrencesOfString:photoSuffix withString:[photoSuffix lowercaseString]];
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"fileFullName = %@", fileFullName]];
    if ([smallPhotoPath myContainsString:@"/qm/"]) {
        smallPhotoPath = [NSString stringWithFormat:@"%@/%@", qmPath, fileFullName];
    } else if ([smallPhotoPath myContainsString:[NSString stringWithFormat:@"/images/%@", [AppConfigure objectForKey:USERID]]]) {
        NSString *imagesFolderPath = [smallPhotoPath substringFromIndex:[smallPhotoPath rangeOfString:@"/images/"].location];
        smallPhotoPath = [NSString stringWithFormat:@"%@%@", PATH_OF_DOCUMENT, imagesFolderPath];
    }
    
    [LogUtils Log:TAG content:[NSString stringWithFormat:@"smallPhotoPath = %@", smallPhotoPath]];
    _name.text = photoName;
    
    [_image hnk_setImageFromFile:smallPhotoPath placeholder:[UIImage imageNamed:@"icon_error.png"]];
}

@end
