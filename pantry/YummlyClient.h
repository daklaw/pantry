//
//  YummlyClient.h
//  pantry
//
//  Created by David Law on 2/14/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface YummlyClient : AFHTTPRequestOperationManager

- (void)setSearchQuery:(NSString *)query;
- (void)setMaximumTime:(NSInteger)time;
- (void)addAllowedIngredient:(NSString *)ingredient;
- (void)addAllowedIngredients:(NSArray *)ingredients;
- (AFHTTPRequestOperation *)search:(void (^) (AFHTTPRequestOperation *operation, id response))success
                           failure:(void (^) (AFHTTPRequestOperation *operation, NSError *error))failure;
- (AFHTTPRequestOperation *)getRecipe:(NSString *)recipeId
                              success:(void (^) (AFHTTPRequestOperation *operation, id response))success
                              failure:(void (^) (AFHTTPRequestOperation *operation, NSError *error))failure;
- (AFHTTPRequestOperation *)ingredient:(void (^) (AFHTTPRequestOperation *operation, id response))success
                               failure:(void (^) (AFHTTPRequestOperation *operation, NSError *error))failure;


@end
