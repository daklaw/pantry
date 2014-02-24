//
//  IngredientListViewController.m
//  pantry
//
//  Created by David Law on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "IngredientListViewController.h"
#import "RecipeViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "IngredientsFilter.h"

static const NSInteger MEAT_SECTION = 0;
static const NSInteger PRODUCE_SECTION = 1;
static const NSInteger OTHERS_SECTION = 2;

@interface IngredientListViewController ()

@property (nonatomic, strong) NSArray *meats;
@property (nonatomic, strong) NSArray *produce;
@property (nonatomic, strong) NSArray *others;
@property (nonatomic, strong) NSMutableArray *selectedIngredients;

- (void) resetFilters;
- (void) searchForRecipes;
- (void) cancelSearch;
- (void) onMenu:(id)sender;

@end

@implementation IngredientListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        /* TODO: Get these into a real data store like Parse */
        self.meats = @[@"Chicken", @"Chicken Breast", @"Chicken Thigh", @"Pork", @"Pork Shoulder", @"Pork Belly", @"Beef", @"Ground Beef", @"Ribeye", @"Turkey", @"Salmon"];
        self.produce = @[@"Celery", @"Carrots", @"Lettuce", @"Cabbage", @"Onions", @"Garlic", @"Ginger", @"Potatoes", @"Sweet Potatoes", @"Avocados", @"Basil", @"Thyme"];
        self.others = @[@"Salt", @"Pepper", @"Eggs", @"Olive Oil", @"Flour", @"Spaghetti", @"Fettuccine", @"Paprika"];
        
        self.selectedIngredients = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Filters";
    UIImage *resetIcon = [UIImage imageNamed:@"Reset Filters"];
    CGRect resetFrame = CGRectMake(0, 0, 20, 20);
    UIButton *resetButton = [[UIButton alloc] initWithFrame:resetFrame];
    [resetButton setBackgroundImage:resetIcon forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetFilters) forControlEvents:UIControlEventTouchUpInside];
    [resetButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *resetBarButton = [[UIBarButtonItem alloc] initWithCustomView:resetButton];
    
    /*
    UIImage *cancelIcon = [UIImage imageNamed:@"Cancel"];
    CGRect cancelFrame = CGRectMake(0, 0, 20, 20);
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:cancelFrame];
    [cancelButton setBackgroundImage:cancelIcon forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    */
    
    UIImage *searchIcon = [UIImage imageNamed:@"Search"];
    CGRect searchFrame = CGRectMake(0, 0, 20, 20);
    UIButton *searchButton = [[UIButton alloc] initWithFrame:searchFrame];
    [searchButton setBackgroundImage:searchIcon forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchForRecipes) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:resetBarButton, searchBarButton, nil];
    
    MMDrawerBarButtonItem *button = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(onMenu:)];
    self.navigationItem.leftBarButtonItem = button;
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == MEAT_SECTION) {
        return [self.meats count];
    }
    else if (section == PRODUCE_SECTION) {
        return [self.produce count];
    }
    
    return [self.others count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == MEAT_SECTION) {
        cell.textLabel.text = self.meats[indexPath.row];
    }
    else if (indexPath.section == PRODUCE_SECTION){
        cell.textLabel.text = self.produce[indexPath.row];
    }
    else {
        cell.textLabel.text = self.others[indexPath.row];
    }
    
    if([[IngredientsFilter instance] hasFilter:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [[IngredientsFilter instance] addFilter:cell.textLabel.text];
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [[IngredientsFilter instance] removeFilter:cell.textLabel.text];
    }
}

- (void) resetFilters {
    for (int section = 0, sectionCount = self.tableView.numberOfSections; section < sectionCount; ++section) {
        for (int row = 0, rowCount = [self.tableView numberOfRowsInSection:section]; row < rowCount; ++row) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
        }
    }
}

- (void) searchForRecipes {
    RecipeViewController *recipeViewController = [[RecipeViewController alloc] init];
    [self.navigationController pushViewController:recipeViewController animated:YES];
}

- (void) onMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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

@end
