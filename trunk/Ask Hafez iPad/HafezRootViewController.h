//
//  HafezRootViewController.h
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HafezDataViewController.h"
#import <iAd/iAd.h>

@interface HafezRootViewController : UIViewController <UIPageViewControllerDelegate, ADBannerViewDelegate>
{
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
}
@property (strong, nonatomic) UIPageViewController *pageViewController;

- (void) setRandomPage;
- (void) setSpecialPage:(int) ghazalNumber;

@end
