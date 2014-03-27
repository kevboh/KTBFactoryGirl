# KTBFactoryGirl

[![Version](http://cocoapod-badges.herokuapp.com/v/KTBFactoryGirl/badge.png)](http://cocoadocs.org/docsets/KTBFactoryGirl)
[![Platform](http://cocoapod-badges.herokuapp.com/p/KTBFactoryGirl/badge.png)](http://cocoadocs.org/docsets/KTBFactoryGirl)

KTBFactoryGirl is an attempt to get something like [ruby's factory_girl](https://github.com/thoughtbot/factory_girl) on iOS and OS X. I don't like bundling gigantic JSON blobs in my test bundles, nor do I like manually setting properties on 20 managed objects when I test Core Data entities. KTBFactoryGirl allows you to predefine factories which act as object templates that can be rapidly built out into NSObject subclasses, NSManagedObjects (or subclasses thereof) that have been inserted into contexts, or JSON blobs. So you can write this:

    // Define a factory for a server's representation of a news feed item.
    [KTBFactoryGirl define:@"ServerFeedItem" as:^(KTBFactoryGirl *feedItem) {
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
    }];

    // Okay, let's define a feed that will contain feed items.
    [KTBFactoryGirl define:@"ServerFeed" as:^(KTBFactoryGirl *feed) {
        // Set some metadata.
        feed[@"timestamp"]          = @([[NSDate date] timeIntervalSince1970]);
        feed[@"user_id"]            = @123;
        
        // Give the feed 3 feed items. Feed items have a special "ordinal" property determined by order in the feed.
        [feed set:@"feed_items" withFactory:@"ServerFeedItem" count:3 setter:^(KTBFactoryGirl *feedItem, NSInteger itemIndex) {
            feedItem[@"ordinal"]    = @(itemIndex);
        }];
    }];

and then do this:

    NSString *json = [KTBFactoryGirl JSONFor:@"ServerFeed" options:0 error:NULL];

to get this:

    {
      "user_id": 123,
      "feed_items": [
        {
          "deleted": false,
          "user_id": 123,
          "text": "This is my super interesting feed item text!",
          "id": 1,
          "likes_count": 12,
          "comments_count": 50,
          "ordinal": 0,
          "url": "http://feeds-r-us.com/i/1"
        },
        {
          "deleted": false,
          "user_id": 123,
          "text": "This is my super interesting feed item text!",
          "id": 2,
          "likes_count": 12,
          "comments_count": 50,
          "ordinal": 1,
          "url": "http://feeds-r-us.com/i/2"
        },
        {
          "deleted": false,
          "user_id": 123,
          "text": "This is my super interesting feed item text!",
          "id": 3,
          "likes_count": 12,
          "comments_count": 50,
          "ordinal": 2,
          "url": "http://feeds-r-us.com/i/3"
        }
      ],
      "timestamp": 1395878480.441685
    }

I plan on adding examples to show how you can generate NSObject subclasses (using the `build` set of methods) and NSManagedObject insertions (using the `insert` set of methods). Along with, you know, docs and stuff. And tests.

## Note!

Though I'm using this for a few projects, this code is very much in alpha. There's no documentation and definitely bugs. I still think it's pretty neat, though.

## Usage

To run the example project, clone the repo and run `pod install` from the Example directory. Then check out KTBFactoryGirlExampleTests.m.

## Requirements

## Installation

I plan on submitting to [CocoaPods](http://cocoapods.org) soon. Until I do, you can add this as a pod directly:

    pod "KTBFactoryGirl", :git => 'https://github.com/kevboh/KTBFactoryGirl.git'

## Author

Kevin Barrett, kevin@littlespindle.com

## License

KTBFactoryGirl is available under the MIT license. See the LICENSE file for more info.

