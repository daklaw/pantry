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

static const NSInteger MEAT_SECTION = 0;
static const NSInteger PRODUCE_SECTION = 1;
static const NSInteger OTHERS_SECTION = 2;

@interface IngredientListViewController ()

@property (nonatomic, strong) NSArray *meats;
@property (nonatomic, strong) NSArray *produce;
@property (nonatomic, strong) NSArray *others;
@property (nonatomic, strong) NSMutableArray *selectedIngredients;

- (void) searchForRecipes;
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

    self.title = @"Ingredient Picker";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                          target:self
                                                                                          action:@selector(searchForRecipes)];
    
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
    
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedIngredients addObject:cell.textLabel.text];
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedIngredients removeObject:cell.textLabel.text];
    }
}

- (void) searchForRecipes {
    RecipeViewController *recipeViewController = [[RecipeViewController alloc] initWithIngredients:self.selectedIngredients];
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
