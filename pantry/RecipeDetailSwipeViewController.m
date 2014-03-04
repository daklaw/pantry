//
//  RecipeDetailSwipeViewController.m
//  pantry
//
//  Created by Phil Wee on 3/2/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeDetailSwipeViewController.h"
#import "GroceryList.h"
#import "NSMutableArray+Additions.h"
#import "Recipe.h"
#import "RecipeIngredient.h"
#import "RecipeWebViewController.h"
#import "SwipeView.h"
#import "UIImageView+AFNetworking.h"
#import "YummlyClient.h"

@interface RecipeDetailSwipeViewController () <SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;

- (IBAction)onAddToGroceryList:(UIButton *)sender;

@end

@implementation RecipeDetailSwipeViewController

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
    
    // Link swipe view data source and delegate
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    
    // Adjust for 3.5" and 4" sizes
    self.swipeView.bounds = [[UIScreen mainScreen] bounds];
    
    // Configure swipeView
    self.swipeView.pagingEnabled = YES;
    self.swipeView.currentItemIndex = self.recipeIndex;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Swipe view data source

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //return the total number of items in the carousel
    return self.recipes.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    UIImageView *recipeImage = nil;
    UILabel *nameLabel = nil;
    UITableView *ingredientsView = nil;
    UIButton *addToGroceryListButton = nil;
    
    if (!view) {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        recipeImage = [[UIImageView alloc] initWithFrame:CGRectMake(view.bounds.origin.x, view.bounds.origin.y, 320, 320)];
        recipeImage.tag = 1;
        [view addSubview:recipeImage];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.origin.x + 20, view.bounds.origin.y + 72, 280, 21)];
        nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20];
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nameLabel.numberOfLines = 0;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.tag = 2;
        [view addSubview:nameLabel];
        
        addToGroceryListButton = [[UIButton alloc] initWithFrame:CGRectMake(view.bounds.origin.x, view.bounds.size.height - 30, view.bounds.size.width, 30)];
        addToGroceryListButton.backgroundColor = [UIColor lightGrayColor];
        addToGroceryListButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        addToGroceryListButton.titleLabel.textColor = [UIColor whiteColor];
        [addToGroceryListButton setTitle:@"Add to Grocery List" forState:UIControlStateNormal];
        [addToGroceryListButton addTarget:self action:@selector(onAddToGroceryList:) forControlEvents:UIControlEventTouchUpInside];
        addToGroceryListButton.tag = 3;
        [view addSubview:addToGroceryListButton];
    }
    else
    {
        recipeImage = (UIImageView *)[view viewWithTag:1];
        nameLabel = (UILabel *)[view viewWithTag:2];
        addToGroceryListButton = (UIButton *)[view viewWithTag:3];
    }
    
    // Populate view with recipe details
    Recipe *recipe = self.recipes[index];
    nameLabel.text = recipe.name;
    [nameLabel sizeToFit];
    
    [recipeImage setImageWithURL:recipe.imageURL];

    ingredientsView = [[UITableView alloc] initWithFrame:CGRectMake(view.bounds.origin.x, addToGroceryListButton.frame.origin.y - 240, view.bounds.size.width, 240)];
    [ingredientsView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    ingredientsView.allowsSelection = NO;
    ingredientsView.delegate = self;
    ingredientsView.dataSource = self;
    ingredientsView.scrollEnabled = NO;
    ingredientsView.separatorStyle = UITableViewCellSeparatorStyleNone;
    ingredientsView.tag = index;
    [view addSubview:ingredientsView];
    
    YummlyClient *client = [[YummlyClient alloc] init];
    [client getRecipe:recipe.yummlyID
              success:^(AFHTTPRequestOperation *operation, id response) {
                  // Populate additional fields from recipe details
                  
                  // Recipe ingredients
                  [recipe.ingredients removeAllObjects];
                  for (id ingredient in [NSMutableArray removeDuplicates:response[@"ingredientLines"]]) {
                      [recipe.ingredients addObject:[[RecipeIngredient alloc] initWithString:ingredient]];
                  }
                  if ([recipe.ingredients count] > 0) {
                      [ingredientsView reloadData];
                  }

                  // Recipe source
                  recipe.sourceRecipeURL = [NSURL URLWithString:[response[@"source"] objectForKey:@"sourceRecipeUrl"]];
                  recipe.sourceDisplayName = [response[@"source"] objectForKey:@"sourceDisplayName"];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"%@", error);
              }];

    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    // Navigate to web view controller
    RecipeWebViewController *vc = [[RecipeWebViewController alloc] init];
    Recipe *recipe = self.recipes[index];
    vc.recipeURL = recipe.sourceRecipeURL;
    vc.recipeName = recipe.sourceDisplayName;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    Recipe *recipe = self.recipes[tableView.tag];
    return recipe.ingredients.count;
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
    
    Recipe *recipe = self.recipes[tableView.tag];
    cell.textLabel.text = [recipe.ingredients[indexPath.row] valueForKey:@"totalString"];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    [cell.textLabel sizeToFit];
    
    return cell;
}

#pragma mark - Private methods

- (IBAction)onAddToGroceryList:(UIButton *)sender {
    [[GroceryList sharedList] addRecipe:self.recipes[self.swipeView.currentItemIndex]];
    [sender setUserInteractionEnabled:NO];
}

@end
