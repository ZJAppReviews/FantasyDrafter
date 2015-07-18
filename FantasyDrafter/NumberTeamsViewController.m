//
//  NumberTeamsViewController.m
//  FantasyDrafter
//
//  Created by Jack on 8/6/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "NumberTeamsViewController.h"

@interface NumberTeamsViewController ()
@property (strong, nonatomic) IBOutlet UITextField *numberTeamsTextBox;

@end

@implementation NumberTeamsViewController {
    NSUserDefaults *defaults;
}

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender {
    int newNumber = [_numberTeamsTextBox.text intValue];
    if(newNumber >= 4 && newNumber <= 20) {
        [defaults setObject:[NSNumber numberWithInt:newNumber] forKey:@"NUM_TEAMS"];
        if(newNumber < [[defaults objectForKey:@"MY_PICK"] intValue]) [defaults setObject:[NSNumber numberWithInt:newNumber] forKey:@"MY_PICK"];
        [defaults synchronize];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid number"
                                                        message:@"You must have between 4 and 20 teams."
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
    
    _numberTeamsTextBox.text = [NSString stringWithFormat: @"%@", [defaults valueForKey:@"NUM_TEAMS"]];
    
    
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
