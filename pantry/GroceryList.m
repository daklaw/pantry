//
//  GroceryList.m
//  pantry
//
//  Created by David Law on 2/18/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "GroceryList.h"

@implementation GroceryList

@synthesize list;

+ (id)sharedList {
    static GroceryList *sharedGroceryList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGroceryList = [[self alloc] init];
        sharedGroceryList.list = [[NSMutableArray alloc] init];
    });
    
    return sharedGroceryList;
}

+ (NSString *)sanitizeItem:(NSString *)item {
    NSMutableString *s = [NSMutableString stringWithString:item];
    NSLog(@"Here");
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

- (void)addItem:(NSString *)item {
    [self.list addObject:[GroceryList sanitizeItem:item]];
    NSLog(@"%@", self.list);
}

- (void)clearGroceryList {
    [self.list removeAllObjects];
}

@end
