//
//  MajorManager.m
//  hxqm_mobile
//
//  Created by HelloWorld on 1/19/15.
//  Copyright (c) 2015 huaxin. All rights reserved.
//

#import "MajorManager.h"

@implementation MajorManager

- (NSArray *)getMajorList:(NSString *)jsonString {
    NSError *err;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSArray *objects = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    return objects;
}

@end
