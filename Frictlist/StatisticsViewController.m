//
//  StatisticsViewController.m
//  Frictlist
//
//  Created by Tony Flo on 12/17/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "StatisticsViewController.h"
#import "version.h"
#import "SignInViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"

@interface StatisticsViewController ()

@end

@implementation StatisticsViewController

//bad globals
static int uid = -1; //uid (pk) of an user that's not signed in
UIAlertView *alertView;
NSString * address = @"http://ivisited.flooreeda.com/scripts/";

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
	// Do any additional setup after loading the view.
    NSLog(@"View did load");
    
    //tab bar titles
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Frictlist"];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Settings"];
    
    //tab bar icons
    [[self.tabBarController.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"list_icon.png"]];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"gear_icon.png"]];
}

-(void)checkFirstAppOpen
{
    SqlHelper * sql = [SqlHelper alloc];
    [sql createEditableCopyOfDatabaseIfNeeded];
    
    //check first sign in
    PlistHelper *plist = [[PlistHelper alloc] initDefaults];

    if([plist getPk] == -1)
    {
        [self showWelcomeDialog];
    }
    else
    {
        NSLog(@"not first");
    }
}

- (void) showWelcomeDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Welcome to Frictlist!"];
    [alert setMessage:@"Thank you for downloading Frictlist. You will now be directed to the sign in screen.  There you will be able to create your account.  If you already have an account, you will be able to sign in."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Sign In"];
    [alert setTag:8];
    [alert show];
}

//Sign in
-(IBAction)signinButtonPress
{
    //not signed in
    if(uid < 0)
    {
        //not signed in, now go to sign in page
        [self performSegueWithIdentifier:@"sign_in" sender:self];
    }
    //sign out
    else
    {
        //signed in, now sign out
        [self showSignOutConfirmationDialog];
    }
}

- (void) showSignOutConfirmationDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Sign Out"];
    [alert setMessage:@"Are you sure you want to sign out?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setTag:4];
    [alert show];
}

//logic to sign out
- (void) signOut
{
    //delete plist
    PlistHelper *plist = [[PlistHelper alloc] resetPlist];
    uid = [plist getPk];
    
    //delete sqlite
    SqlHelper *sql = [SqlHelper alloc];
    BOOL success = [sql removeSqliteFile];
    
    
    if(uid <= 0 && success)
    {
        //now signed out
        [signinBtn setTitle:@"Sign In" forState:UIControlStateNormal];
        
        //set email label back
        [emailLabel setText:[plist getEmail]];
        
        //reset stats
        [self resetStatistics];
                
        //force sign in
        [self checkFirstAppOpen];
    }
    else
    {
        //something went wrong, not signed out
        [self showSignOutFailureAlert];
    }
    [self.view setNeedsDisplay];
    
}

//sign out was successful
- (void)showSignOutSuccessAlert
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Success"];
    [alert setMessage:@"You are now signed out."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//sign out was failure
- (void)showSignOutFailureAlert
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Sorry"];
    [alert setMessage:@"Something went wrong when signing out. Please try again. If the problem presists, please contact the developer."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

- (void)showConfirmAlert
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"All Data Will Be Erased"];
    [alert setMessage:@"Are you sure you want to continue?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setTag:1];
    [alert show];
}

//take an action when a choice is made in an alert dialog
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 2)
    {
        NSLog(@"2");
        if (buttonIndex == 0)
        {
            //Sign In, sign in page
            [self performSegueWithIdentifier:@"sign_in" sender:self];
        }
        else if (buttonIndex == 1)
        {
            //Cancel, dismiss
        }
    }
    //sign out
    else if(alertView.tag == 4)
    {
        NSLog(@"sign out");
        if(buttonIndex == 0)
        {
            //Yes, signout
            [self signOut];
        }
        else
        {
            //Cancel, dismiss
        }
    }
    else if(alertView.tag == 5)
    {
        if (buttonIndex == 0)
        {
            // I Understand, signin
            [self performSegueWithIdentifier:@"sign_in" sender:self];
        }
        else if (buttonIndex == 1)
        {
            //Cancel, dismis
        }
    }
    //welcome dialog
    else if(alertView.tag == 8)
    {
        if (buttonIndex == 0)
        {
            // Sign in, signin
            [self performSegueWithIdentifier:@"sign_in" sender:self];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"sign_in"])
    {
        //SignInViewController *destViewController = segue.destinationViewController;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [self statistics];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self checkFirstAppOpen];
    
    //check signed in
    PlistHelper * plist = [PlistHelper alloc];

    //assign static uid to plist pk
    uid = [plist getPk];
    NSLog(@"will appear uid = %d", uid);
    
    //check if signed in
    if(uid >= 0)
    {
        NSString * email_text = [plist getEmail];
        [signinBtn setTitle:@"Sign Out" forState:UIControlStateNormal];
        [emailLabel setText:[NSString stringWithFormat:@"%@", email_text]];
    }
    else
    {
        [emailLabel setText:[plist getEmail]];

    }
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
    
    //display stats
    [self statistics];
    
    //reset navigation controllers
    [self resetAllTabs];
}

-(void)statistics
{
    SqlHelper *sql = [SqlHelper alloc];
    NSArray *mateList = [sql get_mate_list];
    NSArray *mate_ids = mateList[0];
    
    int counts[4] = {0,0,0,0};
    
    //loop over all fricts
    for(int mate_index = 0; mate_index < mate_ids.count; mate_index++)
    {
        //get frict bases count
        NSArray *fl = [sql get_frict_list:[mate_ids[mate_index] intValue]];
        if(fl != NULL)
        {
            int count = ((NSArray *)fl[0]).count;
            for(int i = 0; i < count; i++)
            {
                //sick logic
                counts[[fl[3][i] intValue]]++;
            }
        }
    }
    
    //determine scores
    int scores[4] ={0,0,0,0};
    scores[0]=counts[0] * 1;
    scores[1]=counts[1] * 3;
    scores[2]=counts[2] * 5;
    scores[3]=counts[3] * 9;
    
    //display the counts
    firstCount.text = [NSString stringWithFormat:@"%d",counts[0]];
    firstCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:17.0];
    secondCount.text = [NSString stringWithFormat:@"%d",counts[1]];
    secondCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:15.0];
    thirdCount.text = [NSString stringWithFormat:@"%d",counts[2]];
    thirdCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:17.0];
    homeCount.text = [NSString stringWithFormat:@"%d",counts[3]];
    homeCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:19.0];
    
    //display the scores
    firstScore.text = [NSString stringWithFormat:@"%d",scores[0]];
    firstScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:25.0];
    secondScore.text = [NSString stringWithFormat:@"%d",scores[1]];
    secondScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:20.0];
    thirdScore.text = [NSString stringWithFormat:@"%d",scores[2]];
    thirdScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:25.0];
    homeScore.text = [NSString stringWithFormat:@"%d",scores[3]];
    homeScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:30.0];
    
    //calculate totals
    int score = 0;
    int count = 0;
    for(int i = 0; i < 4; i++)
    {
        score += scores[i];
        count += counts[i];
    }
    
    //display the total score and count
    totalCount.text = [NSString stringWithFormat:@"%d", count];
    totalCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:27];
    totalScore.text = [NSString stringWithFormat:@"%d", score];
    totalScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:27];
}

-(void)resetStatistics
{
    firstCount.text = @"0";
    secondCount.text = @"0";
    thirdCount.text = @"0";
    homeCount.text = @"0";
    firstScore.text = @"0";
    secondScore.text = @"0";
    thirdScore.text = @"0";
    homeScore.text = @"0";
    totalCount.text = @"0";
    totalScore.text = @"0";
}

- (void)resetAllTabs
{
    for (id controller in self.tabBarController.viewControllers) {
        
        if ([controller isMemberOfClass:[UINavigationController class]]) {
            [controller popToRootViewControllerAnimated:NO];
        }
    }
}

- (IBAction)emailButtonPress:(id)sender
{
    
    if ([MFMailComposeViewController canSendMail]) {

        PlistHelper *plist = [PlistHelper alloc];
        NSString * fn = [plist getFirstName];
        NSString * ln = [plist getLastName];
        NSString * un = [plist getEmail];
        
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"tony@flooreeda.com"]];
        [composeViewController setSubject:@"Frictlist iOS App"];
        [composeViewController setMessageBody:[NSString stringWithFormat:@"Hi Tony,\n\nI really like your Frictlist app!\n\nHappy Fricting!\n%@ %@\n%@", fn, ln, un] isHTML:NO];
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:composeViewController animated:YES completion:nil];
        } else {
            [self presentModalViewController:composeViewController animated:YES];
        }
        //[self presentViewController:composeViewController animated:YES completion:nil];
    }
}

//catch result of email
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
