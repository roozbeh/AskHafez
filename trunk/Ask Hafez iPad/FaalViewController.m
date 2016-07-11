//
//  FaalViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "FaalViewController.h"
#import "HafezDataViewController.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

@implementation FaalViewController
@synthesize delegate;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.screenName = @"/ipad/faal";
}

- (IBAction)faalButton:(id)sender {
    [self.delegate faalDismissPopover];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Faal"
                                                          action:@"Click"
                                                           label:@"Faal"
                                                           value:nil] build]];

}

@end
