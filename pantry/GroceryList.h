//
//  GroceryList.h
//  pantry
//
//  Created by David Law on 2/18/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipe.h"

@interface GroceryList : NSObject {
    NSMutableDictionary *list;
}

@property (nonatomic, strong) NSMutableDictionary *list;

+ (id)sharedList;

- (void)addRecipe:(Recipe *)recipe;
- (void)clearGroceryList;

@end
