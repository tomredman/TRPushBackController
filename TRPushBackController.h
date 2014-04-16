//
//  TRPushBackController.h
//  TRPushBackControllerExample
//
//  Created by Tom Redman on 2014-04-13.
//  Copyright (c) 2014 Tom Redman. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kNotificationWillPushBack;
extern NSString * const kNotificationDidPushBack;
extern NSString * const kNotificationWillPullForward;
extern NSString * const kNotificationDidPullForward;

typedef NS_ENUM(NSInteger, TRPushBackSliderDirection) {
    TRPushBackSliderDirectionLeft = 0,
    TRPushBackSliderDirectionRight
};

@interface TRPushBackController : UIViewController

@property (nonatomic) CGFloat pushBackDistance;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

@property (nonatomic, weak) IBOutlet UIButton *pushBackButton;

- (IBAction)pushBackButtonTapped:(id)sender;

/**-----------------------------------------------------------------------------
 * @name Convenience initializer
 * -----------------------------------------------------------------------------
 */

/** Returns a new `TRPushBackController` instance, using the default xib file.
 *
 * @return A new `TRPushBackController` instance.
 */
+ (instancetype)controller;

/**-----------------------------------------------------------------------------
 * @name Pushing and pulling
 * -----------------------------------------------------------------------------
 */

/** Performs the push back or pull forward animation as required.
 */
- (void)togglePush;

/** Performs the push back animation.
 *
 * The method fires the `kNotificationWillPushBack` and
 * `kNotificationDidPushBack` notifications.
 */
- (void)pushBack;

/** Performs the pull forward animation
 *
 * The method fires the `kNotificationWillPullForward` and
 * `kNotificationDidPullForward` notifications.
 */
- (void)pullForward;

/**-----------------------------------------------------------------------------
 * @name Adding root, left and right view controllers
 * -----------------------------------------------------------------------------
 */

/** Adds the root view controller as a child view controller of
 *  TRPushBackController.
 *
 * This method will add the viewController provider as a childViewController
 * of the TRPushBackController instance.
 *
 * This is your app's main view controller and fills the entire 
 * TRPushBackController (e.g., UINavigationController or UITableViewController)
 *
 * If set, prefersStatusBarHidden and preferredStatusBarStyle will return this
 * view controllers respective values.
 *
 * @param viewController The UIViewController to add as the root of the
 * TRPushBackController
 */
- (void)setRootViewController:(UIViewController *)viewController;

/** Adds the left view controller as a child view controller of 
 *  TRPushBackController.
 *
 * This method will add the viewController provider as a childViewController
 * of the TRPushBackController instance. It will be offset by 50pt and will
 * move relatively to it's final position as the TRPushBackController is dragged
 * or toggled by `revealViewControllerInDirection:`
 *
 * @param viewController The UIViewController to add to the left side of the
 * TRPushBackController
 *
 * @see slide:
 */
- (void)setLeftViewController:(UIViewController *)viewController;

/** Adds the right view controller as a child view controller of
 *  TRPushBackController.
 *
 * This method will add the viewController provider as a childViewController
 * of the TRPushBackController instance. It will be offset by 50pt and will
 * move relatively to it's final position as the TRPushBackController is dragged
 * or toggled by `revealViewControllerInDirection:`
 *
 * @param viewController The UIViewController to add to the right side of the
 * TRPushBackController
 *
 * @see slide:
 */
- (void)setRightViewController:(UIViewController *)viewController;

/** Slides the TRPushBackController to the side inidicated
 *
 * @param direction The direction of the UIViewController to reveal
 */
- (void)slide:(TRPushBackSliderDirection)direction;


@end
