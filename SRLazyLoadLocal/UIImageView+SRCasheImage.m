//
//  UIImageView+SRCasheImage.m
//  LazyLoadingTableview
//
//  Created by Saheb Roy on 10/08/16.
//  Copyright © 2016 Saheb Roy. All rights reserved.
//

#import "UIImageView+SRCasheImage.h"


@implementation UIImageView (SRCasheImage)


-(void)setImageFromCacheWithFilePath:(NSString *)filePath withPlaceHolderImage:(UIImage *)placeHolderImage andImageSize:(SRCacheImageSize)options andCompletionBlock:(void(^)(UIImage *image))completionBlock{
    
    
    self.image = placeHolderImage;
    
    NSString *realCacheKey = [NSString stringWithFormat:@"%@.png",[filePath lastPathComponent]];
    UIImage *resultantImage = [[SRLazyLoadLocal lazyLoadManager]getImageFromCacheWithKey:realCacheKey];
    
    if(resultantImage){
        completionBlock(resultantImage);
    }
    else {
        __weak UIImageView *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *filePathUrlforCacheDirectory = [[SRLazyLoadLocal lazyLoadManager]getCacheDirectoryFileName];
            filePathUrlforCacheDirectory = [filePathUrlforCacheDirectory stringByAppendingPathComponent:[filePath lastPathComponent]];
            
            if([[NSFileManager defaultManager]fileExistsAtPath:filePathUrlforCacheDirectory]){
                UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@.png",filePathUrlforCacheDirectory]];
                [[SRLazyLoadLocal lazyLoadManager]setResultingThumbNailToCashe:filePathUrlforCacheDirectory];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(image);
                    [weakSelf setNeedsLayout];
                });
            }
            else {
                [[SRLazyLoadLocal lazyLoadManager]resizeLocalImageAsthumbAndWriteTofile:filePath andCompletionBlock:^(NSString *fileName) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock([[SRLazyLoadLocal lazyLoadManager]getImageFromCacheWithKey:[NSString stringWithFormat:@"%@.png",[fileName lastPathComponent]]]);
                    });
                }];
            }
        });
    }
}

@end
