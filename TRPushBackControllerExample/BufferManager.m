//
//  BufferManager.m
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import "BufferManager.h"

@implementation BufferManager

- (void)postURLToBuffer:(NSURL *)URL completion:(BufferCompletion)completion
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"bufferapp://?t=Test"]]) {
        
        NSString *urlEncodedMessage = @"Posted%20from%20Buffer%20Pix";
        NSString *urlString = [NSString stringWithFormat:@"bufferapp://?t=%@&u=%@", urlEncodedMessage, [URL absoluteString]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
        if (completion) {
            completion(YES);
        }
    }
    else {
        
        [SVProgressHUD showErrorWithStatus:@"Oops, gotta install the Buffer app!"];
        
        if (completion) {
            completion(NO);
        }
    }
}

@end
