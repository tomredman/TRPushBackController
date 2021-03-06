//
//  FlickrImage.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFlickrTableCellMaxHeight 500.0f
#define kFlickrTableCellMinHeight 300.0f

@interface FlickrImage : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;

@property (nonatomic, strong) NSString *photographer;
@property (nonatomic, strong) NSString *title;

- (CGFloat)height;

@end
