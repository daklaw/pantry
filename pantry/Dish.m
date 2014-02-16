//
//  Dish.m
//  pantry
//
//  Created by David Law on 2/14/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "Dish.h"

@implementation Dish

-(id)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.yummlyID = [data valueForKey:@"id"];
        self.name = [data valueForKey:@"recipeName"];
        self.ingredients = [data objectForKey:@"ingredients"];
        self.rating = [[data valueForKey:@"rating"] integerValue];
        self.cookTime = [[data valueForKey:@"totalTimeInSeconds"] integerValue];
        
        // Extract a URL from the response, then replace the Size Value with 360 px
        NSDictionary *imageUrls = data[@"imageUrlsBySize"];
        if ([imageUrls count] > 0) {
            NSString *key = [imageUrls allKeys][0];
            NSString *url = imageUrls[key];

            self.imageURL = [NSURL URLWithString:[url stringByReplacingOccurrencesOfString:key
                                                 withString:@"360"
                                                    options:0
                                                      range:NSMakeRange([url length]-5, 4)]];
        }
    }
    
    return self;
    
}

- (void)recipeURLWithString:(NSString *)url {
    self.recipeURL = [NSURL URLWithString:url];
}


@end
