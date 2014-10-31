//
//  HafezSecondViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۴.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HafezSecondViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblPersianDesc;
@property (strong, nonatomic) IBOutlet UILabel *lblEnglishDesc;
- (IBAction)cmdFaal:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnFaal;

@end
