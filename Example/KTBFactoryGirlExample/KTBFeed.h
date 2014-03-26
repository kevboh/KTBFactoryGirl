//
//  KTBFeed.h
//  KTBFactoryGirlExample
//
//  Created by Kevin Barrett on 3/26/14.
//  Copyright (c) 2014 Little Spindle, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTBFeed : NSObject
@property (readonly, nonatomic, strong) NSNumber *timestamp;
@property (readonly, nonatomic, strong) NSNumber *userID;
@property (readonly, nonatomic, strong) NSArray *items;
@end
