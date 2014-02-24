//
//  NSMutableArray+Additions.m
//  pantry
//
//  Created by David Law on 2/24/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "NSMutableArray+Additions.h"

@implementation NSMutableArray (Additions)

+ (NSMutableArray *)removeDuplicates:(NSMutableArray *)array {
    return [[[NSSet setWithArray:array] allObjects] copy];
}

@end
