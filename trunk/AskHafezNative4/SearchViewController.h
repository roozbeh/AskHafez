//
//  SearchViewController.h
//  AskHafezNative4
//
//  Created by Roozbeh on ۱۲/۱۱/۴.
//  Copyright (c) ۲۰۱۲ __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface SearchViewController : GAITrackedViewController<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSArray *m_resultArray;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tblView;

@end
