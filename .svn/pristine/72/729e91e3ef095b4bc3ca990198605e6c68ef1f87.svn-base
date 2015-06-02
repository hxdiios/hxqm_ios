//
//  FICDViewController.m
//  FastImageCacheDemo
//
//  Copyright (c) 2013 Path, Inc.
//  See LICENSE for full license agreement.
//

#import "FICDViewController.h"
#import "FICImageCache.h"
#import "FICDTableView.h"
#import "FICDPhoto.h"
#import "FICDFullscreenPhotoDisplayController.h"
#import "FICDPhotosTableViewCell.h"

#pragma mark Class Extension

@interface FICDViewController () <UITableViewDataSource, UITableViewDelegate, FICDPhotosTableViewCellDelegate, FICDFullscreenPhotoDisplayControllerDelegate> {
    FICDTableView *_tableView;
    NSArray *_photos;
    
    NSString *_imageFormatName;
    NSArray *_imageFormatStyleToolbarItems;
    
    BOOL _usesImageTable;
    BOOL _shouldReloadTableViewAfterScrollingAnimationEnds;
    BOOL _shouldResetData;
    NSInteger _selectedMethodSegmentControlIndex;
    NSInteger _callbackCount;
    UIAlertView *_noImagesAlertView;
    UILabel *_averageFPSLabel;
}

@end

#pragma mark

@implementation FICDViewController

#pragma mark - Object Lifecycle

- (id)init {
    self = [super init];
    
    if (self != nil) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
        for(NSInteger i = 1;i < 5;i++) {
            NSURL *url = [mainBundle URLForResource:[NSString stringWithFormat:@"photo%ld",i] withExtension:@".jpg"];
            [imageURLs addObject:url];
        }
        
        if ([imageURLs count] > 0) {
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            for (NSURL *imageURL in imageURLs) {
                FICDPhoto *photo = [[FICDPhoto alloc] init];
                [photo setSourceImageURL:imageURL];
                [photos addObject:photo];
            }
            
            while ([photos count] < 5000) {
                [photos addObjectsFromArray:photos]; // Create lots of photos to scroll through
            }
            
            _photos = photos;
        } else {
            //empty images
        }
    }
    
    return self;
}

- (void)dealloc {
    [_tableView setDelegate:nil];
    [_tableView setDataSource:nil];
    
    [_noImagesAlertView setDelegate:nil];
}

#pragma mark - View Controller Lifecycle

- (void)loadView {
    CGRect viewFrame = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:viewFrame];
    [view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    [self setView:view];
    
    // Configure the table view
    if (_tableView == nil) {
        _tableView = [[FICDTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        CGFloat tableViewCellOuterPadding = [FICDPhotosTableViewCell outerPadding];
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, tableViewCellOuterPadding, 0)];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [_tableView setScrollIndicatorInsets:UIEdgeInsetsMake(7, 0, 7, 1)];
        }
    }
    
    [_tableView setFrame:[view bounds]];
    [view addSubview:_tableView];
    _imageFormatName = FICDPhotoSquareImage32BitBGRAFormatName;
    
    self.title = @"照片管理";
    [self addNavCloseBtn];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[FICDFullscreenPhotoDisplayController sharedDisplayController] setDelegate:self];
    [self reloadTableViewAndScrollToTop:YES];
}

#pragma mark - Reloading Data

- (void)reloadTableViewAndScrollToTop:(BOOL)scrollToTop {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    
    // Don't allow interaction events to interfere with thumbnail generation
    if ([sharedApplication isIgnoringInteractionEvents] == NO) {
        [sharedApplication beginIgnoringInteractionEvents];
    }

    if (scrollToTop) {
        // If the table view isn't already scrolled to top, we do that now, deferring the actual table view reloading logic until the animation finishes.
        CGFloat tableViewTopmostContentOffsetY = 0;
        CGFloat tableViewCurrentContentOffsetY = [_tableView contentOffset].y;
        
        if ([self respondsToSelector:@selector(topLayoutGuide)]) {
            id <UILayoutSupport> topLayoutGuide = [self topLayoutGuide];
            tableViewTopmostContentOffsetY = -[topLayoutGuide length];
        }
        
        if (tableViewCurrentContentOffsetY > tableViewTopmostContentOffsetY) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            _shouldReloadTableViewAfterScrollingAnimationEnds = YES;
        }
    }
    
    if (_shouldReloadTableViewAfterScrollingAnimationEnds == NO) {
        // Reset the data now
        if (_shouldResetData) {
            _shouldResetData = NO;
            [[FICImageCache sharedImageCache] reset];
            
            // Delete all cached thumbnail images as well
            for (FICDPhoto *photo in _photos) {
                [photo deleteThumbnail];
            }
        }
        
        _usesImageTable = _selectedMethodSegmentControlIndex == 1;
        
        [[self navigationController] setToolbarHidden:(_usesImageTable == NO) animated:YES];
        
        dispatch_block_t tableViewReloadBlock = ^{
            [_tableView reloadData];
            [_tableView resetScrollingPerformanceCounters];
            
            if ([_tableView isHidden]) {
                [[_tableView layer] addAnimation:[CATransition animation] forKey:kCATransition];
            }
            
            [_tableView setHidden:NO];
            
            // Re-enable interaction events once every thumbnail has been generated
            if ([sharedApplication isIgnoringInteractionEvents]) {
                [sharedApplication endIgnoringInteractionEvents];
            }
        };
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // In order to make a fair comparison for both methods, we ensure that the cached data is ready to go before updating the UI.
            if (_usesImageTable) {
                _callbackCount = 0;
                NSSet *uniquePhotos = [NSSet setWithArray:_photos];
                for (FICDPhoto *photo in uniquePhotos) {
                    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
                    FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
                    
                    if ([sharedImageCache imageExistsForEntity:photo withFormatName:_imageFormatName] == NO) {
                        if (_callbackCount == 0) {
                            NSLog(@"*** FIC Demo: Fast Image Cache: Generating thumbnails...");
                            
                            // Hide the table view's contents while we generate new thumbnails
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_tableView setHidden:YES];
                                [[_tableView layer] addAnimation:[CATransition animation] forKey:kCATransition];
                            });
                        }
                        
                        _callbackCount++;
                        
                        [sharedImageCache asynchronouslyRetrieveImageForEntity:photo withFormatName:_imageFormatName completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                            _callbackCount--;
                            
                            if (_callbackCount == 0) {
                                NSLog(@"*** FIC Demo: Fast Image Cache: Generated thumbnails in %g seconds", CFAbsoluteTimeGetCurrent() - startTime);
                                dispatch_async(dispatch_get_main_queue(), tableViewReloadBlock);
                            }
                        }];
                    }
                }
                
                if (_callbackCount == 0) {
                    dispatch_async(dispatch_get_main_queue(), tableViewReloadBlock);
                }
            } else {
                [self _generateConventionalThumbnails];
                
                dispatch_async(dispatch_get_main_queue(), tableViewReloadBlock);
            }
        });
    }
}

#pragma mark - Image Helper Functions

static UIImage * _FICDColorAveragedImageFromImage(UIImage *image) {
    // Crop the image to the area occupied by the status bar
    CGSize imageSize = [image size];
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGRect cropRect = CGRectMake(0, 0, imageSize.width, statusBarSize.height);
    
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *statusBarImage = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    
    // Draw the cropped image into a 1x1 bitmap context; this automatically averages the color values of every pixel
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGSize contextSize = CGSizeMake(1, 1);
    CGContextRef bitmapContextRef = CGBitmapContextCreate(NULL, contextSize.width, contextSize.height, 8, 0, colorSpaceRef, (kCGImageAlphaNoneSkipFirst & kCGBitmapAlphaInfoMask));
    CGContextSetInterpolationQuality(bitmapContextRef, kCGInterpolationMedium);
    
    CGRect drawRect = CGRectZero;
    drawRect.size = contextSize;
    
    UIGraphicsPushContext(bitmapContextRef);
    [statusBarImage drawInRect:drawRect];
    UIGraphicsPopContext();
    
    // Create an image from the bitmap context
    CGImageRef colorAveragedImageRef = CGBitmapContextCreateImage(bitmapContextRef);
    UIImage *colorAveragedImage = [UIImage imageWithCGImage:colorAveragedImageRef];
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(colorAveragedImageRef);
    CGContextRelease(bitmapContextRef);
    
    return colorAveragedImage;
}

static BOOL _FICDImageIsLight(UIImage *image) {
    BOOL imageIsLight = NO;
    
    CGImageRef imageRef = [image CGImage];
    CGDataProviderRef dataProviderRef = CGImageGetDataProvider(imageRef);
    NSData *pixelData = (__bridge_transfer NSData *)CGDataProviderCopyData(dataProviderRef);
    
    if ([pixelData length] > 0) {
        const UInt8 *pixelBytes = [pixelData bytes];
        
        // Whether or not the image format is opaque, the first byte is always the alpha component, followed by RGB.
        UInt8 pixelR = pixelBytes[1];
        UInt8 pixelG = pixelBytes[2];
        UInt8 pixelB = pixelBytes[3];
        
        // Calculate the perceived luminance of the pixel; the human eye favors green, followed by red, then blue.
        double percievedLuminance = 1 - (((0.299 * pixelR) + (0.587 * pixelG) + (0.114 * pixelB)) / 255);
        
        imageIsLight = percievedLuminance < 0.5;
    }
    
    return imageIsLight;
}

- (void)_updateStatusBarStyleForColorAveragedImage:(UIImage *)colorAveragedImage {
    BOOL imageIsLight = _FICDImageIsLight(colorAveragedImage);
    
    UIStatusBarStyle statusBarStyle = imageIsLight ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:YES];
}

#pragma mark - Working with Thumbnails

- (void)_generateConventionalThumbnails {
    BOOL neededToGenerateThumbnail = NO;
    CFAbsoluteTime startTime = 0;
    
    NSSet *uniquePhotos = [NSSet setWithArray:_photos];
    for (FICDPhoto *photo in uniquePhotos) {
        if ([photo thumbnailImageExists] == NO) {
            if (neededToGenerateThumbnail == NO) {
                NSLog(@"*** FIC Demo: Conventional Method: Generating thumbnails...");
                startTime = CFAbsoluteTimeGetCurrent();
                
                neededToGenerateThumbnail = YES;
                
                // Hide the table view's contents while we generate new thumbnails
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView setHidden:YES];
                    [[_tableView layer] addAnimation:[CATransition animation] forKey:kCATransition];
                });
            }
            
            @autoreleasepool {
                [photo generateThumbnail];
            }
        }
    }
    
    if (neededToGenerateThumbnail) {
        NSLog(@"*** FIC Demo: Conventional Method: Generated thumbnails in %g seconds", CFAbsoluteTimeGetCurrent() - startTime);
    }
}

#pragma mark - Protocol Implementations

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = ceilf((CGFloat)[_photos count] / (CGFloat)[FICDPhotosTableViewCell photosPerRow]);
    
    return numberOfRows;
}

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString *reuseIdentifier = [FICDPhotosTableViewCell reuseIdentifier];
    
    FICDPhotosTableViewCell *tableViewCell = (FICDPhotosTableViewCell *)[table dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (tableViewCell == nil) {
        tableViewCell = [[FICDPhotosTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [tableViewCell setBackgroundColor:[table backgroundColor]];
        [tableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [tableViewCell setDelegate:self];
    [tableViewCell setImageFormatName:_imageFormatName];
    
    NSInteger photosPerRow = [FICDPhotosTableViewCell photosPerRow];
    NSInteger startIndex = [indexPath row] * photosPerRow;
    NSInteger count = MIN(photosPerRow, [_photos count] - startIndex);
    NSArray *photos = [_photos subarrayWithRange:NSMakeRange(startIndex, count)];
    
    [tableViewCell setUsesImageTable:_usesImageTable];
    [tableViewCell setPhotos:photos];
    
    return tableViewCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = [FICDPhotosTableViewCell rowHeightForInterfaceOrientation:[self interfaceOrientation]];
    
    return rowHeight;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)willDecelerate {
    if (willDecelerate == NO) {
        [_tableView resetScrollingPerformanceCounters];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_tableView resetScrollingPerformanceCounters];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [_tableView resetScrollingPerformanceCounters];

    if (_shouldReloadTableViewAfterScrollingAnimationEnds) {
        _shouldReloadTableViewAfterScrollingAnimationEnds = NO;
        
        // Add a slight delay before reloading the data
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self reloadTableViewAndScrollToTop:NO];
        });
    }
}

#pragma mark - FICDPhotosTableViewCellDelegate

- (void)photosTableViewCell:(FICDPhotosTableViewCell *)photosTableViewCell didSelectPhoto:(FICDPhoto *)photo withImageView:(UIImageView *)imageView {
    FICDFullscreenPhotoDisplayController *controller = [FICDFullscreenPhotoDisplayController sharedDisplayController];
    controller.rootController = self.navigationController;
    [controller showFullscreenPhoto:photo forImageFormatName:_imageFormatName withThumbnailImageView:imageView];
}

#pragma mark - FICDFullscreenPhotoDisplayControllerDelegate

- (void)photoDisplayController:(FICDFullscreenPhotoDisplayController *)photoDisplayController willShowSourceImage:(UIImage *)sourceImage forPhoto:(FICDPhoto *)photo withThumbnailImageView:(UIImageView *)thumbnailImageView {
    // If we're running on iOS 7, we'll try to intelligently determine whether the photo contents underneath the status bar is light or dark.
    if ([self respondsToSelector:@selector(preferredStatusBarStyle)]) {
        if (_usesImageTable) {
            [[FICImageCache sharedImageCache] retrieveImageForEntity:photo withFormatName:FICDPhotoPixelImageFormatName completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                if (image != nil && [photoDisplayController isDisplayingPhoto]) {
                    [self _updateStatusBarStyleForColorAveragedImage:image];
                }
            }];
        } else {
            UIImage *colorAveragedImage = _FICDColorAveragedImageFromImage(sourceImage);
            [self _updateStatusBarStyleForColorAveragedImage:colorAveragedImage];
        }
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    }
}

- (void)photoDisplayController:(FICDFullscreenPhotoDisplayController *)photoDisplayController willHideSourceImage:(UIImage *)sourceImage forPhoto:(FICDPhoto *)photo withThumbnailImageView:(UIImageView *)thumbnailImageView {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

@end
