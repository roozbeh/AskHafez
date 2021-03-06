//
//  HafezFirstViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۴.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#import "GhazalsViewController.h"
#import "CommonUtils.h"
#import "GhazalViewController.h"
#import <Social/Social.h>
#import "GAIDictionaryBuilder.h"
#import "HafezAppDelegate.h"

#import "HafezAPI.h"

//#import "GADBannerView.h"
//#import "GADRequest.h"

static GhazalsViewController *gInstance = NULL;

@implementation GhazalsViewController

+ (GhazalsViewController *) instance {
    return(gInstance);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Sonnet غزل", @"Sonnet غزل");
        self.tabBarItem.image = [UIImage imageNamed:@"ghazal.png"];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (Boolean) loadDB
{
    NSString *databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ghazals.sqlite"];
    if (sqlite3_open([databasePath UTF8String], &m_database) == SQLITE_OK) {
        NSLog(@"database open!");
        return true;
    }
    
    return false;
}

- (sqlite3*) getDB
{
    return m_database;
}

- (NSArray *) getGhazals:(int) ghazalNumber lang:(int) langID
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init ];
    // Create the query statement to get all persons
    NSString *queryStatement = [NSString stringWithFormat:
                                @"select mesra from ghazals where ghazal_id = %d and lang = %d order by id;", ghazalNumber, langID];
    // Prepare the query for execution
    sqlite3_stmt *statement;
    int res = sqlite3_prepare_v2(m_database, [queryStatement UTF8String], -1, &statement, NULL);
    if (res == SQLITE_OK)
    {
        // Iterate over all returned rows
        while (sqlite3_step(statement) == SQLITE_ROW) {
            [retArray addObject:[NSString stringWithFormat:@"%S", sqlite3_column_text16(statement, 0)]];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Error in calculating ghazal count");
    }
    
    return retArray;
}

- (UIView *) createViewForGhazal:(int) ghazalNumber
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    CGRect scrollViewRect = srcMainBrowser.frame;
    scrollViewRect.origin.x++;
    scrollViewRect.origin.y++;
    scrollViewRect.size.width-=2;
    scrollViewRect.size.height-=2;
    
    NSLog(@"Width: %d, Height: %d", (int) width, (int) height);
    
    NSLog(@"createViewForGhazal started for %d!", ghazalNumber);
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    int y = 5;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, y, 200, 20)];
    label.text = [NSString stringWithFormat:@"Ghazal #%d",(ghazalNumber+1)];
    label.font =[UIFont fontWithName:@"Arial" size:12];
    y=y+25;
    [scrollview addSubview:label];
    
    
    NSArray *faLabelArray = [self getGhazals:ghazalNumber lang:1];
    NSArray *enLabelArray = [self getGhazals:ghazalNumber lang:2];
    
    for (int i=0; i < [faLabelArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, y, scrollViewRect.size.width-10, 20)];
        label.text = [NSString stringWithFormat:@"%@",[faLabelArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = (i%2) ? UITextAlignmentLeft : UITextAlignmentRight;
        label.font =[UIFont fontWithName:@"Arial" size:12];
        [scrollview addSubview:label];
        y=y+((i%2) ? 25 : 20);
    }
    
    y=y+25;
    
    for (int i=0; i < [enLabelArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(((i%2) ? 20 : 5), y, scrollViewRect.size.width-20, 20)];
        label.text = [NSString stringWithFormat:@"%@",[enLabelArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = UITextAlignmentLeft;
        label.font =[UIFont fontWithName:@"Arial" size:12];
        label.adjustsFontSizeToFitWidth = NO;
        label.numberOfLines = 0;
        [label sizeToFit];
        [scrollview addSubview:label];
        y = y + label.frame.size.height +((i%2) ? 5 : 0);
    }
    
    scrollview.contentSize = CGSizeMake(scrollview.frame.size.width-4, y+20);
    //    scrollview.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    //    scrollview.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    NSLog(@"createViewForGhazal ent!");
    return scrollview;
}

- (void) initViewsForCursor:(int) ghazalNumber
{
    for (UIView *v in [srcMainBrowser subviews]) {
        [v removeFromSuperview];       
    }
    
    int xPos = 0;

    NSMutableArray *viewsArray = [[NSMutableArray alloc] init];
    
    int ghazal_number = ((ghazalNumber-1)%m_ghzalCnt);
    for (int i=0;i<3;i++, ghazal_number=(ghazal_number+1)%m_ghzalCnt) {
        UIView *view = [self createViewForGhazal:ghazal_number];
        view.frame = CGRectMake(xPos, 0.0, [srcMainBrowser frame].size.width, [srcMainBrowser frame].size.height);
        
        [srcMainBrowser addSubview:view];
        xPos += [srcMainBrowser frame].size.width;
        [viewsArray addObject:view];
    }
    m_scrollViews = viewsArray;
    
    self.screenName = [NSString stringWithFormat:@"Ghazal-%d", ghazalNumber];
}

- (void) calcGhazalCnt
{
    m_ghzalCnt = 0;
    
    // Create the query statement to get all persons
    NSString *queryStatement = @"select count(distinct ghazal_id)  from ghazals;";
    // Prepare the query for execution
    sqlite3_stmt *statement;
    int res = sqlite3_prepare_v2(m_database, [queryStatement UTF8String], -1, &statement, NULL);
    if (res == SQLITE_OK)
    {
        // Iterate over all returned rows
        if (sqlite3_step(statement) == SQLITE_ROW) {
            
            // Get associated address of the current person row
            m_ghzalCnt = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Error in calculating ghazal count");
    }
}

- (void) initViews
{
    srcMainBrowser.contentSize =  CGSizeMake([srcMainBrowser frame].size.width*3, [srcMainBrowser frame].size.height);
    [srcMainBrowser setContentOffset:CGPointMake([srcMainBrowser frame].size.width, 0)];
    [self initViewsForCursor:m_ghazalPointer];
    srcMainBrowser.delegate = self;
}

- (void) randomizeView
{
    int r = arc4random() % m_ghzalCnt;
    m_ghazalPointer = r;
//    [self initViewsForCursor:r];
    [_carousel scrollToItemAtIndex:m_ghazalPointer animated:YES];
}

- (void) navigateToView:(int) ghazal_number
{
    m_ghazalPointer = ghazal_number;
    [_carousel scrollToItemAtIndex:ghazal_number animated:YES];
//    [self initViewsForCursor:ghazal_number];
}

- (void) scrollRight
{
    UIView *first = [m_scrollViews objectAtIndex:0];
    UIView *second = [m_scrollViews objectAtIndex:1];
    UIView *third = [m_scrollViews objectAtIndex:2];
    [first removeFromSuperview];
    [second removeFromSuperview];
    [third removeFromSuperview];
    second.frame = CGRectMake(0, 0, [srcMainBrowser frame].size.width, 
                      [srcMainBrowser frame].size.height);
    third.frame = CGRectMake([srcMainBrowser frame].size.width, 0, 
                             [srcMainBrowser frame].size.width, 
                             [srcMainBrowser frame].size.height);
    [srcMainBrowser addSubview:second];
    [srcMainBrowser addSubview:third];
    [srcMainBrowser setContentOffset:CGPointMake([srcMainBrowser frame].size.width, 0)];
    
    int ghazal_number = ((m_ghazalPointer+1)%m_ghzalCnt);
    UIView *forth = [self createViewForGhazal:ghazal_number];
    forth.frame = CGRectMake([srcMainBrowser frame].size.width*2, 0.0,       
                            [srcMainBrowser frame].size.width, 
                            [srcMainBrowser frame].size.height);
    [srcMainBrowser addSubview:forth];
    

    m_scrollViews = [[NSArray alloc] initWithObjects:second,third,forth, nil];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Ghazals"
                                                          action:@"Scroll"
                                                           label:@"Right"
                                                           value:nil] build]];
}

- (void) scrollLeft
{
    UIView *first = [m_scrollViews objectAtIndex:0];
    UIView *second = [m_scrollViews objectAtIndex:1];
    UIView *third = [m_scrollViews objectAtIndex:2];
    [third removeFromSuperview];
    first.frame = CGRectMake([srcMainBrowser frame].size.width, 0, 
                             [srcMainBrowser frame].size.width, 
                              [srcMainBrowser frame].size.height);
    second.frame = CGRectMake([srcMainBrowser frame].size.width*2, 0, 
                             [srcMainBrowser frame].size.width, 
                             [srcMainBrowser frame].size.height);
    [srcMainBrowser setContentOffset:CGPointMake([srcMainBrowser frame].size.width, 0)];
    
    int ghazal_number = ((m_ghazalPointer-1)%m_ghzalCnt);
    UIView *zeros = [self createViewForGhazal:ghazal_number];
    zeros.frame = CGRectMake(0, 0,       
                             [srcMainBrowser frame].size.width, 
                             [srcMainBrowser frame].size.height);
    [srcMainBrowser addSubview:zeros];
    
    
    m_scrollViews = [[NSArray alloc] initWithObjects:zeros,first,second, nil];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Ghazals"
                                                          action:@"Scroll"
                                                           label:@"Left"
                                                           value:nil] build]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scroll view 1");
    
    CGPoint offset = [scrollView contentOffset];
    float pageNumber = offset.x / srcMainBrowser.frame.size.width;
    int iPageNumber = (int) pageNumber;
    if (pageNumber != iPageNumber) {
        return;
    }
    
    NSLog(@"scroll view 2");
    
    if (pageNumber == 2) {
        m_ghazalPointer++;
        [self scrollRight];
        NSLog(@"scroll view 3");
        return;
    } else if (pageNumber == 0) {
        m_ghazalPointer--;
        [self scrollLeft];
        NSLog(@"scroll view 4");
        return;
    }
    
    NSLog(@"Scroll view scroll: %d", (int) pageNumber);
}

- (void) initScrollFrame
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    int iphone5offset = (height > 480) ? 71 : 0;
    
    CGRect mainViewRect;
    if (currOrtientation == UIInterfaceOrientationPortrait) {
        mainViewRect = CGRectMake(43, 58, 233, 317+iphone5offset);
    } else {
        mainViewRect = CGRectMake(64, 29, height-2*64, width-127);
    }
    
    srcMainBrowser = [[UIScrollView alloc] initWithFrame:mainViewRect];
    
    srcMainBrowser.delegate = self;
    
    srcMainBrowser.pagingEnabled = YES;
    [[self view] addSubview:srcMainBrowser];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    gInstance = self;
    
    if (![self loadDB]) {
        [CommonUtils alert:@"Could not load database!"];
        return;
    }
 
    UIInterfaceOrientation or = [[UIDevice currentDevice] orientation];
    if (or== UIInterfaceOrientationPortrait || or == UIInterfaceOrientationPortraitUpsideDown) {
        currOrtientation = UIInterfaceOrientationPortrait;
    } else {
        currOrtientation = UIInterfaceOrientationLandscapeLeft;
    }
    
    m_ghazalPointer = 0;
    
    [self calcGhazalCnt];
    _carousel.type = iCarouselTypeCoverFlow2;
    [_carousel reloadData];
    
    [self checkForPushNotes];
    
    [self checkForSavedGhazal];
}

- (void) viewGhazal:(NSString *) ghazalNumber {
    [_carousel scrollToItemAtIndex:[ghazalNumber integerValue] animated:YES];
}

- (void) checkForSavedGhazal
{
    NSLog(@"checkForSavedGhazal");
    NSString *ghazalNumber = [[HafezAPI instance] getSetting:@"ghazalNumber"];
    
    if (ghazalNumber == nil) {
        return;
    }
    
    NSLog(@"checkForSavedGhazal, ghazalNumber: %@", ghazalNumber);
    
    [self viewGhazal:ghazalNumber];
    
    [[HafezAPI instance] removeSetting:@"ghazalNumber"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self loadFacebookAd];
}

- (void) loadFacebookAd {
    // Create a banner's ad view with a unique placement ID (generate your own on the Facebook app settings).
    // Use different ID for each ad placement in your app.
    BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    FBAdSize adSize = isIPAD ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    adView = [[FBAdView alloc] initWithPlacementID:@"1260704423969786_1260705903969638"
                                            adSize:adSize
                                rootViewController:self];
    
    // Set a delegate to get notified on changes or when the user interact with the ad.
    adView.delegate = self;
    
    // When testing on a device, add its hashed ID to force test ads.
    // The hash ID is printed to console when running on a device.
    // [FBAdSettings addTestDevice:@"THE HASHED ID AS PRINTED TO CONSOLE"];
    
    // Initiate a request to load an ad.
    [adView loadAd];
    
    // Reposition the adView to the bottom of the screen
    CGSize viewSize = self.view.bounds.size;
    CGSize tabBarSize = self.tabBarController.tabBar.frame.size;
    viewSize = CGSizeMake(viewSize.width, viewSize.height - tabBarSize.height);
    CGFloat bottomAlignedY = viewSize.height;
    adView.frame = CGRectMake(0, bottomAlignedY, viewSize.width, adSize.size.height);
    
    // Set autoresizingMask so the rotation is automatically handled
    adView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleLeftMargin|
                            UIViewAutoresizingFlexibleWidth |
                            UIViewAutoresizingFlexibleTopMargin;
    
    // Add adView to the view hierarchy.
    [self.view addSubview:adView];
}

- (void)adViewDidLoad:(FBAdView *)adViewRef
{
    NSLog(@"Ad was loaded.");
    // Now that the ad was loaded, show the view in case it was hidden before.
    adView.hidden = NO;
    
    [self trackEvent:@"fb-ad-loaded"];
    
}

- (void)adView:(FBAdView *)adViewRef didFailWithError:(NSError *)error
{
    NSLog(@"Ad failed to load with error: %@", error);
    
    // Hide the unit since no ad is shown.
    adView.hidden = YES;
    [self trackEvent:@"fb-ad-failed"];
}


//- (void)bannerViewDidLoadAd:(ADBannerView *)banner
//{
//    if (!_bannerIsVisible)
//    {
//        NSLog(@"Ad shown");
//        // If banner isn't part of view hierarchy, add it
//        if (_adBanner.superview == nil)
//        {
//            [self.view addSubview:_adBanner];
//        }
//        
//        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
//        
//        // Assumes the banner view is just off the bottom of the screen.
//        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
//        _bgDownConstraint.constant = 50;
//        [UIView commitAnimations];
//        
//        _bannerIsVisible = YES;
//        
//        [self trackEvent:@"show"];
//    }
//}
//
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
//{
//    NSLog(@"Failed to retrieve ad");
//    [self trackEvent:@"no-ad"];
//    
//    if (_bannerIsVisible)
//    {
//        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
//        
//        // Assumes the banner view is placed at the bottom of the screen.
//        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
//        
//        [UIView commitAnimations];
//        
//        _bannerIsVisible = NO;
//    }
//}

- (void) trackEvent:(NSString *) eventName {
    int ghazalNumber = _carousel.currentItemIndex;
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ads"
                                                          action:eventName
                                                           label:[NSString stringWithFormat:@"ghazal-%d", ghazalNumber]
                                                           value:nil] build]];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return m_ghzalCnt;
}

- (UIView *) createGhazalContainerView:(CGRect) frame {
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:frame];

    UIView *view = [[UIView alloc] initWithFrame:frame];

    UIView *bgView = [[UIView alloc] initWithFrame:frame];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = 0.8;
    [view addSubview:bgView];
    [view addSubview:scrollview];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ghazalViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:singleTap];
    [view setUserInteractionEnabled:YES];
    
    return view;
}

- (void) ghazalViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    UIView * v = [gestureRecognizer view];
    NSLog(@"ghazal tapped: %d", v.tag);
    
    [self performSegueWithIdentifier:@"showGhazal" sender:v];
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the photo if it navigates to the PhotoView
    if ([segue.identifier isEqualToString:@"showGhazal"]) {
        GhazalViewController *ctrl = (GhazalViewController*)segue.destinationViewController;
        ctrl.ghazalNumber = ((UIView *)sender).tag;
        ctrl.faLabelArray = [self getGhazals:ctrl.ghazalNumber lang:1];
        ctrl.enLabelArray = [self getGhazals:ctrl.ghazalNumber lang:2];

    }
}

- (void) fillGhazalContainerView:(UIScrollView *) scrollview withIndex:(int) ghazalNumber
{
    NSArray *views = [scrollview subviews];
    for (UIView *v in views) {
        [v removeFromSuperview];
    }
    
    int y = 5;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, y, 200, 20)];
    label.text = [NSString stringWithFormat:@"Ghazal #%d غزل شماره",(ghazalNumber+1)];
    label.font =[UIFont fontWithName:@"Arial" size:12];
    y=y+25;
    [scrollview addSubview:label];
    
    
    NSArray *faLabelArray = [self getGhazals:ghazalNumber lang:1];
    NSArray *enLabelArray = [self getGhazals:ghazalNumber lang:2];
    
    for (int i=0; i < [faLabelArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, y, scrollview.frame.size.width-10, 20)];
        label.text = [NSString stringWithFormat:@"%@",[faLabelArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = (i%2) ? UITextAlignmentLeft : UITextAlignmentRight;
        label.font =[UIFont fontWithName:@"Arial" size:12];
        [scrollview addSubview:label];
        y=y+((i%2) ? 25 : 20);
    }
    
    y=y+25;
    
    for (int i=0; i < [enLabelArray count]; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(((i%2) ? 20 : 5), y, scrollview.frame.size.width-20, 20)];
        label.text = [NSString stringWithFormat:@"%@",[enLabelArray objectAtIndex:i]];
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        label.textAlignment = UITextAlignmentLeft;
        label.font =[UIFont fontWithName:@"Arial" size:12];
        label.adjustsFontSizeToFitWidth = NO;
        label.numberOfLines = 0;
        [label sizeToFit];
        [scrollview addSubview:label];
        y = y + label.frame.size.height +((i%2) ? 5 : 0);
    }
    
    scrollview.contentSize = CGSizeMake(scrollview.frame.size.width-4, y+20);
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [self createGhazalContainerView:CGRectMake(0, 0, 200, _carousel.frame.size.height)];
    }

    UIScrollView *scr = [[view subviews] objectAtIndex:1];
    [self fillGhazalContainerView:scr withIndex:index];
    view.tag = index;
    
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.1f;
    }
    return value;
}

- (void)viewDidUnload
{
//    [self setSrcMainBrowser:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    NSLog(@"database close!");
    sqlite3_close(m_database);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"didRotateFromInterfaceOrientation");
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation");
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        currOrtientation = UIInterfaceOrientationPortrait;
    } else {
        currOrtientation = UIInterfaceOrientationLandscapeLeft;
    }

//    [srcMainBrowser removeFromSuperview];
//    [self initScrollFrame];
//    [self initViews];

}

- (IBAction)onss:(id)sender {
    
    NSMutableString *ghazalText = [[NSMutableString alloc] init];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Faal"
                                                          action:@"Click"
                                                           label:@"FacebookShare2"
                                                           value:nil] build]];
    int ghazalNumber = _carousel.currentItemIndex;
    NSArray *faLabelArray = [self getGhazals:ghazalNumber lang:1];
    NSArray *enLabelArray = [self getGhazals:ghazalNumber lang:2];
    
    for (int i=0; i < [faLabelArray count]; i++) {
        [ghazalText appendString:[faLabelArray objectAtIndex:i]];
        if (i%2) {
            [ghazalText appendString:@"\n"];
        } else {
            [ghazalText appendString:@" ... "];
        }
    }
    
    for (int i=0; i < [enLabelArray count]; i++) {
        [ghazalText appendString:[enLabelArray objectAtIndex:i]];
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

- (void) checkForPushNotes
{
    NSLog(@"checkForPushNotes");
    
    HafezAPI *api = [HafezAPI instance];
    NSString *pushNote = [api getSetting:@"PushNote" withDefault:@""];
    if ([pushNote isEqualToString:@""])
    {
        NSLog(@"Not asked before, asking . . .");
        [self showDailyFallRequest];
    } else if ([pushNote isEqualToString:@"yes"]) {
        [self enablePushNotification];
    }
}

- (void) enablePushNotification {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void) showDailyFallRequest
{
    NSLog(@"showDailyFallRequest");
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Daily Ghazal"
                                                   message:@"Do you want to receive daily Ghazal of Hafez?"
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    [alert show];
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"HasSeenPopup"];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    HafezAPI *api = [HafezAPI instance];

    // 0 = Tapped yes
    if (buttonIndex == 1)
    {
        [self enablePushNotification];
        [api saveSetting:@"PushNote" withValue:@"yes"];
        
    } else {
        [api saveSetting:@"PushNote" withValue:@"no"];
    }
}

@end
