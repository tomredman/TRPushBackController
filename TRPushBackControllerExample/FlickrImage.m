//
//  FlickrImage.m
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import "FlickrImage.h"

@implementation FlickrImage

- (CGFloat)height
{
    static CGFloat height = kFlickrTableCellMaxHeight;
    
    if (self.image) {
        
        CGFloat ratio = 1.0;
        
        if (self.image.size.width >= self.image.size.height) {
            ratio = self.image.size.height / self.image.size.width;
        }
        else {
            ratio = self.image.size.width  / self.image.size.height;
        }
        
        height = kFlickrTableCellMaxHeight * ratio;
        
        if (height > kFlickrTableCellMaxHeight) {
            height = kFlickrTableCellMaxHeight;
        }
        
        if (height < kFlickrTableCellMinHeight) {
            height = kFlickrTableCellMinHeight;
        }
        
        return height;
    }
    
    return height;
}

@end
