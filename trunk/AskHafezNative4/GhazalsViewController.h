//
//  HafezFirstViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۴.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "iCarousel.h"
#import "GAI.h"

@import FBAudienceNetwork;

@class GADBannerView;

@interface GhazalsViewController : GAITrackedViewController<UIScrollViewDelegate, iCarouselDataSource, iCarouselDelegate, FBAdViewDelegate>
{
    sqlite3 *m_database;
    int m_ghzalCnt;
    int m_ghazalPointer;
    NSArray *m_scrollViews;
    UIScrollView *srcMainBrowser;
    //43,46 - 233, 317
    
    UIInterfaceOrientation currOrtientation;
    BOOL _bannerIsVisible;
//    ADBannerView *_adBanner;
    FBAdView *adView;
}

//@property (strong, nonatomic) IBOutlet UIScrollView *srcMainBrowser;

- (void) randomizeView;
- (sqlite3*) getDB;
- (void) navigateToView:(int) ghazal_number;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgDownConstraint;
@property (strong, nonatomic) IBOutlet UIView *viewMaster;

+ (GhazalsViewController *) instance;

- (void) viewGhazal:(NSString *) ghazalNumber;
@end
