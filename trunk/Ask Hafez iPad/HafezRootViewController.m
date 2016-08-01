//
//  HafezRootViewController.m
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "HafezRootViewController.h"

#import "HafezModelController.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface HafezRootViewController ()
@property (readonly, strong, nonatomic) HafezModelController *modelController;
@end

@implementation HafezRootViewController

@synthesize pageViewController = _pageViewController;
@synthesize modelController = _modelController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) setSpecialPage:(int) ghazalNumber
{
    HafezDataViewController *startingViewController = [self.modelController viewControllerAtIndex:ghazalNumber storyboard:self.storyboard];
    
    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/ipad/Ghazal-%d", ghazalNumber]];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void) setRandomPage
{
    int r = arc4random() % [[self modelController] getGhazalCount];
    [self setSpecialPage:r];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    [self setSpecialPage:0];
//    HafezDataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
//    
//    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
//    pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];    

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self loadFacebookAd];
}

- (void) trackEvent:(NSString *) eventName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ads"
                                                          action:eventName
                                                           label:@"ghazal"
                                                           value:nil] build]];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    return YES;
}


- (HafezModelController *)modelController
{
    /*
     Return the model controller object, creating it if necessary.
     In more complex implementations, the model controller may be passed to the view controller.
     */
    if (!_modelController) {
        _modelController = [[HafezModelController alloc] init];
        _modelController.rootController = self;
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

/*
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        // In portrait orientation: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        UIViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [NSArray arrayWithObject:currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    HafezDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:currentViewController, nextViewController, nil];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:previousViewController, currentViewController, nil];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];


    return UIPageViewControllerSpineLocationMid;
}

- (void) loadFacebookAd {
    // Create a banner's ad view with a unique placement ID (generate your own on the Facebook app settings).
    // Use different ID for each ad placement in your app.
    BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    FBAdSize adSize = isIPAD ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    adView = [[FBAdView alloc] initWithPlacementID:@"1260704423969786_1260705903969638"
                                            adSize:adSize
                                rootViewController:self];
    
    // Set a delegate to get notified on changes or when the user interact with the ad.
    adView.delegate = self;
    
    // When testing on a device, add its hashed ID to force test ads.
    // The hash ID is printed to console when running on a device.
    // [FBAdSettings addTestDevice:@"THE HASHED ID AS PRINTED TO CONSOLE"];
    
    // Initiate a request to load an ad.
    [adView loadAd];
    
    // Reposition the adView to the bottom of the screen
    CGSize viewSize = self.view.bounds.size;
    CGSize tabBarSize = self.tabBarController.tabBar.frame.size;
    viewSize = CGSizeMake(viewSize.width, viewSize.height - tabBarSize.height);
    CGFloat bottomAlignedY = viewSize.height - adSize.size.height;
    adView.frame = CGRectMake(0, bottomAlignedY, viewSize.width, adSize.size.height);
    
    // Set autoresizingMask so the rotation is automatically handled
    adView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    
    
    // Add adView to the view hierarchy.
    [_pageViewController.view addSubview:adView];
}

- (void)adViewDidLoad:(FBAdView *)adViewRef
{
    NSLog(@"Ad was loaded.");
    // Now that the ad was loaded, show the view in case it was hidden before.
    adView.hidden = NO;
    
    [self trackEvent:@"fb-ad-loaded"];
    
}

- (void)adView:(FBAdView *)adViewRef didFailWithError:(NSError *)error
{
    NSLog(@"Ad failed to load with error: %@", error);
    
    // Hide the unit since no ad is shown.
    adView.hidden = YES;
    [self trackEvent:@"fb-ad-failed"];
}



@end
