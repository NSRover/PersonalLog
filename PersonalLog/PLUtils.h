//
//  PLUtils.h
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 10/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLUtils : NSObject

+ (NSString *)uniqueID;
+ (NSDate *)dateForID:(NSString *)ID;
+ (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2;

@end
