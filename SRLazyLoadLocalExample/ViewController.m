//
//  ViewController.m
//  LazyLoadingTableview
//
//  Created by Saheb Roy on 09/08/16.
//  Copyright © 2016 Saheb Roy. All rights reserved.
//

#define URL @"https://unsplash.it/200/300/?random"

#import "ViewController.h"
#import "UIImageView+SRCasheImage.h"


@interface ViewController ()<UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tblView;

@end

@implementation ViewController{
    NSMutableArray *nameOFAll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    nameOFAll = [NSMutableArray array];
    [self getAllImages];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(allImagesLoaded) name:@"done" object:nil];
}

-(void)allImagesLoaded{
    [self.tblView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/* --------   GET DUMMY IMAGES FROM INTERNET -------- */


-(void)getAllImages{
    __block int counter = 0;
    for (int i=0; i<50; i++) {
        NSURL *url = [NSURL URLWithString:URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          
                                          UIImage *img = [UIImage imageWithData:data];
                                          NSString *nameOfImg = [NSString stringWithFormat:@"IMG_%i.png",counter];
                                          [self saveToDocumentDirectory:nameOfImg andData:img];
                                          [nameOFAll addObject:nameOfImg];
                                          counter++;
                                          if(counter >= 50){
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [[NSNotificationCenter defaultCenter]postNotificationName:@"done" object:nil];

                                              });
                                          }
                                          
                                          // ...
                                      }];
        
        [task resume];
        
    }
    
}


/* --------   SAVE DUMMY IMAGES TO DOCUMENT DIRECTORY -------- */



-(void)saveToDocumentDirectory:(NSString *)name andData:(UIImage *)img{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"DummyImages"];

    
    if(![[NSFileManager defaultManager]fileExistsAtPath:dataPath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }

    NSString *finalPath = [dataPath stringByAppendingPathComponent:name];
    NSData *pngData = UIImagePNGRepresentation(img);
    [pngData writeToFile:finalPath atomically:YES];
    
}


-(NSString *)getFilePathToDummy:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"DummyImages"];
    return [dataPath stringByAppendingPathComponent:fileName];
}



#pragma mark -- Tableview methods -- 


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuse = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    NSString *path = [self getFilePathToDummy:nameOFAll[indexPath.row]];
    UIImageView *imgV = (UIImageView*)[cell.contentView viewWithTag:100];
    __weak UIImageView *weakImg = imgV;
    
    
    /* 
     
        This is how we use the Category class -- >
        Just Pass the path of the image in the Document Directory, and this category will cache it and lazy load this image as it seems.
    */
    
    [imgV setImageFromCacheWithFilePath:path withPlaceHolderImage:nil andImageSize:kSRCasheImageSizeThumbnail andCompletionBlock:^(UIImage *image) {
        weakImg.image = image;
    }];
    

    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return nameOFAll.count;
}

@end
