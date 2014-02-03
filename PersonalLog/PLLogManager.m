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

- (void)deletLog:(PLLog *)log;
{
    if (![[PLFileManager sharedFileManager] deleteLogAtPath:log.videoFilePath])
    {
        [[[UIAlertView alloc] initWithTitle:@"Delete failed" message:@"Could not delete log" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
}

@end
