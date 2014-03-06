//
//  RecipeDetailSwipeViewController.h
//  pantry
//
//  Created by Phil Wee on 3/2/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeDetailSwipeViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic) NSInteger recipeIndex;

@end
