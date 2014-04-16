//
//  FlickrViewController.m
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-15.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import "FlickrViewController.h"
#import "FlickrTableCell.h"
#import "FlickrManager.h"
#import "AppDelegate.h"
#import "FlickrImage.h"
#import "BufferManager.h"

@interface FlickrViewController ()

@property (nonatomic, strong) NSArray *flickrs;
@property (nonatomic, strong) FlickrManager *flickrManager;

@end

@implementation FlickrViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Buffer Pix";
    
    [self configureNavigationButtons];
    [self configureTable];
    [self configureFlickrManager];
    [self addPushObservers];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)configureNavigationButtons
{
    UIBarButtonItem *pushBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reloadImages)];
    [pushBackButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:pushBackButton];
}

- (void)configureTable
{
    //[self.table registerClass:[FlickrTableCell class] forCellReuseIdentifier:@"FlickrCell"];
    [self.table registerNib:[UINib nibWithNibName:@"FlickrTableCell" bundle:nil] forCellReuseIdentifier:@"FlickrCell"];
}

- (void)configureFlickrManager
{
    self.flickrManager = [[FlickrManager alloc] init];
}

- (void)addPushObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRefreshHUD) name:kNotificationDidPushBack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissRefreshHUD) name:kNotificationDidPullForward object:nil];
}

- (void)showRefreshHUD
{
    [SVProgressHUD showWithStatus:@"Getting fresh pics"];
}

- (void)dismissRefreshHUD
{
    [SVProgressHUD dismiss];
}

- (void)togglePush
{
    [[AppDelegate pushBackController] togglePush];
}

- (void)reloadImages
{
    [self togglePush];
    
    __weak FlickrViewController *weakSelf = self;
    [self.flickrManager getNewImages:^(NSArray *newFlickrImages) {
        
        if (!newFlickrImages) {
            
            [SVProgressHUD showErrorWithStatus:@"Oops, Flickr is being fickle. Try again."];
            [weakSelf togglePush];
            return;
        }

        weakSelf.flickrs = newFlickrImages;
        [weakSelf.table reloadData];
        [weakSelf togglePush];
        [SVProgressHUD dismiss];
    }];
}

- (void)bufferButtonTapped:(UIButton *)button
{
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:buttonPosition];

    if (indexPath) {
        FlickrImage *flickrImage = [self.flickrs objectAtIndex:indexPath.row];
        BufferManager *bufferManager = [[BufferManager alloc] init];
        
        [bufferManager postURLToBuffer:flickrImage.imageURL completion:^(BOOL success) {
            
        }];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 315.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrs count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrTableCell *flickrCell = (FlickrTableCell *)cell;
    [flickrCell.bufferButton setAlpha:0.0];
    [UIView animateKeyframesWithDuration:1.0 delay:1.5 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                [flickrCell.bufferButton setAlpha:1.0];
    } completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrCell" forIndexPath:indexPath];
    
    __block FlickrImage *flickrImage = [self.flickrs objectAtIndex:indexPath.row];
    
    [cell.bufferButton setAlpha:0.0];
    
    if (![[cell.bufferButton allTargets] containsObject:self]) {
        [cell.bufferButton addTarget:self action:@selector(bufferButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
     }
    
    if (flickrImage.image) {
        [cell.flickrImage setImage:flickrImage.image];
    }
    else {
        
        [cell.flickrImage setImage:nil];
        
        __weak FlickrTableCell *blockCell = cell;
        [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:flickrImage.imageURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            flickrImage.image = image;
            
            [UIView transitionWithView:blockCell.flickrImage
                              duration:1.0f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{[blockCell.flickrImage setImage:flickrImage.image];}
                            completion:^(BOOL finished) {
                            }];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    
    return cell;
}

@end
