//
//  NSRegularExpression+Additions.m
//  pantry
//
//  Created by David Law on 2/25/14.
//  Copyright (c) 2014 CodePath. All rights reserved.
//

#import "NSRegularExpression+Additions.h"

@implementation NSRegularExpression (Additions)

+ (NSMutableArray *)allGroupsInFirstMatch:(NSString *)string regularExpressionString:(NSString *)regexString {
    /* 
     Method that runs a regular expression on a string and returns all the groupings (as a NSMutableArray) within the first match.
     If a grouping is not found, a NSNull object will take its place within the array
     */
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:(NSString *)regexString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    // If you find a match, grab every substring and place it into the array
    if (match) {
        for (NSUInteger i = 1;i < [match numberOfRanges];i++) {
            NSRange range = [match rangeAtIndex:i];
            // If the item cannot be found, place a NSNull object in its place
            if (range.location == NSNotFound) {
                [arr addObject:[NSNull null]];
                
            }
            else {
                [arr addObject:[string substringWithRange:range]];
            }
        }
    }
    return arr;
}
@end
