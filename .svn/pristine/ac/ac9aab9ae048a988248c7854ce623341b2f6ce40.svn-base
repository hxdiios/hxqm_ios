//
//  BaseHomeViewController.h
//  hxqm_mobile
//
//  Created by panqw on 15-4-8.
//  Copyright (c) 2015年 huaxin. All rights reserved.
//
#import "BaseViewController.h"
#import "ASIHTTPRequestDelegate.h"
#import "BaseFormDataRequest.h"

@interface BaseHomeViewController : BaseViewController<ASIHTTPRequestDelegate>

- (void)getUpdatableNum;
- (void)initProgressAlert;
- (void)showFailMsg:(NSString *)string;
- (void) updateUINums;
- (void)showCurrentReadPosition:(float)currentReadPosition;
- (void)showProgressAlert;
- (void)closeProgressAlert;
- (void) updateInsertDataProcess : (int) insertedCount updateTotalNum:(float)updateTotalNum;
- (void)updateUploadablePicNum;
- (void)shwoUploadablePicNum:(NSString *)photoCounts;
- (void)doUpload:(NSDictionary *) inputData;
- (void)setUploadProgressDelegate:(BaseFormDataRequest *)request;
- (void) updateUploadingUI : (NSInteger) uploadingIndex totalCounts:(NSInteger) totalCounts;
- (void) doSucceedUpload;
- (void) noFileNeedUpload;
@end