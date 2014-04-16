//
//  FlickrImage.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrImage : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *photographer;
@property (nonatomic, strong) NSURL *imageURL;

@end
