//
//  RecipeDetailViewController.h
//  pantry
//
//  Created by Phil Wee on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dish.h"

@interface RecipeDetailViewController : UIViewController

@property (nonatomic, weak) Dish *dish;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *recipeImage;
@property (nonatomic, weak) IBOutlet UITableView *ingredientsView;
@property (nonatomic, weak) IBOutlet UIWebView *directionsView;

@end
