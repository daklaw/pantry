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

@interface IngredientListViewController ()

@property (strong, nonatomic) IBOutlet TITokenField *tokenField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *autocompleteTableView;
@property (strong, nonatomic) IBOutlet UITableView *selectorTableView;
@property (strong, nonatomic) NSArray *autocompleteIngredients;
@property (nonatomic, strong) NSArray *meats;
@property (nonatomic, strong) NSArray *produce;
@property (nonatomic, strong) NSArray *others;
@property (nonatomic, strong) NSMutableArray *allIngredients;
@property (nonatomic, strong) NSMutableArray *personalIngredients;
@property (nonatomic, assign) BOOL canAddPersonalIngredient;

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
        self.others = @[@"Salt", @"Pepper", @"Eggs", @"Olive Oil", @"Flour", @"Butter", @"Spaghetti"];
        
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
    
    self.selectorTableView.delegate = self;
    self.selectorTableView.dataSource = self;
    self.selectorTableView.scrollEnabled = YES;
    // Selector Table View is the default tableView
    [self swapTableView:self.selectorTableView];
    
    self.tokenField.delegate = self;
    [self.tokenField setPromptText:@"Ingredients"];
    self.tokenField.removesTokensOnEndEditing = NO;
    
    // Place back all previous filters
    for (id filter in [[[IngredientsFilter instance] filters] copy]) {
        [self.tokenField addTokenWithTitle:(NSString *)filter];
    }

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:resetBarButton, searchBarButton, nil];
    
    MMDrawerBarButtonItem *button = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(onMenu:)];
    self.navigationItem.leftBarButtonItem = button;
    
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:
                             self.tableView.frame style:UITableViewStylePlain];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.scrollEnabled = YES;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    
    self.allIngredients = [[NSMutableArray alloc] init];
    [self.allIngredients addObjectsFromArray:self.meats];
    [self.allIngredients addObjectsFromArray:self.produce];
    [self.allIngredients addObjectsFromArray:self.others];
    
    self.personalIngredients = [[NSMutableArray alloc] init];
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
    if (tableView == self.autocompleteTableView) {
        return 1;
    }
    else if ([[self personalIngredients] count]) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.autocompleteTableView) {
        if (self.canAddPersonalIngredient) {
            return [self.autocompleteIngredients count] + 1;
        }
        else {
            return [self.autocompleteIngredients count];
        }
    }
    else if (section == [self meatIndex]) {
        return [self.meats count];
    }
    else if (section == [self produceIndex]) {
        return [self.produce count];
    }
    else if (section == [self othersIndex]) {
        return [self.others count];
    }
    
    return [self.personalIngredients count];
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
    
    if (tableView == self.autocompleteTableView) {
        if (indexPath.row == 0 && self.canAddPersonalIngredient) {
            cell.textLabel.text = @"Add Ingredient";
        }
        else {
            if (self.canAddPersonalIngredient) {
                cell.textLabel.text = self.autocompleteIngredients[indexPath.row - 1];
            }
            else {
                cell.textLabel.text = self.autocompleteIngredients[indexPath.row];
            }
            
        }
    }
    else if (indexPath.section == [self meatIndex]) {
        cell.textLabel.text = self.meats[indexPath.row];
    }
    else if (indexPath.section == [self produceIndex]){
        cell.textLabel.text = self.produce[indexPath.row];
    }
    else if (indexPath.section == [self othersIndex]){
        cell.textLabel.text = self.others[indexPath.row];
    }
    else {
        NSLog(@"%d", indexPath.row);
        cell.textLabel.text = self.personalIngredients[indexPath.row];
    }
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView == self.autocompleteTableView && indexPath.row == 0) {
        [self.personalIngredients addObject:[self.tokenField.text capitalizedString]];
        [self.tokenField addTokenWithTitle:[self.tokenField.text capitalizedString]];
        [self.selectorTableView reloadData];
    }
    else {
        [self.tokenField addTokenWithTitle:cell.textLabel.text];
    }
    [(UITextField *)self.tokenField resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.autocompleteTableView) {
        return nil;
    }
    if (section == [self meatIndex]) {
        return @"Meats";
    }
    else if (section == [self produceIndex]) {
        return @"Vegetables";
    }
    else if (section == [self othersIndex]) {
        return @"Other";
    }
    
    return @"Personal Ingredients";
}


#pragma mark - TiTokenField Delegate Methods

- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token {
    
    token.title = [token.title capitalizedString];
    [[IngredientsFilter instance] addFilter:token.title];

    [self swapTableView:self.selectorTableView];
    [self updateTableViewFrame:self.tableView];
}

- (void)tokenField:(TITokenField *)tokenField didRemoveToken:(TIToken *)token {
    [[IngredientsFilter instance] removeFilter:token.title];
    [self updateTableViewFrame:self.tableView];
}

- (BOOL)tokenField:(TITokenField *)tokenField willAddToken:(TIToken *)token {
    return ![[self.tokenField tokenTitles] containsObject:token.title];
}

#pragma mark - TextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *query = [[textField.text stringByAppendingString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self searchAutocompleteEntriesWithSubString:query];
    [self swapTableView:self.autocompleteTableView];
    [self updateTableViewFrame:self.tableView];

    return YES;
}

- (void)searchAutocompleteEntriesWithSubString:(NSString *)substring {
    NSString *predicateStr = [NSString stringWithFormat:@"SELF BEGINSWITH[c] '%@'", substring];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateStr];
    self.autocompleteIngredients = [[self.allIngredients copy] filteredArrayUsingPredicate:predicate];
    if ([self.autocompleteIngredients containsObject:[substring capitalizedString]]) {
        self.canAddPersonalIngredient = NO;
    }
    else {
        self.canAddPersonalIngredient = YES;
    }
    [self.autocompleteTableView reloadData];
}


# pragma mark - Private Methods

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

- (void) updateTableViewFrame:(UITableView *)tableView {
    // First update tokenField to ensure it has the right frame
    [self.tokenField layoutTokensAnimated:YES];
    
    CGRect tokenFrame = self.tokenField.frame;
    
    // Take the offset between the tokenFrame and tableView adjust accordingly
    CGFloat offset = tokenFrame.origin.y + tokenFrame.size.height - tableView.frame.origin.y;
    
    if (offset != 0.0f) {
        CGRect oldTableFrame = tableView.frame;
        tableView.frame = CGRectMake(oldTableFrame.origin.x, oldTableFrame.origin.y+offset, oldTableFrame.size.width, oldTableFrame.size.height-offset);
    }
}

- (NSInteger)meatIndex {
    if ([self.personalIngredients count] > 0) {
        return 1;
    }
    
    return 0;
}

- (NSInteger)produceIndex {
    if ([self.personalIngredients count] > 0) {
        return 2;
    }
    
    return 1;
}

- (NSInteger)othersIndex {
    if ([self.personalIngredients count] > 0) {
        return 3;
    }
    
    return 2;
}

- (void)swapTableView:(UITableView *)tableView {
    if (self.tableView != tableView) {
        self.tableView.hidden = YES;
        tableView.hidden = NO;
        self.tableView = tableView;
    }
}



@end
