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
    
    [self configureNavigationTitle];
    [self configureNavigationButtons];
    [self configureTable];
    [self configureFlickrManager];
    [self reloadImagesWithQuery:nil pushBack:NO];
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
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)configureNavigationTitle
{
    UIButton *navTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navTitleButton.frame = CGRectMake(0, 0, 100, 44);
    [navTitleButton setImage:[UIImage imageNamed:@"buffer-nav"] forState:UIControlStateNormal];
    [navTitleButton addTarget:self action:@selector(togglePush) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = navTitleButton;
}

- (void)configureNavigationButtons
{
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(reloadImages)];
    [refreshButton setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.navigationItem setRightBarButtonItem:refreshButton];
}

- (void)configureTable
{
    /**
     *  TODO: Optimize for 3.5" devices
     */
    [self.table registerNib:[UINib nibWithNibName:@"FlickrTableCell" bundle:nil] forCellReuseIdentifier:@"FlickrCell"];
}

- (void)configureFlickrManager
{
    self.flickrManager = [[FlickrManager alloc] init];
}

- (void)showRefreshHUD
{
    [SVProgressHUD showWithStatus:@"Getting fresh pix"];
}

- (void)dismissRefreshHUD
{
    [SVProgressHUD dismiss];
}

- (void)togglePush
{
    if ([[AppDelegate pushBackController] isPushedBack]) {
        [self pullForwardCancelHUD:NO];
    }
    else {
        [self pushBackShowHUD:NO];
    }
}

- (void)pullForwardCancelHUD:(BOOL)cancelHUD
{
    __weak FlickrViewController *weakSelf = self;
    [[AppDelegate pushBackController] pullForwardWithCompletion:^{
        if (cancelHUD) {
            [weakSelf dismissRefreshHUD];
        }
    }];
}

- (void)pullForward
{
    [self pullForwardCancelHUD:NO];
}

- (void)pushBackShowHUD:(BOOL)showHUD
{
    __weak FlickrViewController *weakSelf = self;
    [[AppDelegate pushBackController] pushBackWithCompletion:^{
        if (showHUD) {
            [weakSelf showRefreshHUD];
        }
    }];
}

- (void)pushBack
{
    [self pushBackShowHUD:NO];
}

- (void)reloadImagesWithQuery:(NSString *)query pushBack:(BOOL)pushBackToggle
{
    if (pushBackToggle) {
        [self pushBackShowHUD:YES];
    }
    
    __weak FlickrViewController *weakSelf = self;
    
    static NSInteger retryCount    = 0;
    static NSInteger maxRetryCount = 5;
    
    NSDate *startTime = [NSDate date];
    
    [self.flickrManager getNewImagesWithSearchTerm:query completion:^(NSArray *newFlickrImages) {
        
        /**
         *  Handle bad Flickr feed
         */
        if (!newFlickrImages) {
            
            retryCount++;
            
            if (retryCount == maxRetryCount) {
                retryCount = 0;
                [SVProgressHUD showErrorWithStatus:@"Darn. We tried and failed. Feel free to hit Refresh."];
                [weakSelf pullForwardCancelHUD:YES];
                return;
            }
            
            NSString *status = [NSString stringWithFormat:@"Oops, Flickr is being fickle. Trying again...\n\n%ld of %ld", (long)retryCount, (long)maxRetryCount];
            [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
            
            // Recurse back here
            [weakSelf reloadImages];
            
            return;
        }
        
        /**
         *  Success!
         */
        NSTimeInterval elapsedTime = -[startTime timeIntervalSinceNow];
        CGFloat delay = 0.0f;
        
        if (elapsedTime < 1.0) {
            delay = 2.0f;
        }
        
        [weakSelf newImagesSuccess:newFlickrImages delay:delay];
    }];
}

- (void)newImagesSuccess:(NSArray *)newImages delay:(CGFloat)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.indicator stopAnimating];
        self.flickrs = newImages;
        [self.table reloadData];
        [self pullForwardCancelHUD:YES];
    });
}

- (void)reloadImages
{
    [self reloadImagesWithQuery:nil pushBack:YES];
}

- (void)reloadImagesWithQuery:(NSString *)query
{
    [self reloadImagesWithQuery:query pushBack:YES];
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrImage *flickrImage = [self.flickrs objectAtIndex:indexPath.row];
    return [flickrImage height];
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
    [flickrCell.photographerLabel setAlpha:0.0];
    [flickrCell.titleLabel setAlpha:0.0];
    
    [UIView animateKeyframesWithDuration:1.0 delay:1.5 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
                [flickrCell.bufferButton setAlpha:1.0];
    } completion:nil];
    
    [UIView animateKeyframesWithDuration:1.0 delay:2.5 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        if (flickrCell.photographerLabel.text) {
            [flickrCell.photographerLabel setAlpha:1.0];
        }
        if (flickrCell.titleLabel.text) {
            [flickrCell.titleLabel setAlpha:1.0];
        }
    } completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlickrTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrCell" forIndexPath:indexPath];
    
    __block FlickrImage *flickrImage = [self.flickrs objectAtIndex:indexPath.row];
    
    [cell.bufferButton setAlpha:0.0];
    
    if (flickrImage.photographer) {
        cell.photographerLabel.text = [NSString stringWithFormat:@"  by %@", flickrImage.photographer];
    }
    else {
        cell.photographerLabel.text = nil;
    }
    
    if (flickrImage.title) {
        cell.titleLabel.text = [NSString stringWithFormat:@"  %@", flickrImage.title];
    }
    else {
        cell.titleLabel.text = nil;
    }
    
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
                            animations:^{
                                //Update height to match new image
                                [self.table beginUpdates];
                                [self.table endUpdates];
                                [blockCell.flickrImage setImage:flickrImage.image];
                            }
                            completion:^(BOOL finished) {
                            }];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSString *query = searchBar.text;
    NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [query stringByTrimmingCharactersInSet:charSet];
    
    if ([trimmedString isEqualToString:@""]) {
        searchBar.text = nil;
        return;
    }
    
    [self reloadImagesWithQuery:query];
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

@end
