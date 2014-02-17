//
//  RecipeDetailViewController.m
//  pantry
//
//  Created by Phil Wee on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeDetailViewController.h"
#import "Recipe.h"
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

    if (self.recipe.ingredientLines.count > 0) {
        self.ingredientsView.dataSource = self;
        [self.ingredientsView reloadData];
    }
    
    if (self.recipe.sourceRecipeURL) {
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.recipe.sourceRecipeURL];
        [self.directionsView loadRequest:requestObj];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.recipe.ingredientLines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *ingredientLine = self.recipe.ingredientLines[indexPath.row];
    cell.textLabel.text = ingredientLine;
    
    return cell;
}

@end
