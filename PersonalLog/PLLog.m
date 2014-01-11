//
//  PLLog.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 10/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLLog.h"
#import "PLUtils.h"

@implementation PLLog

+ (id)newLog;
{
    NSString* newID = [PLUtils uniqueID];
    
    PLLog *log = [[self alloc] init];
    log.ID = newID;
    
    return log;
}

@end
