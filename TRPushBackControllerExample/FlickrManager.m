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
    
    // Need to use HTTP serializer because Flickr's feed
    // returns invalid JSON so the JSON serializer throws errors
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:@"http://api.flickr.com/services/feeds/photos_public.gne?format=json&lang=en-us&nojsoncallback=1&tags=sunset,landscape" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        
        //NSData *santizedData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        //Flickr incorrectly tries to escape single quotes - this is invalid JSON (see http://stackoverflow.com/a/2275428/423565)
        //correct by removing escape slash (note NSString also uses \ as escape character - thus we need to use \\)
         NSString *correctedJSONString = [operation.responseString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
        
        //re-encode the now correct string representation of JSON back to a NSData object which can be parsed by NSJSONSerialization
        NSData *correctedData = [correctedJSONString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *imagesDict = [NSJSONSerialization JSONObjectWithData:correctedData options:NSJSONReadingAllowFragments error:&error];
        
        if (error){
            if (newImageBlock) {
                newImageBlock(nil);
            }
            return;
        }
        
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
                 *  Only add the flickrImage if there is an image URL
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (newImageBlock) {
            newImageBlock(nil);
        }
    }];
}

@end
