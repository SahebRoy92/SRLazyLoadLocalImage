//
//  UIImageView+SRCasheImage.h
//  LazyLoadingTableview
//
//  Created by Saheb Roy on 10/08/16.
//  Copyright © 2016 Saheb Roy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRLazyLoadLocal.h"

@interface UIImageView (SRCasheImage)


// This method creates an alternate image in Cashe directory and also in NSCache, and loads the image from NSCache.
// Only thumbnail image support is there now.

-(void)setImageFromCacheWithFilePath:(NSString *)filePath withPlaceHolderImage:(UIImage *)placeHolderImage andImageSize:(SRCacheImageSize)options andCompletionBlock:(void(^)(UIImage *image))completionBlock;

@end
