//
//  PKMainViewController.h
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import "PKFlipsideViewController.h"

@interface PKMainViewController : UIViewController <PKFlipsideViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *startBtn;
@property (strong, nonatomic) IBOutlet UIButton *tapBtn;

- (IBAction)startTimer:(id)sender;
- (IBAction)endTimer:(id)sender;

@end
