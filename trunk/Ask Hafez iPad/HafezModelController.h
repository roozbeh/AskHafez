//
//  HafezModelController.h
//  Ask Hafez iPad
//
//  Created by Roozbeh on ۱۲/۱۱/۱۷.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class HafezDataViewController;

@interface HafezModelController : NSObject <UIPageViewControllerDataSource>
{
    sqlite3 *m_database;
    int m_ghzalCnt;
    int m_ghazalPointer;
    NSUInteger m_index;
}
- (HafezDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(HafezDataViewController *)viewController;

@property (strong, nonatomic) id rootController;
- (int) getGhazalCount;

@end
