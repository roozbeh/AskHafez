//
//  FaalViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on 10/30/14.
//
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import <iAd/iAd.h>

@protocol FaalDismissPopoverDelegate <NSObject>
-(void) faalDismissPopover;
@end


@interface FaalViewController : GAITrackedViewController<ADBannerViewDelegate>
{
    __unsafe_unretained id<FaalDismissPopoverDelegate> delegate;
    
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
}

@property (nonatomic, assign) id<FaalDismissPopoverDelegate> delegate;
- (IBAction)faalButton:(id)sender;

@end