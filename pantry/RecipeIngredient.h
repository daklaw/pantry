//
//  RecipeIngredient.h
//  pantry
//
//  Created by David Law on 2/25/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecipeIngredient : NSObject

@property (nonatomic, strong) NSString *quantity;
@property (nonatomic, strong) NSString *ingredientName;
@property (nonatomic, strong) NSString *totalString;

- (id) initWithString:(NSString *) string;

@end
