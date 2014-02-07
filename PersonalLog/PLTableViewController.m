//
//  PLTableViewController.m
//  PersonalLog
//
//  Created by Nirbhay Agarwal on 28/01/14.
//  Copyright (c) 2014 Nirbhay Agarwal. All rights reserved.
//

#import "PLTableViewController.h"
#import "PLFileManager.h"
#import "PLLog.h"
#import "PLLogManager.h"
#import "PLMainViewController.h"
#import "PLAppDelegate.h"

@interface PLTableViewController ()

@property (strong, nonatomic) NSMutableArray* logs;

@end

@implementation PLTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Journal";
    
    self.logs = [[[PLLogManager sharedManager] refreshedLogs] mutableCopy];
}

- (void)viewDidAppear:(BOOL)animated;
{
    PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
    PLMainViewController* vc = (PLMainViewController *)appDelegate.mainViewController;
    vc.mode = UIModeBeginRecording;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_logs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell"];
    
    PLLog* log = [_logs objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = log.title;
    cell.detailTextLabel.text = log.tags;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PLLog* log = [_logs objectAtIndex:[indexPath row]];
        
        if ([[PLLogManager sharedManager] deletLog:log])
        {
            [_logs removeObject:log];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    PLLog* log = [_logs objectAtIndex:[indexPath row]];
    PLAppDelegate *appDelegate = (PLAppDelegate *)[[UIApplication sharedApplication] delegate];
    PLMainViewController* vc = (PLMainViewController *)appDelegate.mainViewController;
    vc.mode = UIModePlayback;
    [vc playbackLog:log];
    
    [self popView:nil];
}

- (IBAction)popView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
