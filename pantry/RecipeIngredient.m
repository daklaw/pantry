//
//  RecipeIngredient.m
//  pantry
//
//  Created by David Law on 2/25/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "RecipeIngredient.h"
#import "NSRegularExpression+Additions.h"

static const NSString *ingredientRegex = @"([0-9]+ ?(?:[0-9]*[/.]?[0-9]*)? *(?:(?:(?:ounce|slices|oz|fl oz|cup|pound|lb|tablespoon|T|tbsp.?|tsp.?|teaspoon|cup|gallon|quart)s?))?) (.*)$";

@implementation RecipeIngredient

- (id) initWithString:(NSString *) string {
    self = [super init];
    
    if (self) {
        self.totalString = string;
        NSMutableArray *matches = [NSRegularExpression allGroupsInFirstMatch:string regularExpressionString:(NSString *)ingredientRegex];
        if ([matches count]) {
            if ([matches objectAtIndex:0] != [NSNull null]) {
                self.quantity = [matches objectAtIndex:0];
            }
            
            self.ingredientName = [matches objectAtIndex:1];
        }
        else {
            self.ingredientName = self.totalString;
        }
        
        self.ingredientName = [[self.ingredientName componentsSeparatedByString:@" for "] objectAtIndex:0];
        self.ingredientName = [[self.ingredientName componentsSeparatedByString:@" to "] objectAtIndex:0];
        
    }

    return self;
}

- (NSString *)description {
    return self.totalString;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.quantity = [decoder decodeObjectForKey:@"quantity"];
        self.ingredientName = [decoder decodeObjectForKey:@"ingredientName"];
        self.totalString = [decoder decodeObjectForKey:@"totalString"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.quantity forKey:@"quantity"];
    [encoder encodeObject:self.ingredientName forKey:@"ingredientName"];
    [encoder encodeObject:self.totalString forKey:@"totalString"];
}
@end
