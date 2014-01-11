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
    NSUUID *uuid = [NSUUID UUID];
    return [uuid UUIDString];
}


@end
