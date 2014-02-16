//
//  SampleViewController.m
//  pantry
//
//  Created by David Law on 2/14/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "SampleViewController.h"
#import "YummlyClient.h"
#import "Dish.h"

@interface SampleViewController ()

@property (nonatomic, strong) NSMutableArray *dishes;

@end

@implementation SampleViewController

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
    self.dishes = [[NSMutableArray alloc] init];
    
    YummlyClient *client = [[YummlyClient alloc] init];
    [client setSearchQuery:@"Garlic"];
    [client search:^(AFHTTPRequestOperation *operation, id response) {
        for (id data in response[@"matches"]) {
            [self.dishes addObject:[[Dish alloc] initWithDictionary:data]];
        }
        for (id dish in self.dishes) {
            Dish *d = dish;
            [client getRecipe:d.yummlyID
                      success:^(AFHTTPRequestOperation *operation, id response) {
                          NSLog(@"%@", response);
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"%@", error);
                      }];
            NSLog(@"%@", d.recipeURL);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
