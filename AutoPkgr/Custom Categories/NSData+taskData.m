//
//  NSString+serialized.m
//  AutoPkgr
//
//  Created by Eldon on 5/5/15.
//  Copyright (c) 2015 The Linde Group, Inc. All rights reserved.
//

#import "NSData+taskData.h"
#import "NSString+cleaned.h"

@implementation NSData (NSTaskData)

- (id)taskData_serializePropertyList:(NSPropertyListFormat *)format
{
    id results = nil;
    if (self.length) {
        // Initialize our dict
        results = [NSPropertyListSerialization propertyListWithData:self
                                                            options:NSPropertyListImmutable
                                                             format:format
                                                              error:nil];
    }
    return results;
}

- (NSString *)taskData_string
{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSArray *)taskData_splitLines
{
    return [self.taskData_string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (id)taskData_serializePropertyList
{
    return [self taskData_serializePropertyList:nil];
}

- (NSDictionary *)taskData_serializedDictionary
{
    id results = self.taskData_serializePropertyList;
    if ([results isKindOfClass:[NSDictionary class]]) {
        return results;
    }
    return nil;
}

- (BOOL)taskData_isInteractive {
    NSArray *defaultMatches = @[@"[y/n]:",
                                @"[YES/NO]:",
                                @"Password:",
                                @"Password",
                                ];
    return [self taskData_isInteractiveWithStrings:defaultMatches];
   }

- (BOOL)taskData_isInteractiveWithStrings:(NSArray *)interactiveStrings {
    NSString *message = [[[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:interactiveStrings.count];
    for (NSString *string in interactiveStrings) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[CD] %@", string];
        [predicates addObject:p];
    }
    NSCompoundPredicate *evalPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
    if ([evalPredicate evaluateWithObject:message]) {
        return YES;
    }
    return NO;
}

@end