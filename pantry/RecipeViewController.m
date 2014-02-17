//
//  RecipeViewController.m
//  pantry
//
//  Created by Phil Wee on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeViewController.h"
#import "YummlyClient.h"
#import "Dish.h"
#import "RecipeCell.h"
#import "UIImageView+AFNetworking.h"

@interface RecipeViewController ()

@property (nonatomic, strong) NSMutableArray *dishes;
@property (nonatomic, strong) NSMutableArray *selectedIngredients;

@end

@implementation RecipeViewController

- (id)initWithIngredients:(NSMutableArray *)ingredients {
    self = [super init];
    if (self) {
        self.selectedIngredients = ingredients;
        [self reload];
    }
    
    return self;
}
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
    
    // Load custom UITableViewCell from nib
    UINib *customNib = [UINib nibWithNibName:@"RecipeCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"MyRecipeCell"];
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
    return self.dishes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyRecipeCell";
    RecipeCell *cell = (RecipeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Dish *dish = self.dishes[indexPath.row];
    cell.nameLabel.text = dish.name;
    cell.numIngredientsLabel.text = [NSString stringWithFormat:@"%d", dish.ingredients.count];

    [cell.recipeImage setImageWithURL:dish.imageURL];
    
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


#pragma mark - Private methods
- (void)reload
{
    self.dishes = [[NSMutableArray alloc] init];
    
    YummlyClient *client = [[YummlyClient alloc] init];

    [client addAllowedIngredients:self.selectedIngredients];
    [client search:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        for (id data in response[@"matches"]) {
            [self.dishes addObject:[[Dish alloc] initWithDictionary:data]];
        }
        [self.tableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
