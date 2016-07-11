//
//  FaalViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on 10/30/14.
//
//

#import "FaalViewController.h"
#import "GAIDictionaryBuilder.h"

@interface FaalViewController ()

@end

@implementation FaalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"/faal";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)faalButton:(id)sender {
    [self.delegate faalDismissPopover];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Faal"
                                                          action:@"Click"
                                                           label:@"Faal"
                                                           value:nil] build]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    _adBanner.delegate = self;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
        
        [self trackEvent:@"show-ad" withCat:@"show" withLabel:@"faal" withValue:nil];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    [self trackEvent:@"show-ad" withCat:@"no-ad" withLabel:@"faal" withValue:nil];
    
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

@end

//
//- (void)viewDidLoad {
//    [[GANTracker sharedTracker] trackPageview:@"/ipad/faal" withError:nil];
//}
//
//- (IBAction)faalButton:(id)sender {
//    [self.delegate faalDismissPopover];
//    
//    [[GANTracker sharedTracker] trackEvent:@"Faal"
//                                    action:@"Click"
//                                     label:@"Faal"
//                                     value:-1
//                                 withError:nil];
//
//
//@end
