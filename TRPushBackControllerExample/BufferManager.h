//
//  BufferManager.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BufferCompletion)(BOOL success);

@interface BufferManager : NSObject

- (void)postURLToBuffer:(NSURL *)URL completion:(BufferCompletion)completion;

@end
