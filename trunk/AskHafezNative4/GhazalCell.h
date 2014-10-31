//
//  GhazalCell.h
//  AskHafezNative4
//
//  Created by Roozbeh on 2/10/14.
//
//

#import <UIKit/UIKit.h>

@interface GhazalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblFaMesra1;
@property (weak, nonatomic) IBOutlet UILabel *lblFaMesra2;
@property (weak, nonatomic) IBOutlet UILabel *lblEnMesra1;
@property (weak, nonatomic) IBOutlet UILabel *lblEnMesra2;

- (void)initWithGhazalArray:(NSArray *)mesras;
@end
