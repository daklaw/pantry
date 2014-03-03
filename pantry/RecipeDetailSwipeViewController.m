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
#import "SwipeView.h"
#import "UIImageView+AFNetworking.h"
#import "YummlyClient.h"

@interface RecipeDetailSwipeViewController () <SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *recipeImage;
@property (nonatomic, weak) IBOutlet UITableView *ingredientsView;
@property (nonatomic, weak) IBOutlet UIWebView *directionsView;

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
    if (!view) {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        self.nameLabel.textColor = [UIColor whiteColor];
        
        [self.ingredientsView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        self.ingredientsView.delegate = self;
        self.ingredientsView.dataSource = self;
        self.ingredientsView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    //set background color
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    view.backgroundColor = [UIColor colorWithRed:red
                                           green:green
                                            blue:blue
                                           alpha:1.0];
    
    // Populate view with recipe details
    Recipe *recipe = self.recipes[index];
    self.nameLabel.text = recipe.name;

    [self.recipeImage setImageWithURL:recipe.imageURL];

    self.ingredientsView.tag = index;
    
    YummlyClient *client = [[YummlyClient alloc] init];
    [client getRecipe:recipe.yummlyID
              success:^(AFHTTPRequestOperation *operation, id response) {
                  // Populate additional fields from recipe details
                  
                  // Create Recipe Ingredients
                  [recipe.ingredients removeAllObjects];
                  for (id ingredient in [NSMutableArray removeDuplicates:response[@"ingredientLines"]]) {
                      [recipe.ingredients addObject:[[RecipeIngredient alloc] initWithString:ingredient]];
                  }
                  if ([recipe.ingredients count] > 0) {
                      [self.ingredientsView reloadData];
                  }

                  // Load recipe webpage in web view
                  recipe.sourceRecipeURL = [NSURL URLWithString:[response[@"source"] objectForKey:@"sourceRecipeUrl"]];
                  if (recipe.sourceRecipeURL) {
                      NSURLRequest *requestObj = [NSURLRequest requestWithURL:recipe.sourceRecipeURL];
                      [self.directionsView loadRequest:requestObj];
                  }
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
    NSString *ingredientLine = [recipe.ingredients[indexPath.row] valueForKey:@"totalString"];
    cell.textLabel.text = ingredientLine;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    [cell.textLabel sizeToFit];
    
    return cell;
}

#pragma mark - Private methods

- (IBAction)onAddToGroceryList:(UIButton *)sender {
    NSLog(@"item index %d", self.swipeView.currentItemIndex);
    [[GroceryList sharedList] addRecipe:self.recipes[self.swipeView.currentItemIndex]];
    [sender setUserInteractionEnabled:NO];
}

@end
