//
//  KTBFactoryGirlExampleTests.m
//  KTBFactoryGirlExampleTests
//
//  Created by Kevin Barrett on 3/26/14.
//  Copyright (c) 2014 Little Spindle, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KTBFactoryGirl/KTBFactoryGirl.h>
// The model classes we want to test
#import "KTBFeed.h"
#import "KTBFeedItem.h"

@interface KTBFactoryGirlExampleTests : XCTestCase

@end

@implementation KTBFactoryGirlExampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Define a feed item factory.
        [KTBFactoryGirl define:@"FeedItem" as:^(KTBFactoryGirl *feedItem) {
            // This factory generates a feed item with an incrementing ID.
            feedItem[@"id"]             = [KTBFactoryGirlSequence sequenceFrom:1];
            // The feed item will be by user 123
            feedItem[@"user_id"]        = @123;
            // With some scintillating text
            feedItem[@"text"]           = @"This is my super interesting feed item text!";
            // A lot of comments
            feedItem[@"comments_count"] = @50;
            // A few likes
            feedItem[@"likes_count"]    = @12;
            // A permalink
            feedItem[@"url"]            = [[KTBFactoryGirlSequence sequenceFrom:1] withBlock:^id(NSInteger currentIndex) {
                return [NSString stringWithFormat:@"http://feeds-r-us.com/i/%d", currentIndex];
            }];
            // And a boolean not-deleted flag
            feedItem[@"deleted"]        = @NO;
            
            // We want to test an edge case where this feed item is deleted, so we can define a subfactory
            [feedItem define:@"DeletedFeedItem" as:^(KTBFactoryGirl *feedItem) {
                // A feed item generated by this factory will be the same as our base item, but deleted will be YES.
                feedItem[@"deleted"]    = @YES;
            }];
        }];
        
        // Okay, let's define a feed that will contain feed items.
        [KTBFactoryGirl define:@"Feed" as:^(KTBFactoryGirl *feed) {
            // Set some metadata.
            feed[@"timestamp"]          = @([[NSDate date] timeIntervalSince1970]);
            feed[@"user_id"]            = @123;
            
            // Give the feed some feed items. Feed items have a special "ordinal" property determined by order in the feed.
            [feed set:@"feed_items" withFactory:@"FeedItem" count:20 setter:^(KTBFactoryGirl *feedItem, NSInteger itemIndex) {
                feedItem[@"ordinal"]    = @(itemIndex);
            }];
        }];
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    // Define a feed item factory.
    [KTBFactoryGirl define:@"KTBFeedItem" as:^(KTBFactoryGirl *feedItem) {
        // This factory generates a feed item with an incrementing ID.
        feedItem[@"itemID"]             = [KTBFactoryGirlSequence sequenceFrom:1];
        // The feed item will be by user 123
        feedItem[@"userID"]        = @123;
        // With some scintillating text
        feedItem[@"text"]           = @"This is my super interesting feed item text!";
        // A lot of comments
        feedItem[@"commentsCount"] = @50;
        // A few likes
        feedItem[@"likesCount"]    = @12;
        // A permalink
        feedItem[@"URL"]            = [[KTBFactoryGirlSequence sequenceFrom:1] withBlock:^id(NSInteger currentIndex) {
            return [NSURL URLWithString:[NSString stringWithFormat:@"http://feeds-r-us.com/i/%d", currentIndex]];
        }];
        // And a boolean not-deleted flag
        feedItem[@"deleted"]        = @NO;
        
        // We want to test an edge case where this feed item is deleted, so we can define a subfactory
        [feedItem define:@"DeletedFeedItem" as:^(KTBFactoryGirl *feedItem) {
            // A feed item generated by this factory will be the same as our base item, but deleted will be YES.
            feedItem[@"deleted"]    = @YES;
        }];
    }];
    
    // Okay, let's define a feed that will contain feed items.
    [KTBFactoryGirl define:@"KTBFeed" as:^(KTBFactoryGirl *feed) {
        // Set some metadata.
        feed[@"timestamp"]          = @([[NSDate date] timeIntervalSince1970]);
        feed[@"userID"]            = @123;
        
        // Give the feed some feed items. Feed items have a special "ordinal" property determined by order in the feed.
        [feed set:@"items" withFactory:@"KTBFeedItem" count:20 setter:^(KTBFactoryGirl *feedItem, NSInteger itemIndex) {
            feedItem[@"ordinal"]    = @(itemIndex);
        }];
    }];
    
    KTBFeed *feed = [KTBFactoryGirl build:@"KTBFeed"];
    NSLog(@"feed: %@", feed);
    
    XCTAssert([[feed.items[13] itemID] isEqual:@14], @"Our 14th item should have ID 14.");
}

- (void)testJSON {
    NSString *json = [KTBFactoryGirl JSONFor:@"Feed" options:0 error:NULL];
    NSLog(@"json: %@", json);
}

@end
