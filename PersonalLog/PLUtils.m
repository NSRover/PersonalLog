//
//  PLUtils.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 10/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLUtils.h"

@implementation PLUtils

+ (NSString *)uniqueID;
{
    NSDate* dateNow = [NSDate date];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd(HH:mm:ss)"];
    NSString *formattedDate = [formatter stringFromDate:dateNow];
    
    return [formattedDate description];
}


@end
