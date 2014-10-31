//
//  GhazalViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on 2/8/14.
//
//

#import <UIKit/UIKit.h>

@interface GhazalViewController : UIViewController

@property NSArray *faLabelArray;
@property NSArray *enLabelArray;
@property int ghazalNumber;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)onBackBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblGhazamNumber;
- (IBAction)onFacebookShare:(id)sender;
@end
