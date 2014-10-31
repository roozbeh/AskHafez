//
//  FaalViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FaalDismissPopoverDelegate <NSObject>
-(void) faalDismissPopover;
@end

@interface FaalViewController : UIViewController
{
    __unsafe_unretained id<FaalDismissPopoverDelegate> delegate;
}

@property (nonatomic, assign) id<FaalDismissPopoverDelegate> delegate;
- (IBAction)faalButton:(id)sender;

//@property (assign, nonatomic) id parentViewController;

//- (void)setParentController:(UIViewController*)parent;
@end
