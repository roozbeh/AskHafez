//
//  HafezDataViewController.h
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaalViewController.h"
#import "HafezSearchViewController.h"

@interface HafezDataViewController: UIViewController <FaalDismissPopoverDelegate, SearchDismissPopoverDelegate>
{
    UIPopoverController *m_faalPopover;
    UIPopoverController *m_searchPopover;
}
@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) NSArray *enArray;
@property (strong, nonatomic) NSArray * faArray;
@property (strong, nonatomic) id ghazalNumber;

@property (strong, nonatomic) id rootController;

-(void)dismissPopover;

@end
