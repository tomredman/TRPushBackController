//
//  FlickrTableCell.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFlickrTableCellHeight 400.0f

@interface FlickrTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *bufferButton;
@property (nonatomic, weak) IBOutlet UIImageView *flickrImage;

- (IBAction)bufferButtonTapped:(id)sender;

@end
