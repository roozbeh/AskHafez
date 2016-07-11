//
//  HafezModelController.m
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import "HafezModelController.h"

#import "HafezDataViewController.h"
#import "CommonUtils.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@implementation HafezModelController

@synthesize rootController;

- (Boolean) loadDB
{
    NSString *databasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ghazals.sqlite"];
    if (sqlite3_open([databasePath UTF8String], &m_database) == SQLITE_OK) {
        NSLog(@"database open!");
        return true;
    }
    
    return false;
}

- (int) getGhazalCount
{
    return m_ghzalCnt;
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


- (id)init
{
    self = [super init];
    if (self) {
        if (![self loadDB]) {
//            [CommonUtils alert:@"Could not load database!"];
            return self;
        }
        [self calcGhazalCnt];
        
        m_index = 0;
    }
    return self;
}

- (HafezDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    // Return the data view controller for the given index.
    if ((m_ghzalCnt == 0) || (index >= m_ghzalCnt)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    HafezDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"HafezDataViewController"];
    dataViewController.faArray = [self getGhazals: index lang:1];
    dataViewController.enArray = [self getGhazals: index lang:2];
    dataViewController.ghazalNumber = [NSNumber numberWithInt:index+1];
    dataViewController.rootController = [self rootController];
    m_index = index;
    
//    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/ipad/Ghazal-%d", index] withError:nil];
    
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(HafezDataViewController *)viewController
{   
    /*
     Return the index of the given data view controller.
     For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
     */
//    return [self.pageData indexOfObject:viewController.dataObject];
    return m_index;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(HafezDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(HafezDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == m_ghzalCnt) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
