//
//  KTBFeedItem.h
//  KTBFactoryGirlExample
//
//  Created by Kevin Barrett on 3/26/14.
//  Copyright (c) 2014 Little Spindle, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTBFeedItem : NSObject
@property (readonly, nonatomic, strong) NSNumber *itemID;
@property (readonly, nonatomic, strong) NSNumber *userID;
@property (readonly, nonatomic, copy) NSString *text;
@property (readonly, nonatomic, strong) NSNumber *commentsCount;
@property (readonly, nonatomic, strong) NSNumber *likesCount;
@property (readonly, nonatomic, strong) NSURL *URL;
@property (readonly, nonatomic, strong) NSNumber *deleted;
@property (readonly, nonatomic, strong) NSNumber *ordinal;
@end
