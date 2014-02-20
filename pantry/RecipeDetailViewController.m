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
#import "GroceryList.h"

@interface RecipeDetailViewController ()
- (IBAction)addToGroceryList:(id)sender;

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
    [self.nameLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    [self.recipeImage setImageWithURL:self.recipe.imageURL];
    
    if (self.recipe.sourceRecipeURL) {
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.recipe.sourceRecipeURL];
        [self.directionsView loadRequest:requestObj];
    }
    
    [self.ingredientsView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.ingredientsView.delegate = self;
    self.ingredientsView.dataSource = self;
    self.ingredientsView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.recipe.ingredientLines.count > 0) {
        [self.ingredientsView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *ingredientLine = self.recipe.ingredientLines[indexPath.row];
    cell.textLabel.text = ingredientLine;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    [cell.textLabel sizeToFit];
    
    return cell;
}



- (IBAction)addToGroceryList:(id)sender {
    for (id item in self.recipe.ingredientLines) {
        [[GroceryList sharedList] addItem:item];
    }
    [sender setUserInteractionEnabled:NO];
}
@end
