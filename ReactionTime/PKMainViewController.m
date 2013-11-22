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
CGPoint targetPosition;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.target.hidden = YES;
    self.countdownLabel.hidden = YES;
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

#pragma mark -

- (IBAction)startTest:(id)sender
{
    self.resultTimeLabel.hidden = YES;
    self.resultAccuracyLabel.hidden = YES;
    self.startBtn.hidden = YES;
    self.target.hidden = YES;
    
    self.countdownLabel.text = @"3";
    self.countdownLabel.hidden = NO;
    
    targetDate = [NSDate dateWithTimeIntervalSinceNow:3.0];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
}

- (void)timerTick
{
    NSTimeInterval diff = [NSDate.date timeIntervalSinceDate:targetDate];
    if(diff < 0) {
        self.countdownLabel.text = [NSString stringWithFormat:@"%d", (int)(abs(round(diff)))];
    } else {
        self.countdownLabel.hidden = YES;
        [timer invalidate];
        [self activateButton];
    }
}

- (void)activateButton
{
    float minX = 40.0;
    float maxX = 320.0 - 40.0;
    float minY = 40.0;
    float maxY = 568.0 - 40.0;

    float x = (drand48() * (maxX - minX)) + minX;
    float y = (drand48() * (maxY - minY)) + minY;
    
    targetPosition = CGPointMake(x, y);
    self.target.center = targetPosition;
    self.target.hidden = NO;
//    self.tapBtn.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:235.0/255.0 blue:51.0/255.0 alpha:1.0];
}

- (void)wasTapped:(UITapGestureRecognizer *)sender
{
    CGPoint loc = [sender locationInView:self.view];
    [self targetWasTapped:loc];
}

- (void)targetWasTapped:(CGPoint)tapLocation
{
    if(self.target.hidden == NO) {
        NSLog(@"Tapped!");
        NSLog(@"Scheduled Date: %@", targetDate);
        NSLog(@"Target Position: %.0f, %.0f", self.target.center.x, self.target.center.y);
        NSLog(@"Tap Position: %.0f, %.0f", tapLocation.x, tapLocation.y);

        NSTimeInterval diff = [NSDate.date timeIntervalSinceDate:targetDate];
        NSLog(@"Time Diff: %.0fms", diff * 1000.0);
        NSLog(@"Location Diff: %.0f, %.0f", tapLocation.x - self.target.center.x, tapLocation.y - self.target.center.y);
        
        float accuracyScore = abs(tapLocation.x - self.target.center.x) + abs(tapLocation.y - self.target.center.y);
        
        self.resultTimeLabel.text = [NSString stringWithFormat:@"%.0fms", round(fabs(diff) * 1000.0)];
        self.resultAccuracyLabel.text = [NSString stringWithFormat:@"%.0f", accuracyScore];
        
        self.resultTimeLabel.hidden = NO;
        self.resultAccuracyLabel.hidden = NO;
        self.startBtn.hidden = NO;
        self.target.hidden = YES;

        [timer invalidate];
        timer = nil;
    }
}

@end
