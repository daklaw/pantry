//
//  RecipeWebViewController.m
//  pantry
//
//  Created by Phil Wee on 3/3/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeWebViewController.h"

@interface RecipeWebViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *directionsView;

@end

@implementation RecipeWebViewController

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

    self.title = self.recipeName;
    if (self.recipeURL) {
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.recipeURL];
        self.directionsView.scalesPageToFit = YES;
        [self.directionsView loadRequest:requestObj];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
