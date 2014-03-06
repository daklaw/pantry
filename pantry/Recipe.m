//
//  Recipe.m
//  pantry
//
//  Created by David Law on 2/14/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "Recipe.h"

static const NSString *imageDimension = @"320";

@implementation Recipe

-(id)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.yummlyID = [data valueForKey:@"id"];
        self.name = [data valueForKey:@"recipeName"];
        self.rating = [[data valueForKey:@"rating"] integerValue];
        self.ingredients = [[NSMutableArray alloc] init];
        NSString *seconds = [data valueForKey:@"totalTimeInSeconds"];
        
        // Cook Time can be null
        if (seconds && ![seconds isKindOfClass:[NSNull class]]) {
            self.cookTime = [seconds integerValue];
            NSLog(@"Here");
        }
        // Extract a URL from the response, then replace the Size Value with 360 px
        NSDictionary *imageUrls = data[@"imageUrlsBySize"];
        if ([imageUrls count] > 0) {
            NSString *key = [imageUrls allKeys][0];
            NSString *url = imageUrls[key];

            self.imageURL = [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:key
                                                 withString:(NSString * const)imageDimension
                                                    options:0
                                                      range:NSMakeRange([url length]-5, 4)]];
        }
    }
    
    return self;
    
}

- (void)recipeURLWithString:(NSString *)url {
    self.recipeURL = [NSURL URLWithString:url];
}

- (NSUInteger)ingredientCount {
    if ([self.ingredients count]) {
        return [self.ingredients count];
    }
    
    return [[self.data valueForKey:@"ingredients"] count];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.yummlyID = [decoder decodeObjectForKey:@"yummlyID"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.ingredients = [decoder decodeObjectForKey:@"ingredients"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.recipeURL = [decoder decodeObjectForKey:@"recipeURL"];
        self.sourceRecipeURL = [decoder decodeObjectForKey:@"sourceRecipeURL"];
        self.sourceDisplayName = [decoder decodeObjectForKey:@"sourceDisplayName"];
        self.data = [decoder decodeObjectForKey:@"data"];
        self.rating = [decoder decodeIntegerForKey:@"rating"];
        self.cookTime = [decoder decodeIntegerForKey:@"cookTime"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.yummlyID forKey:@"yummlyID"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.ingredients forKey:@"ingredients"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.recipeURL forKey:@"recipeURL"];
    [encoder encodeObject:self.sourceRecipeURL forKey:@"sourceRecipeURL"];
    [encoder encodeObject:self.sourceDisplayName forKey:@"sourceDisplayName"];
    [encoder encodeObject:self.data forKey:@"data"];
    [encoder encodeInteger:self.rating forKey:@"rating"];
    [encoder encodeInteger:self.cookTime forKey:@"cookTime"];
}


@end
