//
//  FlickrViewController.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRPushBackController.h"

@interface FlickrViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *table;

@end
