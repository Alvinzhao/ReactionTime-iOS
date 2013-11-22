//
//  PKMainViewController.m
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import "PKMainViewController.h"
#import "PKDataManager.h"

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
    self.resultAccuracyLabel.hidden = YES;
    self.resultTimeLabel.hidden = YES;
    self.helpText.hidden = NO;
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

- (void)startTest
{
    self.resultTimeLabel.hidden = YES;
    self.resultAccuracyLabel.hidden = YES;
    self.helpText.hidden = YES;
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
}

- (void)wasTapped:(UITapGestureRecognizer *)sender
{
    if(self.target.hidden == NO) {
        CGPoint loc = [sender locationInView:self.view];
        [self targetWasTapped:loc];
    } else {
        [self startTest];
    }
}

- (void)targetWasTapped:(CGPoint)tapLocation
{
    NSLog(@"Tapped!");
    NSLog(@"Scheduled Date: %@", targetDate);
    NSLog(@"Target Position: %.0f, %.0f", self.target.center.x, self.target.center.y);
    NSLog(@"Tap Position: %.0f, %.0f", tapLocation.x, tapLocation.y);

    NSTimeInterval timeDiff = [NSDate.date timeIntervalSinceDate:targetDate];
    NSLog(@"Time Diff: %.0fms", timeDiff * 1000.0);

    CGPoint tapDiff = CGPointMake(tapLocation.x - self.target.center.x,
                                  tapLocation.y - self.target.center.y);
    
    NSLog(@"Location Diff: %.0f, %.0f", tapDiff.x, tapDiff.y);

    CGPoint worstPossibleDiff = CGPointMake(MAX(self.target.center.x, self.view.frame.size.width - self.target.center.x),
                                            MAX(self.target.center.y, self.view.frame.size.height - self.target.center.y));
    NSLog(@"Worst possible diff: %f, %f", worstPossibleDiff.x, worstPossibleDiff.y);
    
    CGPoint percentDiff = CGPointMake(1.0 - fabs(tapDiff.x / worstPossibleDiff.x),
                                      1.0 - fabs(tapDiff.y / worstPossibleDiff.y));

    NSLog(@"Percent Accuracy X: %%%.4f (%f / %f)", percentDiff.x*100.0, tapDiff.x, worstPossibleDiff.x);
    NSLog(@"Percent Accuracy Y: %%%.4f (%f / %f)", percentDiff.y*100.0, tapDiff.y, worstPossibleDiff.y);
    
    double accuracyPercent = ((percentDiff.x * 0.5) + (percentDiff.y * 0.5)) * 100.0;
    
    self.resultTimeLabel.text = [NSString stringWithFormat:@"Delay: %.0fms", round(fabs(timeDiff) * 1000.0)];
    self.resultAccuracyLabel.text = [NSString stringWithFormat:@"Accuracy: %.0f%%", accuracyPercent];
    
    self.resultTimeLabel.hidden = NO;
    self.resultAccuracyLabel.hidden = NO;
    self.helpText.hidden = NO;
    self.target.hidden = YES;

    [timer invalidate];
    timer = nil;
    
    // Add to the database
    NSDictionary *entry = @{
                            @"timestamp": [NSNumber numberWithLong:(long)[NSDate.date timeIntervalSince1970]],
                            @"delay": [NSNumber numberWithDouble:round(timeDiff * 1000.0)],
                            @"tap_diff": @{
                                @"x": [NSNumber numberWithFloat:round(tapDiff.x)],
                                @"y": [NSNumber numberWithFloat:round(tapDiff.y)],
                            },
                            @"tap_location": @{
                                @"x": [NSNumber numberWithFloat:round(tapLocation.x)],
                                @"y": [NSNumber numberWithFloat:round(tapLocation.y)],
                            },
                            @"target_location": @{
                                @"x": [NSNumber numberWithFloat:round(self.target.center.x)],
                                @"y": [NSNumber numberWithFloat:round(self.target.center.y)],
                            },
                            @"percent": @{
                                @"x": [NSNumber numberWithDouble:round(percentDiff.x * 10000.0) / 100.0],
                                @"y": [NSNumber numberWithDouble:round(percentDiff.y * 10000.0) / 100.0],
                                @"overall": [NSNumber numberWithDouble:round(accuracyPercent * 10000.0) / 100.0],
                            }
                          };
    [[PKDataManager sharedManager] addEntryToQueue:entry withKey:[NSString stringWithFormat:@"%ld", (long)[NSDate.date timeIntervalSince1970]]];
    [[PKDataManager sharedManager] scheduleSend];
}

@end
