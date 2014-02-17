//
//  Recipe.h
//  pantry
//
//  Created by David Law on 2/14/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recipe : NSObject

@property (nonatomic, strong) NSString *yummlyID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *ingredients;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *recipeURL;
@property (nonatomic, strong) NSDictionary *data;
@property NSInteger rating;
@property NSInteger cookTime;
// properties that are retrieved only from recipe details
@property (nonatomic, strong) NSArray *ingredientLines;
@property (nonatomic, strong) NSURL *sourceRecipeURL;

- (id)initWithDictionary:(NSDictionary *)data;

@end
