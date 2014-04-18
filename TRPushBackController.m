//
//  TRPushBackController.m
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-13.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import "TRPushBackController.h"
#import <QuartzCore/QuartzCore.h>

#define kTagSnapshot     1111
#define kStatusBarHeight 20.0f

typedef NS_ENUM(BOOL, TRPushDirection) {
    TRPushDirectionPushBack = YES,
    TRPushDirectionPullForward = NO
};

NSString * const kNotificationWillPushBack    = @"kNotificationWillPushBack";
NSString * const kNotificationDidPushBack     = @"kNotificationDidPushBack";
NSString * const kNotificationWillPullForward = @"kNotificationWillPullForward";
NSString * const kNotificationDidPullForward  = @"kNotificationDidPullForward";

NSString *kAnimationIdentifierPushBack    = @"pushBackAnimation";
NSString *kAnimationIdentifierPullForward = @"pullForwardAnimation";

@interface TRPushBackController ()

@property (nonatomic) BOOL useImageForStatusBar;

@property (nonatomic, strong) Completion pushBackCompletion;
@property (nonatomic, strong) Completion pullForwardCompletion;

@end

@implementation TRPushBackController

#pragma mark - Convenience initializer

+ (instancetype)controller
{
    TRPushBackController *controller = [[TRPushBackController alloc] initWithNibName:@"TRPushBackController" bundle:nil];
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.zPosition = -4000;
}

- (IBAction)pushBackButtonTapped:(id)sender
{
    [self togglePush];
}

- (BOOL)prefersStatusBarHidden
{
    if (_useImageForStatusBar) {
        return YES;
    }
    
    if (self.rootViewController) {
        if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.rootViewController).topViewController prefersStatusBarHidden];
        }
        return [self.rootViewController prefersStatusBarHidden];
    }
    
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.rootViewController) {
        if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
            return [((UINavigationController *)self.rootViewController).topViewController preferredStatusBarStyle];
        }
        
        return [self.rootViewController preferredStatusBarStyle];
    }
    
    return UIStatusBarStyleDefault;
}

#pragma mark - Push back methods

- (void)togglePush
{
    if (self.isPushedBack) {
        [self pullForward];
    }
    else {
        [self pushBack];
    }
}

- (void)pushBackWithCompletion:(Completion)completion
{
    self.pushBackCompletion = completion;
    [self pushBack];
}

- (void)pullForwardWithCompletion:(Completion)completion
{
    self.pullForwardCompletion = completion;
    [self pullForward];
}

- (void)pushBack
{
    if (!self.isPushedBack) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWillPushBack object:nil];
        self.isPushedBack = YES;
        self.view.userInteractionEnabled = NO;
        [self useImageForStatusBar:YES];
        [self.view.layer addAnimation:[self pushAnimationGroup:TRPushDirectionPushBack] forKey:kAnimationIdentifierPushBack];
    }
}

- (void)pullForward
{
    if (self.isPushedBack) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWillPullForward object:nil];
        [self.view.layer addAnimation:[self pushAnimationGroup:TRPushDirectionPullForward] forKey:kAnimationIdentifierPullForward];
    }
}

- (void)setRootViewController:(UIViewController *)viewController
{
    if (_rootViewController && [[self childViewControllers] containsObject:_rootViewController]) {
        [_rootViewController willMoveToParentViewController:nil];
        [_rootViewController removeFromParentViewController];
    }
    
    _rootViewController = viewController;
    
    viewController.view.frame = self.view.bounds;
    [self.view addSubview:viewController.view];
    
    [self addChildViewController:_rootViewController];
    [_rootViewController didMoveToParentViewController:self];
}

- (void)setLeftViewController:(UIViewController *)viewController
{
    _leftViewController = viewController;
}

- (void)setRightViewController:(UIViewController *)viewController
{
    _rightViewController = viewController;
}

- (void)slide:(TRPushBackSliderDirection)direction
{
    
}

#pragma mark - Private methods

#define kAnimationDuration 0.6

-(CAAnimationGroup *)pushAnimationGroup:(TRPushDirection)pushDirection
{
    CATransform3D t1 = CATransform3DIdentity;
    CATransform3D t2 = CATransform3DIdentity;
    
    /**
     *  Set m34 to allow for a perspective rotation
     *  http://stackoverflow.com/questions/10913676/why-does-a-calayers-transform3ds-m34-need-to-be-modified-before-applying-the-r
     */
    t1.m34 = 1.0/-1000;
    t2.m34 = t1.m34;
    
    /**
     *  Rotate the top back 35 degrees
     */
    t1 = CATransform3DRotate(t1, 35.0f * M_PI/180.0f, 1, 0, 0);
    
    /**
     *  Simply scale down to complete the effect
     */
    t2 = CATransform3DScale(t2, 0.9, 0.9, 1);
    
    /**
     *  Setup the animations using the transforms
     */
    CABasicAnimation *firstHalfAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    firstHalfAnimation.toValue              = [NSValue valueWithCATransform3D:t1];
    firstHalfAnimation.duration             = kAnimationDuration/2;
    firstHalfAnimation.fillMode             = kCAFillModeForwards;
    firstHalfAnimation.removedOnCompletion  = NO;
    [firstHalfAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    NSValue *secondHalfToValue = [NSValue valueWithCATransform3D:((pushDirection == TRPushDirectionPushBack) ? t2 : CATransform3DIdentity)];
    
    CABasicAnimation *secondHalfAnimation   = [CABasicAnimation animationWithKeyPath:@"transform"];
    secondHalfAnimation.toValue             = secondHalfToValue;
    secondHalfAnimation.beginTime           = firstHalfAnimation.duration/2;
    secondHalfAnimation.duration            = firstHalfAnimation.duration;
    secondHalfAnimation.fillMode            = kCAFillModeForwards;
    secondHalfAnimation.removedOnCompletion = NO;
    [secondHalfAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    NSArray *animations = @[firstHalfAnimation,secondHalfAnimation];
    
    CAAnimationGroup *animationGroup   = [CAAnimationGroup animation];
    animationGroup.fillMode            = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.duration            = secondHalfAnimation.beginTime + secondHalfAnimation.duration;
    animationGroup.animations          = animations;
    animationGroup.delegate           = self;
    
    return animationGroup;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        
        self.view.userInteractionEnabled = YES;
        
        if (anim == [[self.view layer] animationForKey:kAnimationIdentifierPullForward]) {
            [self pullForwardDidComplete];
        }
        else {
            [self pushBackDidComplete];
        }
    }
}

- (void)pushBackDidComplete
{
    if (self.pushBackCompletion) {
        self.pushBackCompletion();
        self.pushBackCompletion = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidPushBack object:nil];
}

- (void)pullForwardDidComplete
{
    self.isPushedBack = NO;
    [self useImageForStatusBar:NO];
    
    if (self.pullForwardCompletion) {
        self.pullForwardCompletion();
        self.pullForwardCompletion = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidPullForward object:nil];
}

- (void)useImageForStatusBar:(BOOL)useImageForStatusBar
{
    self.useImageForStatusBar = useImageForStatusBar;
    
    if (self.useImageForStatusBar) {
        
        // Remove stale status bar image if it exists
        [[self.view viewWithTag:kTagSnapshot] removeFromSuperview];
        
        UIView *snapshot = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:YES];
        [snapshot setTag:kTagSnapshot];
        
        for (UIView *subview in [snapshot subviews]) {
            subview.contentMode = UIViewContentModeTop;
        }
        
        //crop to just the status bar
        snapshot.clipsToBounds = YES;
        snapshot.frame = CGRectMake(0, 0, snapshot.bounds.size.width, kStatusBarHeight);
        [self.view addSubview:snapshot];
        
        /**
         *  Sneaky workaround to keep navigationBars from shifting up when hiding
         *  the statusBar. This must happen before the status bar update.
         */
        self.rootViewController.view.frame = CGRectMake(0, 1, self.rootViewController.view.frame.size.width, self.rootViewController.view.frame.size.height);
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
    else {
        
        /**
         *  Sneaky workaround to keep navigationBars from shifting up when hiding
         *  the statusBar. This must happen before the status bar update.
         */
        self.rootViewController.view.frame = CGRectMake(0, 0, self.rootViewController.view.frame.size.width, self.rootViewController.view.frame.size.height);
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        [[self.view viewWithTag:kTagSnapshot] setAlpha:0.0];
        [[self.view viewWithTag:kTagSnapshot] removeFromSuperview];
    }
}

@end
