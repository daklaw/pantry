//
//  RecipeDetailViewController.m
//  pantry
//
//  Created by Phil Wee on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface RecipeDetailViewController ()

@end

@implementation RecipeDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Populate view with recipe details
    self.nameLabel.text = self.recipe.name;
    [self.recipeImage setImageWithURL:self.recipe.imageURL];
    //self.ingredientsView.visibleCells = self.dish.ingredients;
    
    NSString *fullURL = [NSString stringWithFormat:@"http://www.yummly.com/recipe/%@", self.recipe.yummlyID];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.directionsView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
