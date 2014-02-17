//
//  RecipeCell.h
//  pantry
//
//  Created by Phil Wee on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"

@interface RecipeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *numIngredientsLabel;
@property (nonatomic, weak) IBOutlet UIImageView *recipeImage;

@end
