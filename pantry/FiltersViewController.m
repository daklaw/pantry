//
//  FiltersViewController.m
//  pantry
//
//  Created by David Law on 3/4/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "FiltersViewController.h"
#import "Filter.h"
#import "TiTokenField.h"
#import "IngredientListViewController.h"
#import "RecipeViewController.h"

@interface FiltersViewController ()

@property (strong, nonatomic) IBOutlet TITokenField *ingredientsField;
@property (strong, nonatomic) IBOutlet UISlider *prepTimeSlider;
@property (strong, nonatomic) IBOutlet UILabel *prepTimeLabel;
@property (strong, nonatomic) IBOutlet UIView *testView;
@property (strong, nonatomic) NSMutableArray *tokens;
@property (strong, nonatomic) IBOutlet UIButton *editButton;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Filters";
    }
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tokens = [[NSMutableArray alloc] init];
    
    // Load previous ingredients into Ingredients Field
    if ([[Filter instance] ingredientFilters]) {
        for (NSString *ingredient in [[Filter instance] ingredientFilters]) {
            [self.tokens addObject:[[TIToken alloc] initWithTitle:ingredient]];
        }
    }
    [self layoutTokens];
    
    self.prepTimeSlider.maximumValue = 11;
    self.prepTimeSlider.minimumValue = 0;
    [self.prepTimeSlider setValue:86400];
    [self.prepTimeSlider setContinuous:YES];
    [self.prepTimeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.editButton addTarget:self action:@selector(onEditIngredients:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIngredientsField:) name:DidAddIngredientFilter object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneFilter:)];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutTokens];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onEditIngredients:(id)sender {
    [self.navigationController pushViewController:[[IngredientListViewController alloc] init] animated:NO];
}

- (void)updateIngredientsField: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *ingredient = [userInfo objectForKey:@"ingredient"];
    if (ingredient) {
        [self.tokens addObject:[[TIToken alloc] initWithTitle:ingredient]];
    }
}

- (void) layoutTokens {
    for (UIView *subview in [self.testView subviews]) {
        [subview removeFromSuperview];
    }
    if ([self.tokens count] > 0) {
        NSInteger xMargin = 5;
        NSInteger yMargin = 5;
        CGFloat xOrigin = 0.0;
        CGFloat yOrigin = 0.0;
        for (TIToken *token in self.tokens) {
            CGPoint origin = CGPointMake(xOrigin, yOrigin);
            if (xOrigin + token.frame.size.width > self.testView.bounds.size.width) {
                xOrigin = 0.0;
                yOrigin += token.font.lineHeight + 5 + yMargin;
                origin = CGPointMake(xOrigin, yOrigin);
            }
            [token setFrame:(CGRect){origin, token.bounds.size}];
            [self.testView addSubview:token];
            xOrigin = xOrigin + token.bounds.size.width + xMargin;
        }
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else {
        CGFloat yOrigin = self.testView.bounds.size.height / 2.0 - 10.0f;
        UILabel *noIngredients = [[UILabel alloc] init];
        [noIngredients setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
        [noIngredients setTextColor:[UIColor whiteColor]];
        noIngredients.text = @"No Ingredient Filters";
        [noIngredients sizeToFit];
        CGFloat xOrigin = (self.testView.bounds.size.width - noIngredients.bounds.size.width) / 2.0;
        [noIngredients setFrame:(CGRect){CGPointMake(xOrigin, yOrigin), noIngredients.bounds.size}];
        [self.testView addSubview:noIngredients];
        [self.editButton setTitle:@"Add" forState:UIControlStateNormal];
    }
    
}

- (void)sliderValueChanged:(UISlider *)slider {
    self.prepTimeLabel.text = [self labelForSlide:(NSInteger)slider.value];
}

- (NSString *)labelForSlide:(NSInteger)value {
    if (value == 0) {
        return @"< 5 minutes";
    }
    else if (value == 1) {
        return @"< 10 minutes";
    }
    else if (value == 2) {
        return @"< 15 minutes";
    }
    else if (value == 3) {
        return @"< 20 minutes";
    }
    else if (value == 4) {
        return @"< 30 minutes";
    }
    else if (value == 5) {
        return @"< 45 minutes";
    }
    else if (value == 6) {
        return @"< 1 hour";
    }
    else if (value == 7) {
        return @"< 2 hours";
    }
    else if (value == 8) {
        return @"< 3 hours";
    }
    else if (value == 9) {
        return @"< 6 hours";
    }
    else if (value == 10) {
        return @"< 12 hours";
    }
    
    return @"No Limit";
}

- (void)onCancel:(id)sender {
    [[Filter instance] clearIngredientFilters];
    [self.navigationController pushViewController:[[RecipeViewController alloc] init] animated:NO];
}

- (void)onDoneFilter:(id)sender {
    [self.navigationController pushViewController:[[RecipeViewController alloc]init] animated:NO];
}



@end
