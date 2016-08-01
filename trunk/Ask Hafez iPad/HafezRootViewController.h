//
//  HafezRootViewController.h
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HafezDataViewController.h"
@import FBAudienceNetwork;

@interface HafezRootViewController : UIViewController <UIPageViewControllerDelegate, FBAdViewDelegate>
{
    FBAdView *adView;
}
@property (strong, nonatomic) UIPageViewController *pageViewController;

- (void) setRandomPage;
- (void) setSpecialPage:(int) ghazalNumber;

@end
