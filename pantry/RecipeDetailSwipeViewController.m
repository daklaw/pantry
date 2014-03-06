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
#import "FiltersViewController.h"
#import "GroceryViewController.h"
#import "YummlyClient.h"
#import "Filter.h"
#import "SVProgressHUD.h"

@interface RecipeDetailSwipeViewController () <SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UIView *introView;
@property (nonatomic, strong) IBOutlet UIView *noResultsView;
@property (nonatomic, assign) BOOL pastIntro;


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
    self.recipes = [[NSMutableArray alloc] init];
    [self recipesWithYummly];

    // Link swipe view data source and delegate
    self.swipeView.dataSource = self;
    self.swipeView.delegate = self;
    
    // Adjust for 3.5" and 4" sizes
    self.swipeView.bounds = [[UIScreen mainScreen] bounds];
    
    // Configure swipeView
    self.swipeView.pagingEnabled = YES;
    self.swipeView.currentItemIndex = 0;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilter:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Grocery List" style:UIBarButtonItemStylePlain target:self action:@selector(onGrocery:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSearchYummly) name:DidFinishFilter object:nil];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"seenTutorial"]) {
        self.overlayView = [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil][0];
        [self.overlayView setBackgroundColor:[UIColor clearColor]];
        self.overlayView.frame = self.view.frame;
    }
    
    self.pastIntro = NO;
    self.introView = [[NSBundle mainBundle] loadNibNamed:@"IntroView" owner:self options:nil][0];
    self.introView.frame = self.view.frame;
    [self.view addSubview:self.introView];
    
    self.noResultsView = [[NSBundle mainBundle] loadNibNamed:@"NoResultsView" owner:self options:nil][0];
    self.noResultsView.frame = [[UIScreen mainScreen] bounds];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    UILabel *prepTimeLabel = nil;
    UITableView *ingredientsView = nil;
    UIButton *addToGroceryListButton = nil;
    Recipe *recipe = self.recipes[index];
    
    if (!view) {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        recipeImage = [[UIImageView alloc] initWithFrame:CGRectMake(view.bounds.origin.x, view.bounds.origin.y, 320, 320)];
        recipeImage.tag = 1;
        [view addSubview:recipeImage];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.origin.x + 20, view.bounds.origin.y + 72, 300, 21)];
        nameLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20];
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nameLabel.numberOfLines = 0;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.tag = 2;
        [view addSubview:nameLabel];
        
        addToGroceryListButton = [[UIButton alloc] initWithFrame:CGRectMake(view.bounds.origin.x, view.bounds.size.height - 30, view.bounds.size.width, 30)];
        addToGroceryListButton.backgroundColor = [UIColor lightGrayColor];
        addToGroceryListButton.titleLabel.font = [UIFont systemFontOfSize:16];
        addToGroceryListButton.titleLabel.textColor = [UIColor whiteColor];
        [addToGroceryListButton setTitle:@"Add Ingredients to Grocery List" forState:UIControlStateNormal];
        [addToGroceryListButton addTarget:self action:@selector(onAddToGroceryList:) forControlEvents:UIControlEventTouchUpInside];
        addToGroceryListButton.tag = 3;
        [view addSubview:addToGroceryListButton];
        
        UILabel *prepTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.bounds.origin.x, view.bounds.origin.y+320, view.bounds.size.width, 20.0f)];
        prepTimeLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        prepTimeLabel.textColor = [UIColor whiteColor];
        prepTimeLabel.backgroundColor = [UIColor darkGrayColor];
        prepTimeLabel.numberOfLines = 1;
        prepTimeLabel.tag = 4;
        NSInteger cookTime = recipe.cookTime;
        if (cookTime) {
            cookTime = cookTime / 60;
            prepTimeLabel.text = [NSString stringWithFormat:@"Estimated Prep Time: %d minutes", cookTime];
            
        }
        else {
            prepTimeLabel.text = @"No Prep Time Specified";
        }
        
        [view addSubview:prepTimeLabel];
    }
    else
    {
        recipeImage = (UIImageView *)[view viewWithTag:1];
        nameLabel = (UILabel *)[view viewWithTag:2];
        addToGroceryListButton = (UIButton *)[view viewWithTag:3];
        prepTimeLabel = (UILabel *)[view viewWithTag:4];
    }
    
    // Populate view with recipe details

    nameLabel.text = recipe.name;
    [nameLabel sizeToFit];
    
    [recipeImage setImageWithURL:recipe.imageURL];

    ingredientsView = [[UITableView alloc] initWithFrame:CGRectMake(view.bounds.origin.x, addToGroceryListButton.frame.origin.y - 200, view.bounds.size.width, 200)];
    [ingredientsView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    ingredientsView.allowsSelection = NO;
    ingredientsView.delegate = self;
    ingredientsView.dataSource = self;
    ingredientsView.scrollEnabled = NO;
    ingredientsView.separatorStyle = UITableViewCellSeparatorStyleNone;
    ingredientsView.tag = index;
    [ingredientsView setBackgroundColor:[UIColor darkGrayColor]];
    [view addSubview:ingredientsView];
    
    YummlyClient *client = [[YummlyClient alloc] init];
    if ([recipe.ingredients count] == 0) {
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
    }

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
    static CGFloat minHeight = 20.0f;

    Recipe *recipe = self.recipes[tableView.tag];
    NSString *string = [recipe.ingredients[indexPath.row] valueForKey:@"totalString"];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width - 40;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12.0f]};
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];

    return MAX(rect.size.height, minHeight);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:[UIColor darkGrayColor]];
    
    Recipe *recipe = self.recipes[tableView.tag];
    cell.textLabel.text = [recipe.ingredients[indexPath.row] valueForKey:@"totalString"];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell.textLabel sizeToFit];
    
    return cell;
}



#pragma mark - Private methods

- (IBAction)onAddToGroceryList:(UIButton *)sender {
    [[GroceryList sharedList] addRecipe:self.recipes[self.swipeView.currentItemIndex]];
    [self showNotificationMessage:@"Ingredients added."];
}

- (void) onFilter:(id)sender {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void) onGrocery:(id)sender {
    GroceryViewController *vc = [[GroceryViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)recipesWithYummly {
    YummlyClient *client = [[YummlyClient alloc] init];
    
    if ([[Filter instance] ingredientFilters]) {
        [client addAllowedIngredients:[(NSSet *)[[Filter instance] ingredientFilters] allObjects]];
    }
    
    if ([[Filter instance] hasMaxPrepTime]) {
        [client setMaximumTime:[[Filter instance] maximumTime]];
    }

    
    [client search:^(AFHTTPRequestOperation *operation, id response) {
//        // Yummly attribution
//        self.attributionLogo = response[@"attribution"][@"logo"];
//        self.attributionText = response[@"attribution"][@"text"];
//        self.attributionURL = response[@"attribution"][@"url"];
        [self.recipes removeAllObjects];
        for (id data in response[@"matches"]) {
            [self.recipes addObject:[[Recipe alloc] initWithDictionary:data]];
        }
        if ([self.recipes count] == 0) {
            [self.view addSubview:self.noResultsView];

        }
        else {
            [self.swipeView reloadData];
            [self.swipeView setCurrentItemIndex:0];

            [self.noResultsView removeFromSuperview];
        }

        [self.introView removeFromSuperview];
        self.pastIntro = YES;
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        if (self.overlayView && ![[NSUserDefaults standardUserDefaults] valueForKey:@"hasSeenTutorial"]) {
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [self.overlayView addGestureRecognizer:recognizer];
            [self.overlayView setUserInteractionEnabled:YES];
            [self.view addSubview:self.overlayView];
            [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"hasSeenTutorial"];
        }
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)reSearchYummly {
    [SVProgressHUD showWithStatus:@"Finding Recipes"];
    [self recipesWithYummly];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    [self.overlayView removeFromSuperview];
}

- (void)showNotificationMessage:(NSString *)message
{
    CGRect startFrame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 30);
    CGRect endFrame = CGRectMake(0, self.view.bounds.size.height - 30, self.view.bounds.size.width, 30);
    
    UIView *notificationView = [[UIView alloc] initWithFrame:startFrame];
    UILabel *label = [[UILabel alloc] initWithFrame:notificationView.bounds];
    label.backgroundColor = [[UIView appearance] tintColor];
    label.font = [UIFont systemFontOfSize:16];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [notificationView addSubview:label];
    
    [self.view addSubview:notificationView];
    
    [UIView animateWithDuration:0.5 animations:^{
        notificationView.frame = endFrame;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            notificationView.frame = startFrame;
        } completion:nil];
    }];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end
