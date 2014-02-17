//
//  RecipeViewController.m
//  pantry
//
//  Created by Phil Wee on 2/16/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeViewController.h"
#import "YummlyClient.h"
#import "Recipe.h"
#import "RecipeCell.h"
#import "RecipeDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface RecipeViewController ()

@property (nonatomic, strong) NSMutableArray *recipes;

@end

@implementation RecipeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self reload];
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
    return self.recipes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyRecipeCell";
    RecipeCell *cell = (RecipeCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Recipe *recipe = self.recipes[indexPath.row];
    cell.nameLabel.text = recipe.name;
    cell.numIngredientsLabel.text = [NSString stringWithFormat:@"%d", recipe.ingredients.count];
    NSLog(@"%@", recipe.imageURL);
    [cell.recipeImage setImageWithURL:recipe.imageURL];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Currently hardwired to be the size of a RecipeCell
    return 321.0f;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
    RecipeDetailViewController *vc = [[RecipeDetailViewController alloc] initWithNibName:@"RecipeDetailViewController" bundle:nil];
    vc.recipe = self.recipes[indexPath.row];

    YummlyClient *client = [[YummlyClient alloc] init];
    [client getRecipe:vc.recipe.yummlyID
              success:^(AFHTTPRequestOperation *operation, id response) {
                  NSLog(@"%@", response);
                  
                  // Populate additional fields from recipe details
                  vc.recipe.ingredientLines = response[@"ingredientLines"];
                  NSDictionary *source = response[@"source"];
                  vc.recipe.sourceRecipeURL = [NSURL URLWithString:[source objectForKey:@"sourceRecipeUrl"]];
                  
                  // Navigate to recipe details
                  [self.navigationController pushViewController:vc animated:YES];
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"%@", error);
              }];
}

#pragma mark - Private methods
- (void)reload
{
    self.recipes = [[NSMutableArray alloc] init];
    
    YummlyClient *client = [[YummlyClient alloc] init];
    [client setSearchQuery:@"Garlic"];
    [client search:^(AFHTTPRequestOperation *operation, id response) {
        for (id data in response[@"matches"]) {
            [self.recipes addObject:[[Recipe alloc] initWithDictionary:data]];
        }
        [self.tableView reloadData];
        /*
        for (id dish in self.dishes) {
            Dish *d = dish;
            [client getRecipe:d.yummlyID
                      success:^(AFHTTPRequestOperation *operation, id response) {
                          NSLog(@"%@", response);
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"%@", error);
                      }];
            NSLog(@"%@", d.yummlyID);
        }
        */
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
