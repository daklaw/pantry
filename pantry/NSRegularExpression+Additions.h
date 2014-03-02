//
//  NSRegularExpression+Additions.h
//  pantry
//
//  Created by David Law on 2/25/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRegularExpression (Additions)
+ (NSMutableArray *)allGroupsInFirstMatch:(NSString *)string regularExpressionString:(NSString *)regex;
@end
