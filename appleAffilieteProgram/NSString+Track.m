//
//  NSString+Track.m
//  appleAffilieteProgram
//
//  Created by Ariel Robles on 4/12/15.
//  Copyright (c) 2015 Ariel Robles. All rights reserved.
//

#import "NSString+Track.h"

@implementation NSString (Track)
- (BOOL)isLooselyEqualToString:(NSString *)str
{
    return [[self removeSpecialCharacters] containSubstringBothDirections:[str removeSpecialCharacters]];
}

/**
 * Tests if one string is a substring of another
 *     ie this should return true for both these comparisons:
 *     - comparing self:"Doctor P & Flux Pavilion" and substring:"Flux Pavilion"
 *     - comparing self:"Flux Pavilion" and substring:"Doctor P & Flux Pavilion"
 *
 * @param substring to compare self against
 * @return if self is a substring of substring
 */
-(BOOL)containSubstringBothDirections:(NSString*)substring
{
    if (substring == nil) return self.length == 0;
    
    if ([self rangeOfString:substring options:NSCaseInsensitiveSearch].location == NSNotFound) {
        if ([substring rangeOfString:self options:NSCaseInsensitiveSearch].location == NSNotFound) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (NSString *)removeSpecialCharacters
{
    NSMutableCharacterSet *specialCharsSet = [[NSCharacterSet letterCharacterSet] mutableCopy];
    [specialCharsSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    return [[self componentsSeparatedByCharactersInSet:[specialCharsSet invertedSet]] componentsJoinedByString:@""];
}
@end
