//
//  RecipeViewController.m
//  pantry
//
//  Created by Phil Wee on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeViewController.h"
#import "YummlyClient.h"
#import "IngredientsFilter.h"
#import "Recipe.h"
#import "RecipeCell.h"
//#import "RecipeDetailViewController.h"
#import "RecipeDetailSwipeViewController.h"
#import "GroceryViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MMDrawerBarButtonItem.h"
#import "NSMutableArray+Additions.h"
#import "RecipeIngredient.h"

@interface RecipeViewController ()

@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSString *attributionLogo;
@property (nonatomic, strong) NSString *attributionText;
@property (nonatomic, strong) NSString *attributionURL;

@end

@implementation RecipeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Recipes";
    
    // Navigation buttons
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(onMenu:)];
    
    // Load custom UITableViewCell from nib
    UINib *customNib = [UINib nibWithNibName:@"RecipeCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"MyRecipeCell"];
    [self reload];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.recipes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyRecipeCell";
    RecipeCell *cell = (RecipeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Recipe *recipe = self.recipes[indexPath.row];
    cell.nameLabel.text = recipe.name;
    cell.numIngredientsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[recipe ingredientCount]];
    
    [cell.recipeImage setImageWithURL:recipe.imageURL];
    
    // Yummly attribution button
    UIButton *attrButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    attrButton.frame = CGRectMake(cell.bounds.size.width-108, 20, 88, 20);
    [attrButton setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.attributionLogo]]] forState:UIControlStateNormal];
    //[attrButton setTitleEdgeInsets:UIEdgeInsetsMake(22.0, 5.0, 5.0, 5.0)];
    //[attrButton setTitle:self.attributionText forState:UIControlStateNormal];
    //attrButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
    //attrButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //attrButton.titleLabel.numberOfLines = 2;
    [attrButton addTarget:self action:@selector(onAttributionButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:attrButton];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Currently hardwired to be the size of a RecipeCell
    return 321.0f;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // navigate to Recipe Detail view controller
    RecipeDetailSwipeViewController *vc = [[RecipeDetailSwipeViewController alloc] init];
    vc.recipes = self.recipes;
    vc.recipeIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private methods
- (void)reload
{
    self.recipes = [[NSMutableArray alloc] init];
    
    YummlyClient *client = [[YummlyClient alloc] init];

    if ([[IngredientsFilter instance] filters]) {
        [client addAllowedIngredients:[(NSSet *)[[IngredientsFilter instance] filters] allObjects]];
    }
    
    [client search:^(AFHTTPRequestOperation *operation, id response) {
        // Yummly attribution
        self.attributionLogo = response[@"attribution"][@"logo"];
        self.attributionText = response[@"attribution"][@"text"];
        self.attributionURL = response[@"attribution"][@"url"];
        
        for (id data in response[@"matches"]) {
            [self.recipes addObject:[[Recipe alloc] initWithDictionary:data]];
        }
        [self.tableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void) onMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)onAttributionButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.attributionURL]];
}

@end
