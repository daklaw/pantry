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

static const NSInteger maxSliderValue = 11;
static const NSInteger minSliderValue = 0;
@interface FiltersViewController ()

@property (strong, nonatomic) IBOutlet UISlider *prepTimeSlider;
@property (strong, nonatomic) IBOutlet UILabel *prepTimeLabel;
@property (strong, nonatomic) IBOutlet UIView *testView;
@property (strong, nonatomic) NSMutableSet *ingredients;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;

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
    self.ingredients = [[NSMutableSet alloc] init];
    
    // Load previous ingredients into Ingredients Field
    if ([[Filter instance] ingredientFilters]) {
        for (NSString *ingredient in [[Filter instance] ingredientFilters]) {
            [self.ingredients addObject:ingredient];
        }
    }
    [self layoutTokens];
    
    self.prepTimeSlider.maximumValue = maxSliderValue;
    self.prepTimeSlider.minimumValue = minSliderValue;
    // TODO: Set slider value to what it was previously (if it exists)
    [self.prepTimeSlider setValue:86400];
    [self.prepTimeSlider setContinuous:YES];
    [self.prepTimeSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.editButton addTarget:self action:@selector(onEditIngredients:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton addTarget:self action:@selector(onClearIngredients:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateIngredientsField:) name:DidAddIngredientFilter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeIngredientField:) name:DidRemoveIngredientFilter object:nil];
    
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
        [self.ingredients addObject:ingredient];
    }
}

- (void)removeIngredientField: (NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *ingredient = [userInfo objectForKey:@"ingredient"];
    [self.ingredients removeObject:ingredient];
}

- (void) layoutTokens {
    for (UIView *subview in [self.testView subviews]) {
        [subview removeFromSuperview];
    }
    if ([self.ingredients count] > 0) {
        NSInteger xMargin = 5;
        NSInteger yMargin = 5;
        CGFloat xOrigin = 0.0;
        CGFloat yOrigin = 0.0;
        for (NSString *ingredient in self.ingredients) {
            TIToken *token = [[TIToken alloc] initWithTitle:ingredient];
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
        [self.clearButton setHidden:NO];
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
        [self.clearButton setHidden:YES];
    }
    
}

- (void)sliderValueChanged:(UISlider *)slider {
    NSArray *labelArray = @[@"< 5 minutes", @"< 10 minutes", @"< 15 minutes", @"< 20 minutes", @"< 30 minutes", @"< 45 minutes", @"< 1 hour", @"< 2 hours", @"< 3 hours", @"< 6 hours", @"< 12 hours", @"No Limit"];
    
    self.prepTimeLabel.text = [labelArray objectAtIndex:(NSInteger)slider.value];
}

- (void)onCancel:(id)sender {
    [[Filter instance] clearIngredientFilters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onClearIngredients:(id)sender {
    // Reset Ingredients
    [self.ingredients removeAllObjects];
    [[Filter instance] removeAllIngredientFilters];
    [self layoutTokens];
}

- (void)onDoneFilter:(id)sender {
    NSInteger sliderValue = (NSInteger)self.prepTimeSlider.value;
    if (sliderValue == 11) {
        [[Filter instance] clearMaxPrepTime];
    }
    else {
        NSArray *minutesArray = @[@5, @10, @15, @20, @30, @45, @60, @120, @180, @360, @720];
        NSNumber *minutes = [minutesArray objectAtIndex:(NSInteger)self.prepTimeSlider.value];
        NSInteger seconds = [minutes integerValue] * 60;
        [[Filter instance] setMaxPrepTime:seconds];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DidFinishFilter object:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}



@end
