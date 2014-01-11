//
//  PLLog.h
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 10/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLLog : NSObject

@property (strong, nonatomic) NSString* ID;

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* tags;
@property (strong, nonatomic) NSString* description;

@property (strong, nonatomic) NSString* videoFilePath;

+ (id)newLog;

@end
