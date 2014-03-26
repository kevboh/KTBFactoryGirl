//
//  KTBFeedItem.m
//  KTBFactoryGirlExample
//
//  Created by Kevin Barrett on 3/26/14.
//  Copyright (c) 2014 Little Spindle, LLC. All rights reserved.
//

#import "KTBFeedItem.h"

@implementation KTBFeedItem

- (NSString *)description {
    return [NSString stringWithFormat:@"<FeedItem>(%@, %@, %@ comments, %@ likes, at %@. %@.)",
            self.itemID,
            self.text,
            self.commentsCount,
            self.likesCount,
            self.URL,
            [self.deleted boolValue] ? @"Deleted" : @"Not deleted"];
}

@end
