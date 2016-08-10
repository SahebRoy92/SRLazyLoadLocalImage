//
//  SRLazyLoadLocal.m
//  LazyLoadingTableview
//
//  Created by Saheb Roy on 10/08/16.
//  Copyright © 2016 Saheb Roy. All rights reserved.
//

#import "SRLazyLoadLocal.h"

static dispatch_once_t lazyLoadQueue;
static NSString *const cacheDirectoryName = @"com.in.SRLazyLoadLocalDirectory";

@implementation SRLazyLoadLocal

+(instancetype)lazyLoadManager{
    
    static SRLazyLoadLocal *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SRLazyLoadLocal alloc]init];
        [manager setupManager];
    });
    return manager;
    
}


-(void)setupManager{
    lazyLoadLocalQueue();
    [self createCacheDirectory];
    
}


#pragma mark -- NSCache Methods -- 

-(NSCache *)cache{
    if(!_cache){
       _cache = [[NSCache alloc] init];
    }
    return _cache;
}

-(void)setResultingThumbNailToCashe:(NSString *)filePath{
    dispatch_async(lazyLoadLocalQueue(), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        [self.cache setObject:image forKey:[filePath lastPathComponent]];
    });
}

-(UIImage *)getImageFromCacheWithKey:(NSString *)key{
    return [self.cache objectForKey:key];
}



#pragma mark -- Custom Queue - 

dispatch_queue_t lazyLoadLocalQueue() {
    static dispatch_queue_t queue;
    dispatch_once(&lazyLoadQueue, ^{
        queue = dispatch_queue_create("com.sahebroy.Lazyloadqueue", 0);
    });
    return queue;
}



#pragma mark -- Cache Directory Methods  ---

-(void)createCacheDirectory{
    NSString *myPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cacheDirectory    = [myPath stringByAppendingPathComponent:cacheDirectoryName];
    
    if(![[NSFileManager defaultManager]fileExistsAtPath:cacheDirectory]){
        // create the cashe directory
        [[NSFileManager defaultManager]createDirectoryAtPath:cacheDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }

}


-(NSString *)getCacheDirectoryFileName{
    NSString *myPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [myPath stringByAppendingPathComponent:cacheDirectoryName];
}





#pragma mark -- Resize and save to Cache Directory ----

- (void)resizeLocalImageAsthumbAndWriteTofile:(NSString *)imagePath andCompletionBlock:(void(^)(NSString *fileName))completionBlock{
    
    dispatch_async(lazyLoadLocalQueue(), ^{

        NSData *pngData = UIImagePNGRepresentation([self resizeImage:[UIImage imageWithContentsOfFile:imagePath] newSize:CGSizeMake(200, 200)]);
        NSString *fileName = [NSString stringWithFormat:@"%@",[imagePath lastPathComponent]];
        fileName = [[self getCacheDirectoryFileName] stringByAppendingPathComponent:fileName];
         [pngData writeToFile:fileName atomically:NO];
        [self setResultingThumbNailToCashe:fileName];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock([NSString stringWithFormat:@"%@",[fileName lastPathComponent]]);
        });

    });
    
}



#pragma mark - Resize Image -- 

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, newRect, imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}



@end
