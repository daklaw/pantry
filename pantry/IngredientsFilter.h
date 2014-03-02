//
//  IngredientsFilter.h
//  pantry
//
//  Created by David Law on 2/23/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IngredientsFilter : NSObject {
    NSMutableSet *filters;
}
@property (nonatomic, strong) NSMutableSet *filters;

+(id) instance;

- (void)addFilter:(NSString *)ingredient;
- (void)removeFilter:(NSString *)ingredient;
- (BOOL)hasFilter:(NSString *)ingredient;
- (void)clearFilters;


@end
