//
//  PKFlipsideViewController.m
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import "PKFlipsideViewController.h"
#import "PKDataManager.h"

@interface PKFlipsideViewController ()

@end

@implementation PKFlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.apiEndpointField.text = [[NSUserDefaults standardUserDefaults] stringForKey:PKAPIEndpointDefaultsName];
    self.saveSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:PKSaveResultsDefaultsName];
    self.saveLocationSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:PKSaveLocationDefaultsName];
    self.entriesInQueueLabel.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.sendingIndicator stopAnimating];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(sendingStarted)
												 name:PKSendingStartedNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(sendingFinished)
												 name:PKSendingFinishedNotification
											   object:nil];
    [self refreshQueueCount];
}

- (void)refreshQueueCount
{
    [[PKDataManager sharedManager] numberOfEntriesInQueue:^(long num) {
        self.entriesInQueueLabel.text = [NSString stringWithFormat:@"%ld unsent entries", num];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)apiEndpointEditingBegan:(id)sender
{
    if(self.apiEndpointField.text.length == 0) {
        self.apiEndpointField.text = @"http://";
    }
}

- (IBAction)apiEndpointValueChanged:(id)sender
{
    NSLog(@"New API Endpoint: %@", self.apiEndpointField.text);
    [[NSUserDefaults standardUserDefaults] setObject:self.apiEndpointField.text forKey:PKAPIEndpointDefaultsName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)saveSwitchChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.saveSwitch.isOn forKey:PKSaveResultsDefaultsName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"State: %d", self.saveSwitch.isOn);
}

- (IBAction)saveLocationSwitchChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.saveLocationSwitch.isOn forKey:PKSaveLocationDefaultsName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"State: %d", self.saveLocationSwitch.isOn);
}

- (IBAction)apiEndpointHelpTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://indiewebcamp.com/micropub"];
    [[UIApplication sharedApplication] openURL:url];
    
}

- (IBAction)sendNowWasTapped:(id)sender
{
    [[PKDataManager sharedManager] sendQueueNow];
}

- (void)sendingStarted {
    [self.sendingIndicator startAnimating];
    self.sendNowButton.enabled = NO;
}

- (void)sendingFinished {
    [self.sendingIndicator stopAnimating];
    self.sendNowButton.enabled = YES;
    [self refreshQueueCount];
}


#pragma mark - Flip

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
