//
//  HafezSecondViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۴.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "FaalPhoneViewController.h"
#import "GhazalsViewController.h"
#import "GAIDictionaryBuilder.h"

//#import <GADBannerView.h>
//#import "GADRequest.h"
@import GoogleMobileAds;

@implementation FaalPhoneViewController
@synthesize lblPersianDesc;
@synthesize lblEnglishDesc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Divination فاال", @"Divination فاال");
        self.tabBarItem.image = [UIImage imageNamed:@"dice.png"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) manageOrientation: (UIInterfaceOrientation)orientation
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        lblPersianDesc.frame = CGRectMake(49, 58, 222, 60);
        lblEnglishDesc.frame = CGRectMake(49, 128, 222, 100);
        _btnFaal.frame = CGRectMake(80, 234, 160, 130);
    } else {
        lblPersianDesc.frame = CGRectMake(67, 29, height-2*67, 40);
        lblEnglishDesc.frame = CGRectMake(67, 79, height-2*67, 60);
        _btnFaal.frame = CGRectMake((height-86)/2, 140, 106, 86);
    }
}

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    NSLog(@"adViewDidReceiveAd");
}

/// Called when an ad request failed. Normally this is because no network connection was available
/// or no ads were available (i.e. no fill). If the error was received as a part of the server-side
/// auto refreshing, you can examine the hasAutoRefreshed property of the view.
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"didFailToReceiveAdWithError: %@", error);
}


- (void) initAd
{
    self.bannerView.adUnitID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"AdMobs"];
    
    self.bannerView.rootViewController = self;
    _bannerView.delegate = self;
    
    GADRequest *request = [GADRequest request];
    // Enable test ads on simulators.
    [self.bannerView loadRequest:request];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"/faal";

    dispatch_async(dispatch_get_main_queue(), ^{
        // Your code to run on the main queue/thread
            [self initAd];
    });
    
    [self manageOrientation: [[UIDevice currentDevice] orientation]];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLblPersianDesc:nil];
    [self setLblEnglishDesc:nil];
    [self setBtnFaal:nil];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)cmdFaal:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Button"
                                                          action:@"Click"
                                                           label:@"Faal"
                                                           value:nil] build]];
    GhazalsViewController *firstView =  [[[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
//    HafezFirstViewController *firstView = [[[self tabBarController] viewControllers] objectAtIndex:0];
    [firstView randomizeView];
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:0];
    [nav popToRootViewControllerAnimated:NO];
    [[self tabBarController] setSelectedIndex:0];
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation");

    [self manageOrientation:orientation];
}

@end

