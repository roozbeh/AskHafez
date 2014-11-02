//
//  FaalViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on 10/30/14.
//
//

#import "FaalViewController.h"
#import "GAIDictionaryBuilder.h"

@interface FaalViewController ()

@end

@implementation FaalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenName = @"/faal";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)faalButton:(id)sender {
    [self.delegate faalDismissPopover];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Faal"
                                                          action:@"Click"
                                                           label:@"Faal"
                                                           value:nil] build]];
}

@end

//
//- (void)viewDidLoad {
//    [[GANTracker sharedTracker] trackPageview:@"/ipad/faal" withError:nil];
//}
//
//- (IBAction)faalButton:(id)sender {
//    [self.delegate faalDismissPopover];
//    
//    [[GANTracker sharedTracker] trackEvent:@"Faal"
//                                    action:@"Click"
//                                     label:@"Faal"
//                                     value:-1
//                                 withError:nil];
//
//
//@end
