//
//  Filter.h
//  pantry
//
//  Created by David Law on 3/4/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DidAddIngredientFilter;

@interface Filter : NSObject {
    NSMutableSet *ingredientFilters;
    NSInteger maximumTime;
}

@property (nonatomic, strong) NSMutableSet *ingredientFilters;
@property (nonatomic, assign) NSInteger maximumTime;

+(id) instance;

- (void)addIngredientFilter:(NSString *)ingredient;
- (void)removeIngredientFilter:(NSString *)ingredient;
- (BOOL)hasIngredientFilter:(NSString *)ingredient;
- (void)clearIngredientFilters;
- (void)setMaximumTime:(NSInteger)time;


@end
