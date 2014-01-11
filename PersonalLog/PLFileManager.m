//
//  PLFileManager.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 10/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLFileManager.h"

#define FM_TEMP_DIRECTORY @"Temp"
#define FM_DEFAULT_FILE_NAME @"newRecording.mp4"

static PLFileManager* _sharedFileManager;

@implementation PLFileManager

#pragma mark Private

+ (id)sharedFileManager;
{
    if (!_sharedFileManager)
    {
        _sharedFileManager = [[PLFileManager alloc] init];
    }
    return _sharedFileManager;
}

- (NSString *)pathForDirectory:(NSString *)directoryName createIfDoesNotExist:(BOOL)create
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:directoryName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:directoryPath])
    {
        if (create) {
            NSError* error;
            //Create Directory
            BOOL success = [fileManager createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
            if (!success) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Unable to create directory!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                directoryPath = nil;
            }
        }
        else
        {
            directoryPath = nil;
        }
    }
    return directoryPath;
}



#pragma mark Public

- (NSString *)pathForNewRecording;
{
    NSString* pathToDirectory = [self pathForDirectory:FM_TEMP_DIRECTORY createIfDoesNotExist:YES];
    NSString* pathToFile = [pathToDirectory stringByAppendingPathComponent:FM_DEFAULT_FILE_NAME];
    
    //Remove old file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:pathToFile])
    {
        [fileManager removeItemAtPath:pathToFile error:nil];
    }
    
    return pathToFile;
}

@end
