//
//  KTBFeed.m
//  KTBFactoryGirlExample
//
//  Created by Kevin Barrett on 3/26/14.
//  Copyright (c) 2014 Little Spindle, LLC. All rights reserved.
//

#import "KTBFeed.h"

@implementation KTBFeed

- (NSString *)description {
    return [NSString stringWithFormat:@"Feed for user %@ at %@, items: %@", self.userID, self.timestamp, self.items];
}

@end
