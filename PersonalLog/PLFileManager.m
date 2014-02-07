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
#define FM_LOG_DIRECTORY @"Logs"

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

- (NSArray *)allLogPaths;
{
    NSString* pathToDirectory = [self pathForDirectory:FM_LOG_DIRECTORY createIfDoesNotExist:YES];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [manager contentsOfDirectoryAtPath:pathToDirectory error:&error];
    
    NSMutableArray *patternPaths = [[NSMutableArray alloc] init];
    
    for(NSString *candidateFile in directoryContents)
    {
        NSString *candidateFileFullPath = [pathToDirectory stringByAppendingPathComponent:candidateFile];
        
        NSString* fileExtension = [candidateFile pathExtension];
        if (![fileExtension isEqualToString:@"mov"])
        {
            [manager removeItemAtPath:candidateFileFullPath error:nil];
            continue;
        }
        
        [patternPaths addObject:candidateFileFullPath];
    }
    return patternPaths;
}

- (PLLog *)logForPath:(NSString *)path;
{
    NSURL* url = [NSURL fileURLWithPath:path];
    AVAsset* asset = [AVAsset assetWithURL:url];
    
    PLLog* log = [[PLLog alloc] init];

    NSString* stringValue = @"";
    AVMetadataItem *item;

    //Description
    NSArray* descriptions = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyDescription keySpace:AVMetadataKeySpaceCommon];
    if ([descriptions count] > 0)
    {
        item = [descriptions objectAtIndex:0];
        stringValue = item.stringValue;
    }
    log.description = stringValue;
    
    //Title
    stringValue = @"";
    NSArray* titles = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon];
    if ([titles count] > 0)
    {
        item = [titles objectAtIndex:0];
        stringValue = item.stringValue;
    }
    log.title = stringValue;

    //Tags
    stringValue = @"";
    NSArray* tags = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyAlbumName keySpace:AVMetadataKeySpaceCommon];
    if ([tags count] > 0)
    {
        item = [tags objectAtIndex:0];
        stringValue = item.stringValue;
    }
    log.tags = stringValue;
    
    log.ID = [[path lastPathComponent] stringByDeletingPathExtension];
    
    log.videoFilePath = path;
    
    return log;
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

- (NSString *)pathForAsset:(PLLog *)log;
{
    NSString* pathToDirectory = [self pathForDirectory:FM_LOG_DIRECTORY createIfDoesNotExist:YES];
    NSString* filename = [NSString stringWithFormat:@"%@.mov", log.ID];
    NSString* pathToFile = [pathToDirectory stringByAppendingPathComponent:filename];
    
    //Remove old file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:pathToFile])
    {
        [fileManager removeItemAtPath:pathToFile error:nil];
    }
    
    return pathToFile;
}

- (NSArray *)allLogs;
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSArray* paths = [self allLogPaths];
    
    for (NSString *path in paths)
    {
        PLLog* log = [self logForPath:path];
        if (log)
        {
            [array addObject:log];
        }
    }
    
    return array;
}

- (BOOL)deleteLogAtPath:(NSString *)path;
{
    //Remove old file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path])
    {
        [fileManager removeItemAtPath:path error:nil];
        return YES;
    }
    
    return NO;
}

@end
