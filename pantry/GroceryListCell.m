//
//  GroceryListCell.m
//  pantry
//
//  Created by David Law on 2/27/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "GroceryListCell.h"

@implementation GroceryListCell

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

- (void)onSelect:(UIButton *)sender {
    [self.checkBox setSelected:!self.checkBox.selected];
}

@end
