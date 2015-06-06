//
//  SearchViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۴.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "GhazalsViewController.h"
#import "GhazalCell.h"
#import "GAIDictionaryBuilder.h"

@implementation SearchViewController
@synthesize searchBar;
@synthesize tblView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search جستجو", @"Search جستجو");
        self.tabBarItem.image = [UIImage imageNamed:@"search.png"];
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [searchBar setDelegate:self];
    [tblView setDelegate:self];
    [tblView setDataSource:self];
    m_resultArray = [[NSArray alloc] init];

    self.screenName = @"/search";    
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTblView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_resultArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GhazalCell";
    GhazalCell *cell = (GhazalCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int index = [indexPath indexAtPosition:1];
    [cell initWithGhazalArray:[[m_resultArray objectAtIndex:index] objectForKey:@"text"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath indexAtPosition:1];
    NSNumber *ghazal_number = [[m_resultArray objectAtIndex:index] valueForKey:@"index"];
    
//    HafezFirstViewController *firstView = [[[self tabBarController] viewControllers] objectAtIndex:0];
    GhazalsViewController *firstView =  [[[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    [firstView navigateToView:[ghazal_number intValue]];
    UINavigationController *nav = [[self.tabBarController viewControllers] objectAtIndex:0];
    [nav popToRootViewControllerAnimated:NO];
    [[self tabBarController] setSelectedIndex:0];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Faal"
                                                          action:@"Click"
                                                           label:@"SearchItem"
                                                           value:nil] build]];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *) srchBar
{
    NSLog(@"search bar clicked");
    
//    HafezFirstViewController *firstView = [[[self tabBarController] viewControllers] objectAtIndex:0];
    GhazalsViewController *firstView =  [[[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    sqlite3* database = [firstView getDB];
    
    NSMutableArray *retArray = [[NSMutableArray alloc] init ];
    
    // Create the query statement to get all persons
    NSString *queryStatement = [NSString stringWithFormat:
            @"select ghazal_id, "
             "   mesra, "
             "   id, "
             "   (select min(g2.id) from ghazals g2 where g2.ghazal_id = g.ghazal_id and g2.lang = 1) as first_fa, "
             "(select min(g2.id) from ghazals g2 where g2.ghazal_id = g.ghazal_id and g2.lang = 2) as first_en from ghazals g "
             " where g.mesra like  '%%%@%%' limit 10;", [searchBar text]];
    // Prepare the query for execution
    sqlite3_stmt *statement;
    int res = sqlite3_prepare_v2(database, [queryStatement UTF8String], -1, &statement, NULL);
    if (res == SQLITE_OK)
    {
        // Iterate over all returned rows
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSNumber *ghazal_number = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
//            NSString *ghazal_mesra = [NSString stringWithFormat:@"%S", sqlite3_column_text16(statement, 1)];
            int mesra_id = [[NSNumber numberWithInt:sqlite3_column_int(statement, 2)] integerValue];
            int first_fa = [[NSNumber numberWithInt:sqlite3_column_int(statement, 3)] integerValue];
            int first_en = [[NSNumber numberWithInt:sqlite3_column_int(statement, 4)] integerValue];
            
            int faMesra1, faMesra2, enMesra1, enMesra2;
            int mesra_index;
            
            if (mesra_id < first_en) {
                /* found farsi */
                mesra_index = mesra_id - first_fa;
            } else {
                /* found en */
                mesra_index = mesra_id - first_en;
            }
            mesra_index = (mesra_index % 2) ? (mesra_index - 1) : mesra_index;
            faMesra1 = first_fa + mesra_index;
            faMesra2 = first_fa + mesra_index + 1;
            enMesra1 = first_en + mesra_index;
            enMesra2 = first_en + mesra_index + 1;
            

            NSArray *mesras = [[NSArray alloc] initWithObjects:
                [self loadMesraWithId:faMesra1],
                [self loadMesraWithId:faMesra2],
                [self loadMesraWithId:enMesra1],
                [self loadMesraWithId:enMesra2],
                               nil];
            [retArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:ghazal_number,@"index",mesras,@"text",nil]];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Error in calculating ghazal count");
    }
    
    m_resultArray = retArray;
    
    [tblView reloadData];
    [srchBar resignFirstResponder];
}

- (NSString *) loadMesraWithId: (int) mesra_id {
    GhazalsViewController *firstView =  [[[[self.tabBarController viewControllers] objectAtIndex:0]viewControllers] objectAtIndex:0];
    sqlite3* database = [firstView getDB];
    NSString *ret = @"";
    
    NSMutableArray *retArray = [[NSMutableArray alloc] init ];
    
    // Create the query statement to get all persons
    NSString *queryStatement = [NSString stringWithFormat:@"select mesra from ghazals where id = %d", mesra_id];
    // Prepare the query for execution
    sqlite3_stmt *statement;
    int res = sqlite3_prepare_v2(database, [queryStatement UTF8String], -1, &statement, NULL);
    if (res == SQLITE_OK)
    {
        // Iterate over all returned rows
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSString *ghazal_mesra = [NSString stringWithFormat:@"%S", sqlite3_column_text16(statement, 0)];
            ret = ghazal_mesra;
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Error in calculating ghazal count");
    }
    
    return ret;
}

@end
