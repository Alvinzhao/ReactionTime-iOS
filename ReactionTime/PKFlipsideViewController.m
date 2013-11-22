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

- (IBAction)apiEndpointHelpTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://indiewebcamp.com/micropub"];
    [[UIApplication sharedApplication] openURL:url];
    
}

#pragma mark - Flip

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
