//
//  GroceryList.m
//  pantry
//
//  Created by David Law on 2/18/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "GroceryList.h"
#import "Recipe.h"

@implementation GroceryList

@synthesize list;

+ (id)sharedList {
    static GroceryList *sharedGroceryList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *groceryList = [[NSUserDefaults standardUserDefaults] objectForKey:@"groceryList"];
        if (groceryList) {
            sharedGroceryList = [[self alloc] initWithList:groceryList];
        }
        else {
            sharedGroceryList = [[self alloc] init];
            sharedGroceryList.list = [[NSMutableDictionary alloc] init];
        }
    });
    
    return sharedGroceryList;
}

- (id)initWithList:(NSMutableDictionary *)groceryList {
    self = [super init];
    
    if (self) {
        self.list = groceryList;
    }
    
    return self;
}

+ (NSString *)sanitizeItem:(NSString *)item {
    NSMutableString *s = [NSMutableString stringWithString:item];
    NSRange start = [s rangeOfString:@","];
    
    if (start.location != NSNotFound) {
        [s deleteCharactersInRange:(NSRange){start.location, [s length] - start.location}];
    }
    
    start = [s rangeOfString:@"("];
    NSRange end = [s rangeOfString:@")"];
    if (start.location != NSNotFound && end.location != NSNotFound) {
        [s deleteCharactersInRange:(NSRange){ start.location, end.location - start.location + 1}];
    }
    

    return s;
}

- (void)addRecipe:(Recipe *)recipe {
    for (id ingredient in recipe.ingredients) {
        NSString *ingredientName = [[[GroceryList sanitizeItem:[ingredient valueForKey:@"ingredientName"]] capitalizedString] stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceCharacterSet]];
        NSString *totalIngredient = [[GroceryList sanitizeItem:[ingredient valueForKey:@"totalString"]] capitalizedString];
        NSMutableDictionary *item = [self.list objectForKey:ingredientName];
        if (item) {
            [item setObject:totalIngredient forKey:recipe.name];
        }
        else {
            item = [[NSMutableDictionary alloc] init];
            [self.list setObject:item forKey:ingredientName];
            [item setObject:totalIngredient forKey:recipe.name];
        }
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.list forKey:@"groceryList"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
}

- (void)clearGroceryList {
    [self.list removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"groceryList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
