//
//  PLMainViewController.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 09/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLMainViewController.h"
#import "PLFileManager.h"
#import "PLLog.h"

@interface PLMainViewController ()

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

@property (assign, nonatomic) CGRect smallPreviewFrame;
@property (assign, nonatomic) BOOL isPreviewBig;

@property (assign, nonatomic) int countdownTime;

@property (strong, nonatomic) PLLog* currentLog;

@end

@implementation PLMainViewController

#pragma mark Video Playback

- (void)initCaptureSession;
{
    //Session
    self.session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetMedium;
    
    //Preview
    self.preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    [_preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    _preview.frame = _previewView.bounds;
    [_previewView.layer addSublayer:_preview];
    
    //Inputs
    NSArray* devices = [AVCaptureDevice devices];
    AVCaptureDevice* frontCamera;
    AVCaptureDevice* backCamera;
    AVCaptureDevice* microphone;
    
    for (AVCaptureDevice *device in devices)
    {
        //Microphone
        if ([device hasMediaType:AVMediaTypeAudio])
        {
            microphone = device;
        }
        //Camera
        else
        {
            if ([device position] == AVCaptureDevicePositionBack)
            {
                backCamera = device;
            }
            else
            {
                frontCamera = device;
            }
        }
    }
    
    if (backCamera)
    {
        NSError* error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input)
        {
            NSLog(@"error");
        }
        if ([_session canAddInput:input])
        {
            [_session addInput:input];
        }
        else
        {
            NSLog(@"error");
        }

    }
//    if (frontCamera)
//    {
//        NSError* error = nil;
//        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
//        if (!input)
//        {
//            NSLog(@"error");
//        }
//        [session addInput:input];
//    }
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
//    movieFileOutput.maxRecordedDuration = kcmtT
    
    
    if ([_session canAddOutput:_movieFileOutput])
    {
        [_session addOutput:_movieFileOutput];
    }
    else
    {
        NSLog(@"error");
    }
    

    [_session commitConfiguration];
    [_session startRunning];
}

#pragma mark delegates

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections;
{
    [self highlightCountdownLabel:_countdownLblStatus];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error;
{
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            recordedSuccessfully = [value boolValue];
        }
    }
}

#pragma mark Capturing

- (void)startRecording;
{
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:[[PLFileManager sharedFileManager] pathForNewRecording]];
    [_movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
    
    self.currentLog = [PLLog newLog];
}

#pragma mark Main

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    [self initCaptureSession];
    
    //Gestures
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped)];
    [_previewView addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [self beginCountDown];
    [self previewTapped];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Interaction

- (void)previewTapped;
{
    CGRect targetFrame;
    if (_isPreviewBig)
    {
        targetFrame = _smallPreviewFrame;
        self.isPreviewBig = NO;
    }
    else
    {
        self.smallPreviewFrame = _previewView.frame;
        targetFrame = [self.view bounds];
        self.isPreviewBig = YES;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        _previewView.frame = targetFrame;
        _preview.frame = _previewView.bounds;
    }];
}

- (IBAction)stopButtonTapped:(id)sender
{
    [_movieFileOutput stopRecording];
}

#pragma mark Countdown

- (void)highlightCountdownLabel:(UILabel *)label;
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         label.textColor = [UIColor redColor];
                         label.alpha = 1.0;
                     }
     ];
}

- (void)unhighlightCountdownLabel:(UILabel *)label animated:(BOOL)animated;
{
    if (animated)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             label.textColor = [UIColor grayColor];
                             label.alpha = 0.3;
                         }
         ];
    }
    else
    {
        label.textColor = [UIColor grayColor];
        label.alpha = 0.3;
    }
}

- (void)tick;
{
    _countdownTime++;

    switch (_countdownTime) {
        case 1:
            [self highlightCountdownLabel:_countdownLbl3];
            [self tock];
            break;
            
        case 2:
            [self unhighlightCountdownLabel:_countdownLbl3 animated:YES];
            [self highlightCountdownLabel:_countdownLbl2];
            [self tock];
            break;
            
        case 3:
            [self unhighlightCountdownLabel:_countdownLbl2 animated:YES];
            [self highlightCountdownLabel:_countdownLbl1];
            [self tock];
            break;
            
        case 4:
            _countdownLbl1.alpha = 0.0;
            _countdownLbl2.alpha = 0.0;
            _countdownLbl3.alpha = 0.0;
            [self startRecording];
        default:
            break;
    }
}

- (void)tock;
{
    [self performSelector:@selector(tick) withObject:nil afterDelay:1.0];
}

- (void)beginCountDown;
{
    //unhighlight all labels
    [self unhighlightCountdownLabel:_countdownLbl1 animated:NO];
    [self unhighlightCountdownLabel:_countdownLbl2 animated:NO];
    [self unhighlightCountdownLabel:_countdownLbl3 animated:NO];

    self.countdownTime = 0;
    [self tock];
}

@end
