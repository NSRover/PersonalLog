//
//  PLLog.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 10/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLLog.h"
#import "PLUtils.h"
#import "PLFileManager.h"

@implementation PLLog

+ (id)newLog;
{
    NSString* newID = [PLUtils uniqueID];
    
    PLLog *log = [[self alloc] init];
    log.ID = newID;
    
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    log.title = [formatter stringFromDate:date];
    
    log.tags = @"#PersonalLog ";
    
    log.description = [NSString stringWithFormat:@"This is a personal log entered on %@", log.title];
    
    log.videoFilePath = [[PLFileManager sharedFileManager] pathForAsset:log];
    
    return log;
}

@end
