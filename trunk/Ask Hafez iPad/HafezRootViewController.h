//
//  HafezRootViewController.h
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HafezDataViewController.h"

@interface HafezRootViewController : UIViewController <UIPageViewControllerDelegate>
{
}
@property (strong, nonatomic) UIPageViewController *pageViewController;

- (void) setRandomPage;
- (void) setSpecialPage:(int) ghazalNumber;

@end
