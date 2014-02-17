//
//  YummlyClient.m
//  pantry
//
//  Created by David Law on 2/14/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "YummlyClient.h"

#define YUMMLY_APP_ID @"4bc3f464"
#define YUMMLY_APP_KEY @"00b5a92f34c0e221bb159e250e37ac90"
#define YUMMLY_BASE_URL @"http://api.yummly.com/v1/api"

@interface YummlyClient()

@property (nonatomic, strong) NSMutableDictionary *params;

@end

@implementation YummlyClient

- (id)init {
    NSURL *url = [NSURL URLWithString:YUMMLY_BASE_URL];
    self = [self initWithBaseURL:url];
    
    if (self) {
        // establish empty parameters
        self.params = [[NSMutableDictionary alloc] init];
        [self.params setObject:[[NSMutableArray alloc] init] forKey:@"allowedIngredient"];
    }
    
    return self;
}

-(id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    
    if (self) {
        // Set headers to establish which authentication for Yummly's API
        [self.requestSerializer setValue:YUMMLY_APP_ID forHTTPHeaderField:@"X-Yummly-App-ID"];
        [self.requestSerializer setValue:YUMMLY_APP_KEY forHTTPHeaderField:@"X-Yummly-App-Key"];
    }
    
    return self;
}

#pragma mark - Yummly Search Recipes API

- (void)setSearchQuery:(NSString *)query {
    /* Set string to query for on Yummly's API */
    
    [self.params setObject:query forKey:@"q"];
}

- (void)addAllowedIngredient:(NSString *)ingredient {
    /* Add an ingredient to the list of allowed ingredient to the query on Yummly's API */
    
    [self.params[@"allowedIngredient"] addObject:[ingredient lowercaseString]];
}

- (void)addAllowedIngredients:(NSArray *)ingredients {
    /* Add a list of ingredients to the list of allowed ingredients to the query on Yummly's API */
    [self.params[@"allowedIngredient"] addObjectsFromArray:[ingredients valueForKey:@"lowercaseString"]];
}

- (AFHTTPRequestOperation *)search:(void (^) (AFHTTPRequestOperation *operation, id response))success
                                  failure:(void (^) (AFHTTPRequestOperation *operation, NSError *error))failure {
    /* Given the established parameters, search the Yummly API for dishes/recipes */
    
    [self.params setObject:@"true" forKey:@"requirePictures"];
    return [self GET:@"recipes" parameters:self.params success:success failure:failure];
}

#pragma mark - Yummly Get Recipe API

- (AFHTTPRequestOperation *)getRecipe:(NSString *)recipeId
                              success:(void (^) (AFHTTPRequestOperation *operation, id response))success
                              failure:(void (^) (AFHTTPRequestOperation *operation, NSError *error))failure {
    /* Given a recipe ID (probably after searching) find more details about the particular dish/recipe */
    
    return [self GET:[NSString stringWithFormat:@"recipe/%@", recipeId] parameters:nil success:success failure:failure];
}

#pragma mark - Yummly Search Metadata Dictionaries

- (AFHTTPRequestOperation *)ingredient:(void (^) (AFHTTPRequestOperation *operation, id response))success
                           failure:(void (^) (AFHTTPRequestOperation *operation, NSError *error))failure {
    /* Get the dictionary of ingredients from the Yummly API */
    
    return [self GET:@"metadata/ingredient" parameters:nil success:success failure:failure];
}

@end
