//
//  PKMainViewController.h
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import "PKFlipsideViewController.h"

@interface PKMainViewController : UIViewController <PKFlipsideViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *helpText;
@property (strong, nonatomic) IBOutlet UIImageView *target;

@property (strong, nonatomic) IBOutlet UILabel *resultTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultAccuracyLabel;

@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;

- (void)wasTapped:(UITapGestureRecognizer *)sender;

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
- (IBAction)deleteWasTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;

@end
