//
//  PLLogManager.h
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 28/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PLLog;

@interface PLLogManager : NSObject

@property (strong, nonatomic) NSArray* logs;

- (NSArray *)refreshedLogs;
- (void)deletLog:(PLLog *)log;

+ (id)sharedManager;

@end
