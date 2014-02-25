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
        self.ingredients = [data objectForKey:@"ingredients"];
        self.rating = [[data valueForKey:@"rating"] integerValue];
        NSString *seconds = [data valueForKey:@"totalTimeInSeconds"];
        
        // Cook Time can be null
        if (seconds && ![seconds isKindOfClass:[NSNull class]]) {
            self.cookTime = [seconds integerValue];
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
    return [self.ingredients count];
}


@end
