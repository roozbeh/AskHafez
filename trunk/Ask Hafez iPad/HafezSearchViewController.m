//
//  HafezSearchViewController.m
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۲۵.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "HafezSearchViewController.h"
#import <sqlite3.h>
#import "GANTracker.h"

@implementation HafezSearchViewController
@synthesize tableView;
@synthesize searchBar;
@synthesize delegate;

- (void)viewDidLoad {
    m_resultArray = [[NSArray alloc] init];
    [searchBar setDelegate:self];
    [tableView setDelegate:self];
    [tableView setDataSource:self];


    [[GANTracker sharedTracker] trackPageview:@"/ipad/search" withError:nil];
}


- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [m_resultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    int index = [indexPath indexAtPosition:1];
    // Configure the cell...
    cell.textLabel.text = [[m_resultArray objectAtIndex:index] valueForKey:@"text"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath indexAtPosition:1];
    NSNumber *ghazal_number = [[m_resultArray objectAtIndex:index] valueForKey:@"index"];
    [self.delegate searchDismissPopover:[ghazal_number intValue]];
    
//    HafezFirstViewController *firstView = [[[self tabBarController] viewControllers] objectAtIndex:0];
//    [firstView navigateToView:[ghazal_number intValue]];
//    [[self tabBarController] setSelectedIndex:0];
}

- (sqlite3 *) openDB
{
    sqlite3 *db;
    NSString *databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ghazals.sqlite"];
    if (sqlite3_open([databasePath UTF8String], &db) == SQLITE_OK) {
        NSLog(@"database open!");
        return db;
    }
    
    return NULL;
}

- (void) closeDB:(sqlite3 *) db
{
    sqlite3_close(db);
}


- (void)searchBarSearchButtonClicked:(UISearchBar *) srchBar
{
    NSLog(@"search bar clicked");
    
//    HafezFirstViewController *firstView = [[[self tabBarController] viewControllers] objectAtIndex:0];
//    sqlite3* database = [firstView getDB];
    sqlite3* database = [self openDB];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    
    // Create the query statement to get all persons
    NSString *queryStatement = [NSString stringWithFormat:
                                @"select ghazal_id, mesra from ghazals where mesra like '%%%@%%' limit 10;", [searchBar text]];
    // Prepare the query for execution
    sqlite3_stmt *statement;
    int res = sqlite3_prepare_v2(database, [queryStatement UTF8String], -1, &statement, NULL);
    if (res == SQLITE_OK)
    {
        // Iterate over all returned rows
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSNumber *ghazal_number = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
            NSString *ghazal_mesra = [NSString stringWithFormat:@"%S", sqlite3_column_text16(statement, 1)];
            [retArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:ghazal_number,@"index",ghazal_mesra,@"text",nil]];
        }
        sqlite3_finalize(statement);
    } else {
        NSLog(@"Error in calculating ghazal count");
    }
    
    m_resultArray = retArray;
    
    [tableView reloadData];
    [srchBar resignFirstResponder];
    [self closeDB:database];
    
    [[GANTracker sharedTracker] trackEvent:@"Search"
                                    action:@"Click"
                                     label:[searchBar text]
                                     value:-1
                                 withError:nil];
    
}

@end
