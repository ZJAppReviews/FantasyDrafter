//
//  FantasyViewController.m
//  FantasyDrafter
//
//  Created by Jack on 8/5/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "FantasyViewController.h"
#import "Fantasy.h"
#import "Player.h"
#import "PlayerIdent.h"

@interface FantasyViewController ()
@end

@implementation FantasyViewController {
    Fantasy *fantasy;
    
    NSArray *myPositions;
    
    int NUM_TEAMS;
    int NUM_PICK;
    int NUM_ROUNDS_IN_ADVANCE;
    
    NSUserDefaults *defaults;
    
    NSArray *availablePlayers;
    NSMutableArray *filteredPlayers;
    
    BOOL isUserPick;
    
    Player *playerToDraft;
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
    [self.tabBarController.tabBar setTintColor:[UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]];
    //[self refreshController];
    
    //NSArray *recomendedPlayers = [fantasy getPlayersByPositionForRound:2];
    //int recomendedPosition = [fantasy getRecomendedPositionForRound:2];
}

-(void) help {
    [self alert:@"Welcome" withMessage:@"Fantasy Football DraftMetrics calculates the best picks for your draft. During the draft, select the players who are drafted. You can see the best players for you in the 'My Pick' tab."];
}

- (IBAction)helpButtonTapped:(id)sender {
    [self help];
}

-(void) alert: (NSString*) title withMessage: (NSString*) message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    
    [alert show];

}

-(void) refreshController {
    
    [self checkUserDefaults];
    
    NUM_TEAMS = [[defaults objectForKey:@"NUM_TEAMS"] intValue];
    NUM_PICK = [[defaults objectForKey:@"MY_PICK"] intValue];
    NUM_ROUNDS_IN_ADVANCE = [[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] intValue];
    //NSLog(@"%i", NUM_PICK);
    fantasy = [[Fantasy alloc] initWithNumTeams:NUM_TEAMS withNumPick:NUM_PICK withNumRoundsInAdvance:NUM_ROUNDS_IN_ADVANCE withCustomScoring:[defaults objectForKey:@"SCORING"]];
    
    [fantasy setNoCalc:true];
    [fantasy calculateData];
    availablePlayers = [fantasy getAvailablePlayers];
    int round = [fantasy getCurrentRound];
    int pick = [fantasy getCurrentPick];
    isUserPick = [fantasy isUserPick];
    
    if(!isUserPick) self.title = [NSString stringWithFormat:@"Round %i, Pick %i", round, pick];
    else self.title = [NSString stringWithFormat:@"Your Pick!"];
    [self initializeArray];
    
    [self.tableView reloadData];
}

-(void) checkUserDefaults {
    defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"NUM_TEAMS"] == nil) [defaults setObject:@8 forKey:@"NUM_TEAMS"];
    if([defaults objectForKey:@"MY_PICK"] == nil) [defaults setObject:@1 forKey:@"MY_PICK"];
    if([defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] == nil) [defaults setObject:@2 forKey:@"NUM_ROUNDS_IN_ADVANCE"];
    if([defaults objectForKey:@"SHOW_BEST_AVAIL"] == nil) [defaults setObject:@NO forKey:@"SHOW_BEST_AVAIL"];
    if([defaults objectForKey:@"SCORING"] == nil) [defaults setObject:@[@.04, @4, @-2, @.1, @6, @0, @.1, @6, @1, @2, @-2] forKey:@"SCORING"];
    if([defaults objectForKey:@"firstTime"] == nil) {
        [defaults setObject:@"true" forKey:@"firstTime"];
        [self help];
    }
    [defaults synchronize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredPlayers count];
    } else {
        return [availablePlayers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath    *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if(indexPath.row < filteredPlayers.count) {
            cell.textLabel.text = ((Player*)[filteredPlayers objectAtIndex: indexPath.row]).name;
            cell.detailTextLabel.text = ((Player*)[filteredPlayers objectAtIndex: indexPath.row]).team;
        }
    } else {
        if(indexPath.row < availablePlayers.count) {
            cell.textLabel.text = ((Player*)[availablePlayers objectAtIndex: indexPath.row]).name;
            cell.detailTextLabel.text = ((Player*)[availablePlayers objectAtIndex: indexPath.row]).team;
        }
    }
     return cell;
 }

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self resetArray];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    filteredPlayers = [NSMutableArray arrayWithArray:[availablePlayers filteredArrayUsingPredicate:predicate]];
}

-(void) initializeArray {
    filteredPlayers = [NSMutableArray arrayWithCapacity:[availablePlayers count]];
}

-(void) resetArray {
    [filteredPlayers removeAllObjects];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        playerToDraft = filteredPlayers[indexPath.row];
    } else {
        playerToDraft = availablePlayers[indexPath.row];
    }
    
    NSString *message = [NSString stringWithFormat:@"Draft %@?", playerToDraft.name];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    
    [alert show];
    
}


- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex:(NSInteger) index {
    if(index == 1) {
        if(playerToDraft != nil) {
            [fantasy draftPlayer:playerToDraft];
            [self refreshController];
            [self.searchDisplayController setActive:NO];
        }
    }
    playerToDraft = nil;
}

@end







