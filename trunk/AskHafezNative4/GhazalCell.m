//
//  GhazalCell.m
//  AskHafezNative4
//
//  Created by Roozbeh on 2/10/14.
//
//

#import "GhazalCell.h"

@implementation GhazalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initWithGhazalArray:(NSArray *)mesras {
    _lblFaMesra1.text = [mesras objectAtIndex:0];
    _lblFaMesra2.text = [mesras objectAtIndex:1];
    _lblEnMesra1.text = [mesras objectAtIndex:2];
    _lblEnMesra2.text = [mesras objectAtIndex:3];
}

@end
