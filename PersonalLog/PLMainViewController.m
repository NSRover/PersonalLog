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

typedef enum
{
    UITypeBeginCountdown = 0,
    UITypeBeginRecording,
    UITypeEditDetails,
    UITypeStartNew,
}
UIType;

@interface PLMainViewController ()

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

@property (assign, nonatomic) CGRect smallPreviewFrame;
@property (assign, nonatomic) BOOL isPreviewBig;

@property (assign, nonatomic) int countdownTime;

@property (strong, nonatomic) PLLog* currentLog;

@property (strong, nonatomic) NSURL* tempFileURL;

//UI constants

@property (strong, nonatomic) UIColor* custBlueColor;
@property (strong, nonatomic) UIColor* custRedColor;
@property (strong, nonatomic) UIColor* custGrayColor;
@property (strong, nonatomic) UIColor* custGreenColor;

@end

@implementation PLMainViewController

NSString *const stopButtonTitle_wait = @"W a i t !";
NSString *const stopButtonTitle_stop = @"Stop";
NSString *const stopButtonTitle_done = @"Save";
NSString *const stopButtonTitle_new = @"New";

NSString *const statusLabelTitle_countdown = @"Starting in..";
NSString *const statusLabelTitle_recording = @"Recording";
NSString *const statusLabelTitle_recorded = @"Duration: ";
NSString *const statusLabelTitle_previousLog = @"Last log:";

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
    
//    if (backCamera)
//    {
//        NSError* error = nil;
//        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
//        if (!input)
//        {
//            NSLog(@"error");
//        }
//        if ([_session canAddInput:input])
//        {
//            [_session addInput:input];
//        }
//        else
//        {
//            NSLog(@"error");
//        }
//
//    }
    if (frontCamera)
    {
        NSError* error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input)
        {
            NSLog(@"error");
        }
        if ([_session canAddInput:input])
        {
            [_session addInput:input];
        }
    }
    
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
    [UIView animateWithDuration:0.2
                     animations:^{
                         _countdownLblStatus.alpha = 1.0;
                     }
     ];
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
    self.tempFileURL = [[NSURL alloc] initFileURLWithPath:[[PLFileManager sharedFileManager] pathForNewRecording]];
    [_movieFileOutput startRecordingToOutputFileURL:_tempFileURL recordingDelegate:self];

    //Log object
    self.currentLog = [PLLog newLog];
}

#pragma mark UI

- (void)prepareUIFor:(UIType)type;
{
    if (type == UITypeBeginCountdown)
    {
        //Stop button
        [self.stopButton.titleLabel setText:stopButtonTitle_wait];
        [self.stopButton.titleLabel setTextColor:_custRedColor];
        
        //Delete Button
        [self.deleteButton setAlpha:0.0];
        [self.deleteButton setEnabled:NO];
        
        //List button
        [self.listButton.titleLabel setTextColor:_custGrayColor];
        [self.listButton.titleLabel setTintColor:_custGrayColor];
    }
    else if (type == UITypeBeginRecording)
    {
        //Stop button
        [self.stopButton.titleLabel setText:stopButtonTitle_stop];
        [self.stopButton.titleLabel setTextColor:_custBlueColor];
        
        //Status label
        [self.countdownLblStatus setText:statusLabelTitle_recording];
        [self.countdownLblStatus setTextColor:_custGrayColor];
        
        [self minimiseBottomBar];
    }
    else if (type == UITypeEditDetails)
    {
        //Stop button
        [self.stopButton.titleLabel setText:stopButtonTitle_done];
        [self.stopButton.titleLabel setTextColor:_custGreenColor];
        
        //Status label
        [self.countdownLblStatus setText:statusLabelTitle_recorded];
        [self.countdownLblStatus setTextColor:_custGrayColor];
        
        //Delete Button
        self.deleteButton.alpha = 1.0;
        self.deleteButton.enabled = YES;
        [self.deleteButton.titleLabel setTextColor:_custRedColor];
        [self.deleteButton.titleLabel setTintColor:_custRedColor];
        
        [self maximiseBottomBar];
    }
    else if (type == UITypeStartNew)
    {
        //Stop button
        [self.stopButton.titleLabel setText:stopButtonTitle_new];
        [self.stopButton.titleLabel setTextColor:_custGrayColor];
        
        //Status label
        [self.countdownLblStatus setText:statusLabelTitle_previousLog];
        [self.countdownLblStatus setTextColor:_custGrayColor];
        
        //Delete Button
        self.deleteButton.alpha = 0.0;
        self.deleteButton.enabled = NO;
        [self.deleteButton.titleLabel setTextColor:_custRedColor];
        [self.deleteButton.titleLabel setTintColor:_custRedColor];
        
        [self maximiseBottomBar];
    }
}

- (void)prepareColors;
{
    self.custBlueColor = [UIColor colorWithRed:(102.0/255.0) green:(102.0/255.0) blue:(255.0/255.0) alpha:1.0];
    self.custGrayColor = [UIColor grayColor];
    self.custRedColor = [UIColor redColor];
    self.custGreenColor = [UIColor greenColor];
}

- (void)minimiseBottomBar;
{
    [UIView animateWithDuration:0.25 animations:^(void){
       [self.bottomBar setFrame:CGRectMake(self.bottomBar.frame.origin.x,
                                          self.view.frame.size.height - self.bottomBar.frame.size.height / 2,
                                          self.bottomBar.frame.size.width,
                                           self.bottomBar.frame.size.height)];
    }];
}

- (void)maximiseBottomBar;
{
    [UIView animateWithDuration:0.25 animations:^(void){
        [self.bottomBar setFrame:CGRectMake(self.bottomBar.frame.origin.x,
                                            self.view.frame.size.height - self.bottomBar.frame.size.height,
                                            self.bottomBar.frame.size.width,
                                            self.bottomBar.frame.size.height)];
    }];
}

#pragma mark Main

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    [self prepareColors];
    [self initCaptureSession];
    
    //Gestures
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped)];
    [_previewView addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated;
{
    //ui
    [self prepareUIFor:UITypeBeginCountdown];
    
    //Countdown
    [self beginCountDown];
    
    //Full Screen
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

- (void)delayedPrepareUICallForEditDetails;
{
    [self prepareUIFor:UITypeEditDetails];
}

- (IBAction)stopButtonTapped:(id)sender
{
    //Stop recording
    if ([self.stopButton.titleLabel.text isEqualToString:stopButtonTitle_stop])
    {
        [_movieFileOutput stopRecording];
        if (_isPreviewBig)
        {
            [self previewTapped];
        }
        [self performSelector:@selector(delayedPrepareUICallForEditDetails) withObject:nil afterDelay:0.2];
    }
    //Save
    else if ([self.stopButton.titleLabel.text isEqualToString:stopButtonTitle_done])
    {
        //Asset
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_tempFileURL options:nil];

        //Meta Data
        NSMutableArray* metaDataCollection;
        if (asset.commonMetadata)
        {
            metaDataCollection = [asset.commonMetadata mutableCopy];
        }
        else
        {
            metaDataCollection = [[NSMutableArray alloc] init];
        }
        
        //Title
        _currentLog.title = _titleTextField.text;
        AVMutableMetadataItem* titleItem = [[AVMutableMetadataItem alloc] init];
        titleItem.keySpace = AVMetadataKeySpaceCommon;
        titleItem.key = AVMetadataCommonKeyTitle;
        titleItem.value = _currentLog.title;
        [metaDataCollection addObject:titleItem];
        
        //Tags
        _currentLog.tags = _tagsTextField.text;
        AVMutableMetadataItem* tagsItem = [[AVMutableMetadataItem alloc] init];
        tagsItem.keySpace = AVMetadataKeySpaceCommon;
        tagsItem.key = AVMetadataCommonKeyAlbumName;
        tagsItem.value = _currentLog.tags;
        [metaDataCollection addObject:tagsItem];
        
        //Description
        _currentLog.description = _notesTextArea.text;
        AVMutableMetadataItem* descriptionItem = [[AVMutableMetadataItem alloc] init];
        descriptionItem.keySpace = AVMetadataKeySpaceCommon;
        descriptionItem.key = AVMetadataCommonKeyDescription;
        descriptionItem.value = _currentLog.description;
        [metaDataCollection addObject:descriptionItem];
        
        NSString* outputPath = [[PLFileManager sharedFileManager] pathForAsset:_currentLog];
        NSURL* outputUrl = [NSURL fileURLWithPath:outputPath];
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
        exportSession.outputURL = outputUrl;
        CMTimeRange range = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        exportSession.timeRange = range;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.metadata = metaDataCollection;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusCompleted:
                    [self prepareUIFor:UITypeStartNew];
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [exportSession error]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    break;
            }
        }];
    }
//    else if ([self.stopButton.titleLabel.text isEqualToString:stopButtonTitle_done])
//    {
//        
//    }
}

- (IBAction)deleteButtonTapped:(id)sender
{
}

- (IBAction)listButtonTapped:(id)sender
{
}

- (void)saveCurrentLog;
{
    
}

#pragma mark Countdown

- (void)highlightCountdownLabel:(UILabel *)label;
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         label.textColor = _custBlueColor;
                         label.alpha = 1.0;
                     }
     ];
}

- (void)unhighlightCountdownLabel:(UILabel *)label animated:(BOOL)animated;
{
    UIColor *textColor = _custGrayColor;
    float alpha = 0.3;
    
    if (animated)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             label.textColor = textColor;
                             label.alpha = alpha;
                         }
         ];
    }
    else
    {
        label.textColor = textColor;
        label.alpha = alpha;
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
            [self countdownEnded];
        default:
            break;
    }
}

- (void)tock;
{
    [self performSelector:@selector(tick) withObject:nil afterDelay:1.0];
}

- (void)countdownEnded;
{
    [self prepareUIFor:UITypeBeginRecording];
    [self startRecording];
}

- (void)beginCountDown;
{
    [self.countdownLblStatus setText:statusLabelTitle_countdown];
    [self.countdownLblStatus setTextColor:_custBlueColor];
    
    //unhighlight all labels
    [self unhighlightCountdownLabel:_countdownLbl1 animated:NO];
    [self unhighlightCountdownLabel:_countdownLbl2 animated:NO];
    [self unhighlightCountdownLabel:_countdownLbl3 animated:NO];

    self.countdownTime = 0;
    [self tock];
}

@end
