//
//  IngredientsFilter.m
//  pantry
//
//  Created by David Law on 2/23/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "IngredientsFilter.h"

@implementation IngredientsFilter

@synthesize filters;

+ (id)instance {
    static IngredientsFilter *ingredients = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ingredients= [[self alloc] init];
        ingredients.filters = [[NSMutableSet alloc] init];
    });
    
    return ingredients;
}

- (void)addFilter:(NSString *)ingredient {
    [self.filters addObject:ingredient];
}

- (void)removeFilter:(NSString *)ingredient {
    [self.filters removeObject:ingredient];
}

- (BOOL)hasFilter:(NSString *)ingredient {
    return [self.filters containsObject:ingredient];
}

- (void)clearFilters {
    [self.filters removeAllObjects];
}


@end
