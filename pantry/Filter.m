//
//  Filter.m
//  pantry
//
//  Created by David Law on 3/4/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "Filter.h"
NSString * const DidAddIngredientFilter = @"DidAddIngredientFilter";

@implementation Filter

@synthesize ingredientFilters;
@synthesize maximumTime;

+ (id)instance {
    static Filter *filter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        filter = [[self alloc] init];
        filter.ingredientFilters = [[NSMutableSet alloc] init];
    });
    
    return filter;
}

- (void)addIngredientFilter:(NSString *)ingredient {
    [self.ingredientFilters addObject:ingredient];
}

- (void)removeIngredientFilter:(NSString *)ingredient {
    [self.ingredientFilters removeObject:ingredient];
}

- (BOOL)hasIngredientFilter:(NSString *)ingredient {
    return [self.ingredientFilters containsObject:ingredient];
}

- (void)clearIngredientFilters {
    [self.ingredientFilters removeAllObjects];
}

- (void)setMaximumTime:(NSInteger)time {
    self.maximumTime = time;
}


@end
