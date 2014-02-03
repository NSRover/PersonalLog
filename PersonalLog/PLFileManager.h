//
//  PLFileManager.h
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 10/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PLLog.h"

@interface PLFileManager : NSObject

//this returns a temporary location for storing the recorded video. In case another file already exists, it will be deleted.
- (NSString *)pathForNewRecording;
- (NSString *)pathForAsset:(PLLog *)log;

- (NSArray *)allLogs;
- (BOOL)deleteLogAtPath:(NSString *)path;

+ (id)sharedFileManager;

@end
