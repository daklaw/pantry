//
//  GroceryViewController.m
//  pantry
//
//  Created by Phil Wee on 2/17/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "GroceryViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "GroceryList.h"
#import "GroceryListCell.h"

static const NSInteger RECIPE_CHECKBOX_BUTTON_TAG_OFFSET = 1000;
static const CGFloat CELL_INGREDIENT_MAIN_HEIGHT = 25.0f;
static const CGFloat CELL_RECIPE_HEIGHT = 26.0f;
static const CGFloat CELL_RECIPE_DETAIL_HEIGHT = 13.0f;
static const CGFloat CELL_RECIPE_INGREDIENT_HEIGHT = 13.0f;

@interface GroceryViewController ()
@property (nonatomic, strong) NSMutableArray *ingredientsList;

- (void) clearList;
@end

@implementation GroceryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Grocery List";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(onMenu:)];
    
    UIImage *resetIcon = [UIImage imageNamed:@"Reset"];
    CGRect resetFrame = CGRectMake(0, 0, 20, 20);
    UIButton *resetButton = [[UIButton alloc] initWithFrame:resetFrame];
    [resetButton setBackgroundImage:resetIcon forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(clearList) forControlEvents:UIControlEventTouchUpInside];
    [resetButton setShowsTouchWhenHighlighted:YES];
    UIBarButtonItem *resetBarButton = [[UIBarButtonItem alloc] initWithCustomView:resetButton];
    
    self.navigationItem.rightBarButtonItem = resetBarButton;
    self.ingredientsList = [[[[GroceryList sharedList] list] allKeys] copy];
    
    // Necessary to use GroceryListCell
    UINib *customNib = [UINib nibWithNibName:@"GroceryListCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"GroceryListCell"];
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [[[GroceryList sharedList] list] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Actually dynamically alter height
    NSDictionary *dict = [[[GroceryList sharedList] list] objectForKey:self.ingredientsList[indexPath.row]];
    
                             
    // How to get the UITableViewCell associated with this indexPath?
    return CELL_INGREDIENT_MAIN_HEIGHT + CELL_RECIPE_HEIGHT * [[dict allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroceryListCell";
    GroceryListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[GroceryListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setBackgroundColor:[UIColor darkGrayColor]];
    [cell.ingredientLabel setTextColor:[UIColor whiteColor]];
    [cell.ingredientLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    
    // Configure the cell...
    NSString *ingredientString = self.ingredientsList[indexPath.row];
    
    NSDictionary *dict = [[[GroceryList sharedList] list] objectForKey:self.ingredientsList[indexPath.row]];
    
    [cell.checkBox setImage:[UIImage imageNamed:@"checkboxClosed"] forState:UIControlStateSelected];
    [cell.checkBox addTarget:self action:@selector(selectIngredient:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkBox.tag = indexPath.row;
    
    cell.ingredientLabel.text = ingredientString;
    
    UIView *recipeSubview = [[UIView alloc] initWithFrame:CGRectMake(35, 25, cell.frame.size.width-35, CELL_RECIPE_HEIGHT)];
    
    NSInteger enumeration = 0;
    for (NSString *recipe in [dict allKeys]) {
        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0+enumeration*CELL_RECIPE_HEIGHT, 10, 10)];
        [detailButton setImage:[UIImage imageNamed:@"checkboxUnmarked"] forState:UIControlStateNormal];
        [detailButton setImage:[UIImage imageNamed:@"checkboxClosed"] forState:UIControlStateSelected];
        [detailButton addTarget:self action:@selector(selectIngredient:) forControlEvents:UIControlEventTouchUpInside];
        [detailButton setTag:RECIPE_CHECKBOX_BUTTON_TAG_OFFSET+enumeration];
        
        UILabel *ingredientLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, enumeration*CELL_RECIPE_HEIGHT, cell.frame.size.width-35, 13.0f)];
        ingredientLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
        ingredientLabel.backgroundColor = [UIColor clearColor];
        ingredientLabel.textColor = [UIColor whiteColor];
        ingredientLabel.text = [dict objectForKey:recipe];
        
        UILabel *recipeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, CELL_RECIPE_INGREDIENT_HEIGHT+enumeration*CELL_RECIPE_HEIGHT, cell.frame.size.width-35, CELL_RECIPE_DETAIL_HEIGHT)];
        recipeLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
        recipeLabel.backgroundColor = [UIColor clearColor];
        recipeLabel.textColor = [UIColor whiteColor];
        recipeLabel.text = recipe;
        
        [recipeSubview addSubview:detailButton];
        [recipeSubview addSubview:ingredientLabel];
        [recipeSubview addSubview:recipeLabel];
        [cell.contentView addSubview:recipeSubview];
        
        enumeration += 1;
    }

    
    
    return cell;
}

# pragma mark - Private Methods

- (void) onMenu:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void) clearList {
    [[GroceryList sharedList] clearGroceryList];
    [self.tableView reloadData];
}

- (void) selectIngredient:(UIButton *)sender {
    [sender setSelected:!sender.selected];
    
    if (sender.tag < RECIPE_CHECKBOX_BUTTON_TAG_OFFSET) {
        GroceryListCell *cell = (GroceryListCell *)[[[sender superview] superview] superview];
        NSDictionary *dict = [[[GroceryList sharedList] list] objectForKey:self.ingredientsList[sender.tag]];
        for (int i = 0; i < [[dict allKeys] count]; i++) {
            UIButton *detailButton = (UIButton *)[cell.contentView viewWithTag:RECIPE_CHECKBOX_BUTTON_TAG_OFFSET+i];
            [detailButton setSelected:sender.selected];
        }
    }
    
}
@end
