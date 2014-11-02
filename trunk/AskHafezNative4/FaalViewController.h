//
//  FaalViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on 10/30/14.
//
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@protocol FaalDismissPopoverDelegate <NSObject>
-(void) faalDismissPopover;
@end


@interface FaalViewController : GAITrackedViewController
{
    __unsafe_unretained id<FaalDismissPopoverDelegate> delegate;
}

@property (nonatomic, assign) id<FaalDismissPopoverDelegate> delegate;
- (IBAction)faalButton:(id)sender;

@end