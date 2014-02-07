//
//  PLMainViewController.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 09/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLMainViewController.h"
#import "PLFileManager.h"
#import "PLLogManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PLAppDelegate.h"

typedef enum
{
    UITypeBeginCountdown = 0,
    UITypeBeginRecording,
    UITypeEditDetails,
    UITypeStartNew,
}
UIType;

@interface PLMainViewController ()

//Capturing
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

//Playback
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) CALayer *playerLayer;

//UI
@property (assign, nonatomic) CGRect smallPreviewFrame;
@property (assign, nonatomic) BOOL isPreviewBig;

//State
@property (assign, nonatomic) int countdownTime;
@property (assign, nonatomic) UIType currentType;
@property (assign, nonatomic) BOOL firstLaunch;

//UI constants
@property (strong, nonatomic) UIColor* custBlueColor;
@property (strong, nonatomic) UIColor* custRedColor;
@property (strong, nonatomic) UIColor* custGrayColor;
@property (strong, nonatomic) UIColor* custGreenColor;

@end

@implementation PLMainViewController

NSString *const stopButtonTitle_wait = @"W a i t !";
NSString *const stopButtonTitle_stop = @"Stop";
NSString *const stopButtonTitle_save = @"Save";
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
            frontCamera = device;
        }
    }
    
    if (frontCamera)
    {
        NSError* error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input)
        {
            NSLog(@"No fraont cam!");
        }
        if ([_session canAddInput:input])
        {
            [_session addInput:input];
        }
    }
    
    if (microphone)
    {
        NSError* error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:microphone error:&error];
        if (!input)
        {
            NSLog(@"No microphone!");
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
}

- (void)initPlaybackSession;
{
    self.player = [[AVPlayer alloc] init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [_previewView.layer addSublayer:_playerLayer];
    [_playerLayer setFrame:_previewView.bounds];
    _playerLayer.hidden = YES;
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

- (void)beginCaptureSession;
{
    if (!_session.isRunning)
    {
        [_session startRunning];
    }
}

- (void)startRecording;
{
    [self beginCaptureSession];
    [_movieFileOutput startRecordingToOutputFileURL:[[NSURL alloc] initFileURLWithPath:_currentLog.videoFilePath]
                                  recordingDelegate:self];
    
    self.mode = UIModeRecording;
}

#pragma mark UI

- (void)populateDetails;
{
    _titleTextField.text = _currentLog.title;
    
    //Tags
    _tagsTextField.text = _currentLog.tags;
    
    //Description
    _notesTextArea.text = _currentLog.description;
}

- (void)privatePrepareUI;
{
    UIType type = _currentType;
    
    if (type == UITypeBeginCountdown)
    {
        //Stop button
        [self.stopButton.titleLabel setText:stopButtonTitle_wait];
        [self.stopButton.titleLabel setTextColor:_custRedColor];
        self.stopButton.alpha = 1.0;
        
        //Delete Button
        [self.deleteButton setAlpha:0.0];
        [self.deleteButton setEnabled:NO];
        
        //update button
        [self hideUpdateButton];
        
        //List button
        [self.listButton.titleLabel setTextColor:_custGrayColor];
        [self.listButton.titleLabel setTintColor:_custGrayColor];
    }
    else if (type == UITypeBeginRecording)
    {
        //Stop button
        [self.stopButton.titleLabel setText:stopButtonTitle_stop];
        [self.stopButton.titleLabel setTextColor:_custBlueColor];
        self.stopButton.alpha = 1.0;
        
        //update button
        [self hideUpdateButton];
        
        //Status label
        [self.countdownLblStatus setText:statusLabelTitle_recording];
        [self.countdownLblStatus setTextColor:_custGrayColor];
        
        [self minimiseBottomBar];
    }
    else if (type == UITypeEditDetails)
    {
        //Stop button
        [self.stopButton.titleLabel setText:stopButtonTitle_new];
        [self.stopButton.titleLabel setTextColor:_custGrayColor];
        self.stopButton.alpha = 1.0;
        
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
        self.stopButton.alpha = 1.0;
        
        //Status label
        [self.countdownLblStatus setText:[[PLLogManager sharedManager] lastLogGap]];
        [self.countdownLblStatus setTextColor:_custGrayColor];
        
        //update button
        [self hideUpdateButton];
        
        //Delete Button
        self.deleteButton.alpha = 0.0;
        self.deleteButton.enabled = NO;
        [self.deleteButton.titleLabel setTextColor:_custRedColor];
        [self.deleteButton.titleLabel setTintColor:_custRedColor];
        
        [self maximiseBottomBar];
        
        [self beginCaptureSession];
    }
}

- (void)prepareUIFor:(UIType)type;
{
    self.currentType = type;
    [self performSelector:@selector(privatePrepareUI) withObject:nil afterDelay:0.3];
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

- (void)showBusyView;
{
    [UIView animateWithDuration:0.2 animations:^(void){
        [self.activityView setAlpha:1.0];
    }];
}

- (void)hideBusyView;
{
    [UIView animateWithDuration:0.2 animations:^(void){
        [self.activityView setAlpha:0.0];
    }];
}

- (void)showUpdateButton;
{
    [self.updateButton.titleLabel setTextColor:_custGreenColor];
    self.updateButton.alpha = 1.0;
    self.updateButton.enabled = YES;
}

- (void)hideUpdateButton;
{
    self.updateButton.alpha = 0.0;
    self.updateButton.enabled = NO;
}

#pragma mark Main

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    //Assign to delegate
    PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mainViewController = self;

    //Initializations
    [self prepareColors];
    [self initCaptureSession];
    [self initPlaybackSession];
    
    [self beginCaptureSession];
    self.mode = UIModeBeginRecording;
    
    self.firstLaunch = YES;
    
    //Gestures
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped)];
    [_previewView addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated;
{
    if (_mode == UIModeBeginRecording)
    {
        if (_firstLaunch)
        {
            self.firstLaunch = NO;
            [self beginNewLogEntry];
        }
        else
        {
            [self prepareUIFor:UITypeStartNew];
        }

    }
    else if (_mode == UIModePlayback)
    {
        [self prepareUIFor:UITypeEditDetails];
    }
}

- (void)beginNewLogEntry;
{
    [self stopLogPlayback];
    
    self.currentLog = [PLLog newLog];
    [self populateDetails];
    
    //ui
    [self prepareUIFor:UITypeBeginCountdown];

    //Countdown
    [self beginCountDown];
    
    //Full Screen
    [self previewTapped];
}

- (void)playbackLog:(PLLog *)log;
{
    self.currentLog = log;
    
    //UI
    [self prepareUIFor:UITypeEditDetails];
    
    //Play
    [self playLog];
}

- (void)updateMetaDataForObject:(id)object;
{
    //Meta Data
    NSMutableArray* metaDataCollection = [[NSMutableArray alloc] init];

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
    
    if (_mode == UIModeRecording)
    {
        AVCaptureMovieFileOutput *output = (AVCaptureMovieFileOutput *)object;
        output.metadata = metaDataCollection;
    }
    else if(_mode == UIModePlayback)
    {
        AVAssetExportSession* session = (AVAssetExportSession *)object;
        session.metadata = metaDataCollection;
    }
}

#pragma mark Playback

- (void)playLog;
{
    NSURL* urlToPlay;
    urlToPlay = [NSURL fileURLWithPath:_currentLog.videoFilePath];
    
    AVPlayerItem* item = [[AVPlayerItem alloc] initWithURL:urlToPlay];
    [_player replaceCurrentItemWithPlayerItem:item];
    [_player play];
    _playerLayer.hidden = NO;
    
    _preview.hidden = YES;
}

- (void)stopLogPlayback;
{
    if (!_playerLayer.hidden)
    {
        [_player pause];
        _playerLayer.hidden = YES;
        _preview.hidden = NO;
        [self beginCaptureSession];
    }
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
        _playerLayer.frame = _previewView.bounds;
    }];
}

- (IBAction)stopButtonTapped:(id)sender
{
    //Stop recording
    if ([self.stopButton.titleLabel.text isEqualToString:stopButtonTitle_stop])
    {
        //meta data
        [self updateMetaDataForObject:_movieFileOutput];
        
        [_movieFileOutput stopRecording];
        [_session stopRunning];
        
        [[PLLogManager sharedManager] refreshedLogs];
        
        [self prepareUIFor:UITypeEditDetails];
        self.mode = UIModePlayback;
        [self playLog];
        
        if (_isPreviewBig)
        {
            [self previewTapped];
        }
    }
    //Save
    else if ([self.stopButton.titleLabel.text isEqualToString:stopButtonTitle_save])
    {
        //Busy View
        [self performSelectorInBackground:@selector(showBusyView) withObject:nil];
        
        //Asset
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:_currentLog.videoFilePath]
                                                    options:nil];

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
        
        NSString* outputPath = [[PLFileManager sharedFileManager] pathForAsset:_currentLog];
        NSURL* outputUrl = [NSURL fileURLWithPath:outputPath];
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
        exportSession.outputURL = outputUrl;
        CMTimeRange range = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        exportSession.timeRange = range;
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        [self updateMetaDataForObject:exportSession];
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusCompleted:
                    [self prepareUIFor:UITypeStartNew];
                    [self hideBusyView];
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
    else if ([self.stopButton.titleLabel.text isEqualToString:stopButtonTitle_wait])
    {
        [self stopCountdown];
    }
    else if ([self.stopButton.titleLabel.text isEqualToString:stopButtonTitle_new])
    {
        [self prepareUIFor:UITypeBeginCountdown];
        [self beginNewLogEntry];
    }
}

- (IBAction)deleteButtonTapped:(id)sender
{
    if ([[PLLogManager sharedManager] deletLog:_currentLog])
    {
        self.currentLog = nil;
    }
    [self stopLogPlayback];
    
    [self prepareUIFor:UITypeStartNew];
}

- (IBAction)listButtonTapped:(id)sender
{
    
}

- (IBAction)updateButtonTapped:(id)sender {
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

- (void)stopCountdown;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tick) object:nil];
    
    _countdownLbl1.alpha = 0.0;
    _countdownLbl2.alpha = 0.0;
    _countdownLbl3.alpha = 0.0;
    if (_isPreviewBig)
    {
        [self previewTapped];
    }
    
    [self prepareUIFor:UITypeStartNew];
}

#pragma mark Textfield delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
    if (_mode == UIModePlayback)
    {
        [self showUpdateButton];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [textField resignFirstResponder];
    return YES;
}

@end
