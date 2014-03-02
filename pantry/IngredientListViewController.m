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

@property (strong, nonatomic) IBOutlet TITokenField *tokenField;
@property (nonatomic, assign) CGFloat tokenFieldHeight;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *meats;
@property (nonatomic, strong) NSArray *produce;
@property (nonatomic, strong) NSArray *others;
@property (nonatomic, strong) NSMutableArray *selectedIngredients;

- (void) resetFilters;
- (void) searchForRecipes;
- (void) onMenu:(id)sender;

@end

@implementation IngredientListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    UIImage *resetIcon = [UIImage imageNamed:@"Reset"];
    CGRect resetFrame = CGRectMake(0, 0, 20, 20);
    UIButton *resetButton = [[UIButton alloc] initWithFrame:resetFrame];
    [resetButton setBackgroundImage:resetIcon forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetFilters) forControlEvents:UIControlEventTouchUpInside];
    [resetButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *resetBarButton = [[UIBarButtonItem alloc] initWithCustomView:resetButton];
    
    UIImage *searchIcon = [UIImage imageNamed:@"Search"];
    CGRect searchFrame = CGRectMake(0, 0, 20, 20);
    UIButton *searchButton = [[UIButton alloc] initWithFrame:searchFrame];
    [searchButton setBackgroundImage:searchIcon forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchForRecipes) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    

    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tokenField.delegate = self;
    [self.tokenField setPromptText:@"Ingredients"];
    self.tokenFieldHeight = self.tokenField.frame.size.height;
    
    // Place back all previous filters
    for (id filter in [[[IngredientsFilter instance] filters] copy]) {
        [self.tokenField addTokenWithTitle:(NSString *)filter];
    }

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

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 20.0f;
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
    [self.tokenField addTokenWithTitle:cell.textLabel.text];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Meats";
    }
    if (section == 1) {
        return @"Vegetables";
    }
    return @"Other";
}

- (void) resetFilters {
    [self.tokenField removeAllTokens];
}

- (void) searchForRecipes {
    RecipeViewController *recipeViewController = [[RecipeViewController alloc] init];
    [self.navigationController pushViewController:recipeViewController animated:YES];
}

- (void) onMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) updateTableViewFrame {
    CGRect tokenFrame = self.tokenField.frame;
    if (tokenFrame.size.height > self.tokenFieldHeight) {
        CGFloat offset = tokenFrame.size.height - self.tokenFieldHeight;
        CGRect oldTableFrame = self.tableView.frame;
        self.tableView.frame = CGRectMake(oldTableFrame.origin.x, oldTableFrame.origin.y+offset, oldTableFrame.size.width, oldTableFrame.size.height-offset);
    }
    else if (tokenFrame.size.height < self.tokenFieldHeight) {
        CGFloat offset = self.tokenFieldHeight - tokenFrame.size.height;
        CGRect oldTableFrame = self.tableView.frame;
        self.tableView.frame = CGRectMake(oldTableFrame.origin.x, oldTableFrame.origin.y-offset, oldTableFrame.size.width, oldTableFrame.size.height+offset);
    }
    self.tokenFieldHeight = tokenFrame.size.height;
}

#pragma mark - TiTokenField Methods

- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token {
    
    [[IngredientsFilter instance] addFilter:token.title];
    [self.tokenField layoutTokensAnimated:YES];
    [self updateTableViewFrame];
}

- (void)tokenField:(TITokenField *)tokenField didRemoveToken:(TIToken *)token {
    [[IngredientsFilter instance] removeFilter:token.title];
    [self.tokenField layoutTokensAnimated:YES];
    [self updateTableViewFrame];
}

- (BOOL)tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token {
    return ![[self.tokenField tokenTitles] containsObject:token.title];
}

#pragma mark - TextField Delegate


@end
