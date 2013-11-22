//
//  PKMainViewController.m
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import "PKMainViewController.h"

@interface PKMainViewController ()

@end

@implementation PKMainViewController

NSTimer *timer;
NSDate *targetDate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(PKFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

- (IBAction)startTest:(id)sender
{
    self.resultsLabel.text = @"wait";
    self.tapBtn.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:207.0/255.0 blue:16.0/255.0 alpha:1.0];
    // Pick a random interval and wait that long to start the timer
    NSTimeInterval randomInterval = 4.0;
    targetDate = [NSDate dateWithTimeIntervalSinceNow:randomInterval];
    timer = [NSTimer scheduledTimerWithTimeInterval:randomInterval target:self selector:@selector(activateButton) userInfo:nil repeats:NO];
}

- (void)activateButton
{
    self.tapBtn.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:235.0/255.0 blue:51.0/255.0 alpha:1.0];
}

- (IBAction)endTimer:(id)sender
{
    if(timer) {
        NSLog(@"Tapped!");
        NSLog(@"Ideal Date: %@", targetDate);
        NSTimeInterval diff = [NSDate.date timeIntervalSinceDate:targetDate];
        NSLog(@"%fms", diff * 1000.0);
        NSString *formatString;
        if(diff < 0) {
            formatString = @"%.0fms early";
        } else {
            formatString = @"%.0fms late";
        }
        self.resultsLabel.text = [NSString stringWithFormat:formatString, round(fabs(diff) * 1000.0)];
        self.tapBtn.backgroundColor = [UIColor lightGrayColor];

        [timer invalidate];
        timer = nil;
    }
}

@end
