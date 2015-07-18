//
//  CustomScoringViewController.m
//  FantasyDrafter
//
//  Created by Jack on 8/7/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#define N(x) [NSNumber numberWithInt: x]
#define F(x) [NSNumber numberWithFloat: x]

#import "CustomScoringViewController.h"

@interface CustomScoringViewController ()
@property (strong, nonatomic) IBOutlet UITextField *passingYardsFirstField;
@property (strong, nonatomic) IBOutlet UITextField *passingYardsSecondField;
@property (strong, nonatomic) IBOutlet UITextField *passingTouchdownField;
@property (strong, nonatomic) IBOutlet UITextField *interceptionField;
@property (strong, nonatomic) IBOutlet UITextField *rushingYardsFirstField;
@property (strong, nonatomic) IBOutlet UITextField *rushingYardsSecondField;
@property (strong, nonatomic) IBOutlet UITextField *rushingTouchdownField;
@property (strong, nonatomic) IBOutlet UITextField *receptionsFirstField;
@property (strong, nonatomic) IBOutlet UITextField *receptionsSecondField;
@property (strong, nonatomic) IBOutlet UITextField *receivingYardsFirstField;
@property (strong, nonatomic) IBOutlet UITextField *receivingYardsSecondField;
@property (strong, nonatomic) IBOutlet UITextField *receivingTouchdownField;
@property (strong, nonatomic) IBOutlet UITextField *passing2PtConversionField;
@property (strong, nonatomic) IBOutlet UITextField *rushing2PtConversionField;
@property (strong, nonatomic) IBOutlet UITextField *fumblesLostField;

@end

@implementation CustomScoringViewController {
    NSUserDefaults *defaults;
}


- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender {
    
    if([_passingYardsFirstField.text floatValue] <= 0 || [_rushingYardsFirstField.text floatValue] <= 0 || [_receivingYardsFirstField.text floatValue] <= 0 || [_receptionsFirstField.text floatValue] <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid number"
                                                        message:@"The numbers on the left must be positive."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if([_interceptionField.text floatValue] > 0 || [_fumblesLostField.text floatValue] > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid number"
                                                        message:@"Fumbles and interceptions must be negative or zero."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if([_passingYardsSecondField.text floatValue] < 0 || [_passingTouchdownField.text floatValue] < 0 || [_rushingYardsSecondField.text floatValue] < 0 || [_receivingYardsSecondField.text floatValue] < 0 || [_receptionsSecondField.text floatValue] < 0 || [_receivingTouchdownField.text floatValue] < 0 || [_passing2PtConversionField.text floatValue] < 0 || [_rushing2PtConversionField.text floatValue] < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid number"
                                                        message:@"Numbers except for fumbles and interceptions must be positive or zero."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSArray *newVals = @[F([_passingYardsSecondField.text floatValue] / [_passingYardsFirstField.text floatValue]), _passingTouchdownField.text, _interceptionField.text, F([_rushingYardsSecondField.text floatValue] / [_rushingYardsFirstField.text floatValue]), _rushingTouchdownField.text, F([_receptionsSecondField.text floatValue] / [_receptionsFirstField.text floatValue]), F([_receivingYardsSecondField.text floatValue] / [_receivingYardsFirstField.text floatValue]), _receivingTouchdownField.text, _passing2PtConversionField.text, _rushing2PtConversionField.text, _fumblesLostField.text];
    [defaults setObject:newVals forKey:@"SCORING"];
    [defaults synchronize];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *scoring = [defaults objectForKey:@"SCORING"];
    
    _passingYardsFirstField.text = [NSString stringWithFormat:@"%.0f", [scoring[0] floatValue] == 0 ? 25 : 1/[scoring[0] floatValue]];
    _passingYardsSecondField.text = [scoring[0] floatValue] == 0 ? @"0" : @"1";
    _passingTouchdownField.text = [NSString stringWithFormat:@"%@", scoring[1]];
    _interceptionField.text = [NSString stringWithFormat:@"%@", scoring[2]];
    _rushingYardsFirstField.text = [NSString stringWithFormat:@"%.0f", [scoring[3] floatValue] == 0 ? 10 : 1/[scoring[3] floatValue]];
    _rushingYardsSecondField.text = [scoring[3] floatValue] == 0 ? @"0" : @"1";
    _rushingTouchdownField.text = [NSString stringWithFormat:@"%@", scoring[4]];
    _receptionsFirstField.text = [NSString stringWithFormat:@"%.0f", [scoring[5] floatValue] == 0 ? 1 : 1/[scoring[5] floatValue]];
    _receptionsSecondField.text = [scoring[5] floatValue] == 0 ? @"0" : @"1";
    _receivingYardsFirstField.text = [NSString stringWithFormat:@"%.0f", [scoring[6] floatValue] == 0 ? 10 : 1/[scoring[6] floatValue]];
    _receivingYardsSecondField.text = [scoring[6] floatValue] == 0 ? @"0" : @"1";
    _receivingTouchdownField.text = [NSString stringWithFormat:@"%@", scoring[7]];
    _passing2PtConversionField.text = [NSString stringWithFormat:@"%@", scoring[8]];
    _rushing2PtConversionField.text = [NSString stringWithFormat:@"%@", scoring[9]];
    _fumblesLostField.text = [NSString stringWithFormat:@"%@", scoring[10]];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
        self.navigationController.navigationBar.translucent = NO;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
