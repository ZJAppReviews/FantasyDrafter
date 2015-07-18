//
//  SettingsViewController.m
//  FantasyDrafter
//
//  Created by Jack on 8/7/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "SettingsViewController.h"
#import "Fantasy.h"

@interface SettingsViewController ()

@property (strong, nonatomic) IBOutlet UITableViewCell *refreshProjectionsCell;

@end

@implementation SettingsViewController

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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath       *)indexPath
{
    if ([indexPath isEqual:[tableView indexPathForCell:self.refreshProjectionsCell]])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int NUM_TEAMS = [[defaults objectForKey:@"NUM_TEAMS"] intValue];
        int NUM_PICK = [[defaults objectForKey:@"MY_PICK"] intValue];
        int NUM_ROUNDS_IN_ADVANCE = [[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] intValue];
        Fantasy *fantasy = [[Fantasy alloc] initWithNumTeams:NUM_TEAMS withNumPick:NUM_PICK withNumRoundsInAdvance:NUM_ROUNDS_IN_ADVANCE withCustomScoring:[defaults objectForKey:@"SCORING"]];
        [fantasy saveFilesToDocuments];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Projections updated" message:@"Your projections have been updated. Check back again for more updates on injuries, suspensions, and more!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
