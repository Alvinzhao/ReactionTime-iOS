//
//  PKFlipsideViewController.h
//  ReactionTime
//
//  Created by Aaron Parecki on 11/22/13.
//  Copyright (c) 2013 Aaron Parecki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PKFlipsideViewController;

@protocol PKFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(PKFlipsideViewController *)controller;
@end

@interface PKFlipsideViewController : UIViewController

@property (weak, nonatomic) id <PKFlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *saveSwitch;
@property (strong, nonatomic) IBOutlet UITextField *apiEndpointField;
- (IBAction)apiEndpointEditingBegan:(id)sender;
- (IBAction)apiEndpointValueChanged:(id)sender;
- (IBAction)apiEndpointHelpTapped:(id)sender;
- (IBAction)saveSwitchChanged:(id)sender;

@end

