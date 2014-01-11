//
//  PLMainViewController.h
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 09/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PLMainViewController : UIViewController <AVCaptureFileOutputRecordingDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;

- (IBAction)stopButtonTapped:(id)sender;

#pragma mark Countdown
@property (weak, nonatomic) IBOutlet UIView *countdownView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLbl3;
@property (weak, nonatomic) IBOutlet UILabel *countdownLbl2;
@property (weak, nonatomic) IBOutlet UILabel *countdownLbl1;
@property (weak, nonatomic) IBOutlet UILabel *countdownLblStatus;

@end
