//
//  AdjustProjectionsViewController.m
//  DraftMetrics
//
//  Created by Jack on 8/9/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "AdjustProjectionsViewController.h"
#import "Fantasy.h"

@interface AdjustProjectionsViewController ()

@end

@implementation AdjustProjectionsViewController {
    Fantasy *fantasy;
    
    int NUM_TEAMS;
    int NUM_PICK;
    int NUM_ROUNDS_IN_ADVANCE;
    
    NSUserDefaults *defaults;
    
    NSArray *players;
    NSMutableArray *filteredPlayers;
    
    NSMutableArray *allTextFields;
}


- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender {
    
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
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
        self.navigationController.navigationBar.translucent = NO;
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    NUM_TEAMS = [[defaults objectForKey:@"NUM_TEAMS"] intValue];
    NUM_PICK = [[defaults objectForKey:@"MY_PICK"] intValue];
    NUM_ROUNDS_IN_ADVANCE = [[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] intValue];
    
    fantasy = [[Fantasy alloc] initWithNumTeams:NUM_TEAMS withNumPick:NUM_PICK withNumRoundsInAdvance:NUM_ROUNDS_IN_ADVANCE withCustomScoring:[defaults objectForKey:@"SCORING"]];
    
    players = [fantasy getPlayerProjections];
    [self initializeArray];
    
    allTextFields = [NSMutableArray array];
    
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


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [filteredPlayers count];
    } else {
        return [players count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath    *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if([tableView visibleCells].count > 0 && [tableView visibleCells][0] == cell) {
        for(UITextField *t in allTextFields) {
            [t removeFromSuperview];
        }
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UITextField *playerPoints = [[UITextField alloc] initWithFrame:cell.frame];
        playerPoints.autocorrectionType = UITextAutocorrectionTypeNo;
        [playerPoints setClearButtonMode:UITextFieldViewModeWhileEditing];
        
        [allTextFields addObject:playerPoints];
    }
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    UITextField *playerPoints = allTextFields[indexPath.row];
    
    [cell.contentView addSubview:playerPoints];
    
    
    NSArray *arrayForData = tableView == self.searchDisplayController.searchResultsTableView ? filteredPlayers : players;
    
    cell.textLabel.text = ((Player*)[arrayForData objectAtIndex: indexPath.row]).name;
    cell.detailTextLabel.text = ((Player*)[arrayForData objectAtIndex: indexPath.row]).team;
    playerPoints.text = [NSString stringWithFormat:@"%.0f and %f", ((Player*)[arrayForData objectAtIndex: indexPath.row]).points, ((Player*)[arrayForData objectAtIndex: indexPath.row]).points];
    return cell;
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self resetArray];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    filteredPlayers = [NSMutableArray arrayWithArray:[players filteredArrayUsingPredicate:predicate]];
}

-(void) initializeArray {
    filteredPlayers = [NSMutableArray arrayWithCapacity:[players count]];
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

@end
