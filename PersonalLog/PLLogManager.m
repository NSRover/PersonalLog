//
//  PLLogManager.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 28/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLLogManager.h"
#import "PLFileManager.h"
#import "PLLog.h"
#import "PLUtils.h"

static PLLogManager* _sharedLogManager = nil;

@implementation PLLogManager

+ (id)sharedManager;
{
    if (!_sharedLogManager)
    {
        _sharedLogManager = [[PLLogManager alloc] init];
    }
    return _sharedLogManager;
}

- (NSArray *)refreshedLogs;
{
    self.logs = [[PLFileManager sharedFileManager] allLogs];
    return _logs;
}

- (NSString *)lastLogGap;
{
    if (!_logs)
    {
        [self refreshedLogs];
    }
    
    NSString* dateToReturn = @"Calculating";
    if ([_logs count] > 0)
    {
        NSDate* latestDate = nil;
        for (PLLog *log in _logs)
        {
            NSDate* date = [PLUtils dateForID:log.ID];
            if (!latestDate)
            {
                latestDate = date;
            }
            else
            {
                if ([latestDate compare:date] == NSOrderedAscending)
                {
                    latestDate = date;
                }
            }
        }
        NSString* interval = [PLUtils timeIntervalWithStartDate:latestDate withEndDate:[NSDate date]];
        dateToReturn = [NSString stringWithFormat:@"Previous: %@", interval];
    }
    else
    {
        dateToReturn = @"Journal empty";
    }
    return dateToReturn;
}

- (BOOL)deletLog:(PLLog *)log;
{
    if (![[PLFileManager sharedFileManager] deleteLogAtPath:log.videoFilePath])
    {
        [[[UIAlertView alloc] initWithTitle:@"Delete failed" message:@"Could not delete log" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
        return NO;
    }
    
    self.logs = [self refreshedLogs];
    
    return YES;
}

@end
