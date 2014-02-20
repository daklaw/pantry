//
//  GroceryList.h
//  pantry
//
//  Created by David Law on 2/18/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroceryList : NSObject {
    NSMutableArray *list;
}

@property (nonatomic, retain) NSMutableArray *list;

+ (id)sharedList;

- (void)addItem:(NSString *)item;
- (void)clearGroceryList;

@end
