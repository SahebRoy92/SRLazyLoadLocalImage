//
//  SRLazyLoadLocal.h
//  LazyLoadingTableview
//
//  Created by Saheb Roy on 10/08/16.
//  Copyright © 2016 Saheb Roy. All rights reserved.
//



/*
 
 THERE ARE MANY LIBRARIES THAT HELP CACHE IMAGES FROM WEB URLS's. 
 AND WE USE THEM AS THEY ARE SO GOOD.
 BUT ALL OF THEM FETCH IMAGES FROM THE WEB URL.
 
 THERE WASNT ANY LAZY LOADING CACHE LIBRARY THAT FETCHES IMAGE FROM DOCUMENT DIRECTORY PATH, AND CACHE IT FOR LATER USE.
 
 
 
 
--------------------          SRLazyLoadLocal         --------------------------- 
 
 This Library does this tiny job of loading image from Document Directory and also saving the image in Cache for later use.
 This lazy loading method is very effective and also helps in a better UI Experience for users.
 This Library not just saves it in NSCache but also keeps a backup in the Cache Directory. 

 Best uses when Loading images ASYNCHRONOUSLY in Tableview Cells.
 
 
 Refinement left -- 
 
 1. Backup for Original Size images (Right now Only thumbnail size of the real images are kept as backup).
 2. Adding Activity indicator for showing images are being loaded.
 
 
 
 I would also like to thank souvickcse for his helping hand.
 */






#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    kSRCasheImageSizeFull,
    kSRCasheImageSizeThumbnail
    
}SRCacheImageSize;


static dispatch_once_t lazyLoadQueue;


@interface SRLazyLoadLocal : NSObject

@property (nonatomic,strong) NSCache *cache;



+(instancetype)lazyLoadManager;

- (void)resizeLocalImageAsthumbAndWriteTofile:(NSString *)imagePath andCompletionBlock:(void(^)(NSString *fileName))completionBlock;

- (UIImage *)getImageFromCacheWithKey:(NSString *)key;

- (NSString *)getCacheDirectoryFileName;

- (void)setResultingThumbNailToCashe:(NSString *)filePath;


@end
