//
//  DraftHistoryViewController.m
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "DraftHistoryViewController.h"
#import "Fantasy.h"
#import "Player.h"
#import "PlayerIdent.h"

@interface DraftHistoryViewController ()
@end

@implementation DraftHistoryViewController {
    Fantasy *fantasy;
    
    NSArray *myPositions;
    
    NSUserDefaults *defaults;
    
    NSArray *draftHistory;
    
    int NUM_TEAMS;
    int NUM_PICK;
    int NUM_ROUNDS_IN_ADVANCE;
}

-(void) viewDidAppear:(BOOL)animated {
    if([fantasy picksHaveChanged] || [fantasy settingsHaveChanged:[[defaults objectForKey:@"NUM_TEAMS"] floatValue] :[[defaults objectForKey:@"MY_PICK"] floatValue] :[[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] floatValue] :[defaults objectForKey:@"SCORING"]] || fantasy == nil)
        [self refreshController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    myPositions = @[@"QB", @"RB", @"WR", @"TE"];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    //[self refreshController];
    
    //NSArray *recomendedPlayers = [fantasy getPlayersByPositionForRound:2];
    //int recomendedPosition = [fantasy getRecomendedPositionForRound:2];
}

-(void) refreshController {
    
    [self checkUserDefaults];
    
    NUM_TEAMS = [[defaults objectForKey:@"NUM_TEAMS"] intValue];
    NUM_PICK = [[defaults objectForKey:@"MY_PICK"] intValue];
    NUM_ROUNDS_IN_ADVANCE = [[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] intValue];
    
    fantasy = [[Fantasy alloc] initWithNumTeams:NUM_TEAMS withNumPick:NUM_PICK withNumRoundsInAdvance:NUM_ROUNDS_IN_ADVANCE];
    
    draftHistory = [fantasy getDraftHistory];
    
    [self.tableView reloadData];
}

-(void) checkUserDefaults {
    defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"NUM_TEAMS"] == nil) [defaults setObject:@8 forKey:@"NUM_TEAMS"];
    if([defaults objectForKey:@"MY_PICK"] == nil) [defaults setObject:@1 forKey:@"MY_PICK"];
    if([defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] == nil) [defaults setObject:@5 forKey:@"NUM_ROUNDS_IN_ADVANCE"];
    [defaults synchronize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [draftHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath    *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int adjRow = (int) draftHistory.count - 1 - (int) indexPath.row;
    
    Player *draftedPlayer = draftHistory[adjRow];
    
    int overallPick = (int) adjRow + 1;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Pick %i", overallPick];
    cell.textLabel.text = draftedPlayer.name;
    
    return cell;
}

- (IBAction)resetDraftButtonPressed:(id)sender {
    
    NSString *message = @"Are you sure that you want to reset the draft?";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
    
}


- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) index {
    if(index == 1) {
        [fantasy clearDraft];
        [self refreshController];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [fantasy removePickAtIndex:(int) [draftHistory count] - 1 - (int) indexPath.row];
    [self refreshController];
}

@end







