//
//  YourPickViewController.m
//  FantasyDrafter
//
//  Created by Jack on 8/7/14.
//  Copyright (c) 2014 JackCable. All rights reserved.
//

#import "YourPickViewController.h"
#import "Fantasy.h"
#import "Player.h"

@interface YourPickViewController ()
@property (strong, nonatomic) IBOutlet UIPickerView *positionPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *roundPicker;
@property (strong, nonatomic) IBOutlet UITableView *playersTable;

@property (strong, nonatomic) IBOutlet UILabel *recommendedPositionLabel;
@end

@implementation YourPickViewController {
    Fantasy *fantasy;
    
    NSArray *myPositions;
    
    int NUM_TEAMS;
    int NUM_PICK;
    int NUM_ROUNDS_IN_ADVANCE;
    
    NSUserDefaults *defaults;
    
    NSArray *recommendedPlayers;
    int recommendedPosition;
    
    int thisRound;
    
    NSMutableArray *roundsPreviewed;
    
    int originalRound;
    
    BOOL showBestAvailable;
    
    Player *playerToDraft;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myPositions = @[@"QB", @"RB", @"WR", @"TE"];
    
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:0.529 blue:0.22 alpha:1]; /*#008738*/
        self.navigationController.navigationBar.translucent = NO;
    }
    
    //self.view.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1]; /*#e5e5e5*/
    // Do any additional setup after loading the view.
    //[self refreshController : true];
}

-(void) viewDidAppear:(BOOL)animated {
    if([fantasy picksHaveChanged] || [fantasy settingsHaveChanged:[[defaults objectForKey:@"NUM_TEAMS"] floatValue] :[[defaults objectForKey:@"MY_PICK"] floatValue] :[[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] floatValue] :[defaults objectForKey:@"SCORING"]] || [[defaults objectForKey:@"SHOW_BEST_AVAIL"] boolValue] != showBestAvailable || fantasy == nil)
        [self refreshController : true : true];
}

-(void) refreshController : (BOOL) calculateRound : (BOOL) newFantasy {
    
    [self checkUserDefaults];
    
    showBestAvailable = [[defaults objectForKey:@"SHOW_BEST_AVAIL"] boolValue];
    
    NUM_TEAMS = [[defaults objectForKey:@"NUM_TEAMS"] intValue];
    NUM_PICK = [[defaults objectForKey:@"MY_PICK"] intValue];
    NUM_ROUNDS_IN_ADVANCE = [[defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] intValue];
    
    if(newFantasy) {
        fantasy = [[Fantasy alloc] initWithNumTeams:NUM_TEAMS withNumPick:NUM_PICK withNumRoundsInAdvance:NUM_ROUNDS_IN_ADVANCE];
        [fantasy calculateData];
        self.playersTable.userInteractionEnabled = [fantasy isUserPick];
    }
    if(calculateRound) {
        thisRound = [fantasy getNextRoundToDraft];
        originalRound = thisRound;
    }
    recommendedPlayers = [fantasy getPlayersByPositionForRound:thisRound];
    recommendedPosition = [fantasy getRecommendedPositionForRound:thisRound];
    [_positionPicker selectRow:recommendedPosition inComponent:0 animated:YES];
    
    if(calculateRound) {
        roundsPreviewed = [NSMutableArray array];
        for(int i=thisRound; i<thisRound+NUM_ROUNDS_IN_ADVANCE; i++) {
            if(i > 14) break;
            [roundsPreviewed addObject:[NSString stringWithFormat:@"Round %i", i]];
        }
        [_roundPicker selectRow:0 inComponent:0 animated:YES];
        [_roundPicker reloadAllComponents];
    }
    
    _recommendedPositionLabel.text = [NSString stringWithFormat:@"Recommended Position : %@", myPositions[recommendedPosition]];
    
    [_playersTable reloadData];
}


-(void) checkUserDefaults {
    defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"NUM_TEAMS"] == nil) [defaults setObject:@8 forKey:@"NUM_TEAMS"];
    if([defaults objectForKey:@"MY_PICK"] == nil) [defaults setObject:@1 forKey:@"MY_PICK"];
    if([defaults objectForKey:@"NUM_ROUNDS_IN_ADVANCE"] == nil) [defaults setObject:@5 forKey:@"NUM_ROUNDS_IN_ADVANCE"];
    [defaults synchronize];
    
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _positionPicker)
        return myPositions.count;
    else
        return roundsPreviewed.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if(pickerView == _positionPicker)
        return myPositions[row];
    else
        return roundsPreviewed[row];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    if(pickerView == _positionPicker)
        [_playersTable reloadData];
    else {
        thisRound = originalRound + (int) row;
        [self refreshController:false : false];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int) getSelectedPosition {
    return (int)[_positionPicker selectedRowInComponent:0];
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)recommendedPlayers[[self getSelectedPosition]]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath    *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray *playersForPosition = recommendedPlayers[[self getSelectedPosition]];
    Player *curr = playersForPosition[indexPath.row];
    int chanceOfAvailability = roundf([fantasy getChanceOfAvailability:curr :thisRound]*100);
    int chanceOfBest = roundf([fantasy getChanceOfBestAvailable :curr :thisRound]*100);
    cell.detailTextLabel.adjustsFontSizeToFitWidth=YES;
    
    cell.textLabel.text = curr.name;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        if(!showBestAvailable) cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f pts, %02d%% avbl.", curr.points, chanceOfAvailability];
        else cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f pts, %02d%%, %02d%%.", curr.points, chanceOfAvailability, chanceOfBest];
    } else
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f pts, %02d%% chance of availability, %02d%% chance of best available", curr.points, chanceOfAvailability, chanceOfBest];
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(![fantasy isUserPick]) return;
    
    NSArray *playersForPosition = recommendedPlayers[[self getSelectedPosition]];
    
    playerToDraft = playersForPosition[indexPath.row];
    
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
            [self refreshController : true : true];
        }
    }
    playerToDraft = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
