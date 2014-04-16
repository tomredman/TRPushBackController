//
//  FlickrManager.m
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import "FlickrManager.h"
#import "FlickrImage.h"

@implementation FlickrManager

- (void)getNewImages:(NewImageBlock)newImageBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/x-javascript", @"application/json", @"text/javascript", @"text/x-javascript", @"text/x-json", nil]];
    
    [manager GET:@"http://api.flickr.com/services/feeds/photos_public.gne?tag=sunset&lang=en-us&format=json&nojsoncallback=1" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        
        NSString *responseString = [operation.responseString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
        
        NSData *santizedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *imagesDict = [NSJSONSerialization JSONObjectWithData:santizedData options:NSJSONReadingAllowFragments error:&error];
        
        if (!error){
            NSArray *images = imagesDict[@"items"];
            if (!images) {
                if (newImageBlock) {
                    newImageBlock(nil);
                }
                return;
            }
            
            NSMutableArray *allImages = [@[] mutableCopy];
            
            for (NSDictionary *image in images) {
                FlickrImage *flickrImage = [[FlickrImage alloc] init];
                flickrImage.photographer = image[@"author"];
                
                NSString *urlString = image[@"media"][@"m"];
                
                if (urlString) {
                    flickrImage.imageURL = [NSURL URLWithString:urlString];
                    
                    /**
                     *  Only add the flickrImage if there is an image to view
                     */
                    [allImages addObject:flickrImage];
                }
            }
            
            /**
             *  SUCCESS
             */
            if (newImageBlock) {
                newImageBlock(allImages);
            }
            
        }
        else {
            if (newImageBlock) {
                newImageBlock(nil);
            }
            return;
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        newImageBlock(nil);
    }];
    
    return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *images = [@[] mutableCopy];
        
        for (int i = 1; i <= 8; i++) {
            FlickrImage *newImage = [[FlickrImage alloc] init];
            newImage.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://tomredman.ca/pics/%d.jpg", i]];
            newImage.photographer = @"Tom Redman";
            [images addObject:newImage];
        }
        
        [NSThread sleepForTimeInterval:4.0];
        
        if (newImageBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                newImageBlock(images);
            });
        }
        
    });
}

@end
