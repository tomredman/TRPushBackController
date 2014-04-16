//
//  AppDelegate.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-13.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRPushBackController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TRPushBackController *pushBackController;

+ (TRPushBackController *)pushBackController;

@end
