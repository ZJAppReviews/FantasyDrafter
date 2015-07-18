//
//  NumRoundsViewController.m
//  FantasyDrafter
//
//  Created by Jack on 8/6/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "NumRoundsViewController.h"

@interface NumRoundsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *numRoundsTextBox;

@end

@implementation NumRoundsViewController {
    NSUserDefaults *defaults;
}

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender {
    int newNumber = [_numRoundsTextBox.text intValue];
    if(newNumber >= 1 && newNumber <= 6) {
        [defaults setObject:[NSNumber numberWithInt:newNumber] forKey:@"NUM_ROUNDS_IN_ADVANCE"];
        [defaults synchronize];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid number"
                                                        message:@"You must select between 1 and 6 rounds ahead."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    _numRoundsTextBox.text = [NSString stringWithFormat: @"%@", [defaults valueForKey:@"NUM_ROUNDS_IN_ADVANCE"]];
    
    
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
