//
//  GroceryListCell.h
//  pantry
//
//  Created by David Law on 2/27/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroceryListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *ingredientLabel;
@property (strong, nonatomic) IBOutlet UIButton *checkBox;
@end
