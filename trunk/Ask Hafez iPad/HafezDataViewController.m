//
//  HafezDataViewController.m
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱3۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "HafezDataViewController.h"
#import "FaalViewController.h"
#import "HafezRootViewController.h"

@implementation HafezDataViewController

@synthesize dataLabel = _dataLabel;
@synthesize enArray;
@synthesize faArray;
@synthesize ghazalNumber;
@synthesize rootController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [_btnSearch setBackgroundImage:[UIImage imageNamed:@"search_b.png"] forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) createViewForGhazal
{
    
    NSLog(@"createViewForGhazal started for %d!", [ghazalNumber intValue]);
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:
                                CGRectMake(102,177, 559, 711)];
    int y = 5;
    
    int totalWidth = [scrollview frame].size.width-10   ;
    
    for (int i=0; i < [faArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, y, totalWidth, 20)];
        label.text = [NSString stringWithFormat:@"%@",[faArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = (i%2) ? UITextAlignmentLeft : UITextAlignmentRight;
        label.font =[UIFont fontWithName:@"Arial" size:16];
        [scrollview addSubview:label];
        y=y+((i%2) ? 35 : 25);
    }
    
    y=y+35;
    
    for (int i=0; i < [enArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(
                                  ((i%2) ? totalWidth*0.1 : totalWidth*0.02), y, totalWidth*0.9, 20)];
        label.text = [NSString stringWithFormat:@"%@",[enArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = UITextAlignmentLeft;
        label.font =[UIFont fontWithName:@"Arial" size:16];
        label.adjustsFontSizeToFitWidth = NO;
        label.numberOfLines = 0;
        [label sizeToFit];
        [scrollview addSubview:label];
        y = y + label.frame.size.height +((i%2) ? 15 : 10);
    }
    
    scrollview.contentSize = CGSizeMake(totalWidth, y+20);
    //    scrollview.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    //    scrollview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    NSLog(@"createViewForGhazal ent!");
    
    [[self view] addSubview:scrollview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = 
        [NSString stringWithFormat:@"Ghazal #%d", [ghazalNumber intValue]];
    
    [self createViewForGhazal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (IBAction)searchButton:(id)sender {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FaalViewSeque"]) { // set in Storyboard
        m_faalPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        FaalViewController *faalView = (FaalViewController*) (m_faalPopover.contentViewController);
        faalView.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"SearchViewSeque"]) { // set in Storyboard
        m_searchPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        HafezSearchViewController *searchView = (HafezSearchViewController*) (m_searchPopover.contentViewController);
        searchView.delegate = self;
    }
}


-(void)faalDismissPopover
{
    [m_faalPopover dismissPopoverAnimated:YES];
    HafezRootViewController *root = rootController;
    [root setRandomPage];
}

-(void)searchDismissPopover:(int) ghazalNumber
{
    [m_searchPopover dismissPopoverAnimated:YES];
    HafezRootViewController *root = rootController;
    [root setSpecialPage:ghazalNumber];
}

@end
