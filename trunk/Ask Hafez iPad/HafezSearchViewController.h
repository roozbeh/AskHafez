//
//  HafezSearchViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۲۵.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchDismissPopoverDelegate <NSObject>
-(void)searchDismissPopover:(int) ghazalNumber;
@end

@interface HafezSearchViewController : UIViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSArray *m_resultArray;
    __unsafe_unretained id<SearchDismissPopoverDelegate> delegate;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, assign) id<SearchDismissPopoverDelegate> delegate;

@end
