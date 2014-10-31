//
//  FaalViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "FaalViewController.h"
#import "HafezDataViewController.h"
#import "GANTracker.h"

@implementation FaalViewController
@synthesize delegate;

- (void)viewDidLoad {
    [[GANTracker sharedTracker] trackPageview:@"/ipad/faal" withError:nil];
}

- (IBAction)faalButton:(id)sender {
    [self.delegate faalDismissPopover];
    
    [[GANTracker sharedTracker] trackEvent:@"Faal"
                                    action:@"Click"
                                     label:@"Faal"
                                     value:-1
                                 withError:nil];
}

@end
