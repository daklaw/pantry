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
//    self.navigationItem.leftBarButtonItem = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(onMenu:)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearList)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.ingredientsList = [[[[GroceryList sharedList] list] allKeys] copy];
    
    // Necessary to use GroceryListCell
    UINib *customNib = [UINib nibWithNibName:@"GroceryListCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"GroceryListCell"];
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
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
    
    [cell.checkBox setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateSelected];
    [cell.checkBox setBackgroundColor:[UIColor whiteColor]];
    [cell.checkBox addTarget:self action:@selector(selectIngredient:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkBox.tag = indexPath.row;
    
    cell.ingredientLabel.text = ingredientString;
    
    UIView *recipeSubview = [[UIView alloc] initWithFrame:CGRectMake(35, 25, cell.frame.size.width-35, CELL_RECIPE_HEIGHT)];
    
    NSInteger enumeration = 0;
    BOOL checked = YES;
    for (NSString *recipe in [dict allKeys]) {
        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0+enumeration*CELL_RECIPE_HEIGHT, 10, 10)];
        [detailButton setImage:[UIImage imageNamed:@"checkboxUnchecked"] forState:UIControlStateNormal];
        [detailButton setImage:[UIImage imageNamed:@"checkboxChecked"] forState:UIControlStateSelected];
        [detailButton addTarget:self action:@selector(selectIngredient:) forControlEvents:UIControlEventTouchUpInside];
        [detailButton setBackgroundColor:[UIColor whiteColor]];
        [detailButton setTag:(indexPath.row+1)*RECIPE_CHECKBOX_BUTTON_TAG_OFFSET+enumeration];
        
        NSMutableDictionary *ingredientDict = [dict objectForKey:recipe];
        UILabel *ingredientLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, enumeration*CELL_RECIPE_HEIGHT, cell.frame.size.width-35, 13.0f)];
        ingredientLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
        ingredientLabel.backgroundColor = [UIColor clearColor];
        ingredientLabel.textColor = [UIColor whiteColor];
        ingredientLabel.text = [ingredientDict objectForKey:@"ingredient"];
        
        UILabel *recipeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, CELL_RECIPE_INGREDIENT_HEIGHT+enumeration*CELL_RECIPE_HEIGHT, cell.frame.size.width-35, CELL_RECIPE_DETAIL_HEIGHT)];
        recipeLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
        recipeLabel.backgroundColor = [UIColor clearColor];
        recipeLabel.textColor = [UIColor whiteColor];
        recipeLabel.text = recipe;
        
        [recipeSubview addSubview:detailButton];
        [recipeSubview addSubview:ingredientLabel];
        [recipeSubview addSubview:recipeLabel];
        [cell.contentView addSubview:recipeSubview];
        
        if ([[ingredientDict objectForKey:@"checked"] boolValue]) {
            [detailButton setSelected:[[ingredientDict objectForKey:@"checked"] boolValue]];
        }
        else {
            checked = NO;
        }
        
        [cell.checkBox setSelected:checked];
        
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

- (void) onDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) selectIngredient:(UIButton *)sender {
    // Unnessarily complicated, but I'm tired will need to refactor big time
    [sender setSelected:!sender.selected];
    
    if (sender.tag < RECIPE_CHECKBOX_BUTTON_TAG_OFFSET) {
        GroceryListCell *cell = (GroceryListCell *)[[[sender superview] superview] superview];
        NSMutableDictionary *dict = [[[GroceryList sharedList] list] objectForKey:self.ingredientsList[sender.tag]];
        for (NSString *key in [dict allKeys]) {
            dict[key][@"checked"] = [NSNumber numberWithBool:sender.selected];
        }
        for (int i = 0; i < [[dict allKeys] count]; i++) {
            UIButton *detailButton = (UIButton *)[cell.contentView viewWithTag:(sender.tag+1)*RECIPE_CHECKBOX_BUTTON_TAG_OFFSET+i];
            [detailButton setSelected:sender.selected];
            
        }
    }
    else {
        NSInteger listIndex = (sender.tag / RECIPE_CHECKBOX_BUTTON_TAG_OFFSET) - 1;
        NSInteger recipeIndex = sender.tag % RECIPE_CHECKBOX_BUTTON_TAG_OFFSET;
        
        NSMutableDictionary *dict = [[[GroceryList sharedList] list] objectForKey:self.ingredientsList[listIndex]];
        dict[[dict allKeys][recipeIndex]][@"checked"] = [NSNumber numberWithBool:sender.selected];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[[GroceryList sharedList] list] forKey:@"groceryList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
@end
