//
//  FlickrManager.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NewImageBlock)(NSArray *newFlickrImages);

@interface FlickrManager : NSObject

- (void)getNewImagesWithSearchTerm:(NSString *)searchTerm completion:(NewImageBlock)newImageBlock;

@end
