//
//  PKMainViewController.h
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import "PKFlipsideViewController.h"

@interface PKMainViewController : UIViewController <PKFlipsideViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *startBtn;
@property (strong, nonatomic) IBOutlet UIImageView *target;

@property (strong, nonatomic) IBOutlet UILabel *resultTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultAccuracyLabel;

@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;

- (IBAction)startTest:(id)sender;
- (void)wasTapped:(UITapGestureRecognizer *)sender;

@end
