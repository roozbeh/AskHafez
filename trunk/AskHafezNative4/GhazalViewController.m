//
//  GhazalViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on 2/8/14.
//
//

#import "GhazalViewController.h"
#import <Social/Social.h>
#import "GAIDictionaryBuilder.h"

@interface GhazalViewController ()

@end

@implementation GhazalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self fillGhazalContainerView];
    _lblGhazamNumber.text = [NSString stringWithFormat:@"%d", (_ghazalNumber+1)];
    self.screenName = [NSString stringWithFormat:@"/iphone/Ghazal-%d", _ghazalNumber] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) fillGhazalContainerView
{
    int y = 5;
    
    for (int i=0; i < [_faLabelArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, y, _scrollview.frame.size.width-10, 20)];
        label.text = [NSString stringWithFormat:@"%@",[_faLabelArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = (i%2) ? NSTextAlignmentLeft : NSTextAlignmentRight;
        label.font =[UIFont fontWithName:@"Arial" size:12];
        [_scrollview addSubview:label];
        y=y+((i%2) ? 25 : 20);
    }
    
    y=y+25;
    
    for (int i=0; i < [_enLabelArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(((i%2) ? 20 : 5), y, _scrollview.frame.size.width-20, 20)];
        label.text = [NSString stringWithFormat:@"%@",[_enLabelArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = NSTextAlignmentLeft;
        label.font =[UIFont fontWithName:@"Arial" size:12];
        label.adjustsFontSizeToFitWidth = NO;
        label.numberOfLines = 0;
        [label sizeToFit];
        [_scrollview addSubview:label];
        y = y + label.frame.size.height +((i%2) ? 5 : 0);
    }
    
    _scrollview.contentSize = CGSizeMake(_scrollview.frame.size.width, y+20);
}

- (IBAction)onBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onFacebookShare:(id)sender {

    NSMutableString *ghazalText = [[NSMutableString alloc] init];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Faal"
                                                          action:@"Click"
                                                           label:@"FacebookShare"
                                                           value:nil] build]];
    
    for (int i=0; i < [_faLabelArray count]; i++) {
        [ghazalText appendString:[_faLabelArray objectAtIndex:i]];
        if (i%2) {
            [ghazalText appendString:@"\n"];
        } else {
            [ghazalText appendString:@" ... "];
        }
    }
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setTitle:@"Hafez Ghazal - غزل حافظ"];
    [controller setInitialText:ghazalText];
    [controller setInitialText:ghazalText];
    [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/ask-hafez/id558114091?mt=8"]];
    
    [self presentViewController:controller animated:YES completion:Nil];
}
@end
