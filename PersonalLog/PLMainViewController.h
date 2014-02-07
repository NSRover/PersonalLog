//
//  PLMainViewController.h
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 09/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PLLog.h"

typedef enum
{
    UIModeBeginRecording = 0,
    UIModeRecording,
    UIModePlayback
}
UIMode;

@interface PLMainViewController : UIViewController <AVCaptureFileOutputRecordingDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;

- (IBAction)stopButtonTapped:(id)sender;
- (IBAction)deleteButtonTapped:(id)sender;
- (IBAction)listButtonTapped:(id)sender;
- (IBAction)updateButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

#pragma mark MetaData elements
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *tagsTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextArea;

#pragma mark Countdown
@property (weak, nonatomic) IBOutlet UIView *countdownView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLbl3;
@property (weak, nonatomic) IBOutlet UILabel *countdownLbl2;
@property (weak, nonatomic) IBOutlet UILabel *countdownLbl1;
@property (weak, nonatomic) IBOutlet UILabel *countdownLblStatus;

@property (strong, nonatomic) PLLog* currentLog;
@property (assign, nonatomic) UIMode mode;

#pragma mark Public functions

- (void)playbackLog:(PLLog *)log;

@end
