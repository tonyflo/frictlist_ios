//
//  StatisticsViewController.m
//  Frictlist
//
//  Created by Tony Flo on 12/17/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "StatisticsViewController.h"
#import "Frict.h"
#import "version.h"
#import "SignInViewController.h"
#import "PlistHelper.h"

@interface StatisticsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *visited;


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

//get the number of states that were visited
- (int)countVisited
{
    int count = 0;
    PlistHelper * plist = [PlistHelper alloc];
    
    //count visits
    for(int i = 0; i < 50; i++)
    {
        char v = [[plist getIvisited] characterAtIndex:i];
        if(v == '1')
        {
            count++;
        }
    }
    
    return count;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"View did load");
    
    //tab bar titles
    [[self.tabBarController.tabBar.items objectAtIndex:0] setTitle:@"Fricts"];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setTitle:@"Settings"];
    
    //tab bar icons
    [[self.tabBarController.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"list_icon.png"]];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"gear_icon.png"]];
}

-(void)checkFirstAppOpen
{
    //check first sign in
    PlistHelper *plist = [[PlistHelper alloc] initDefaults];
    int first = [plist getFirst];
    if([plist getPk] == -1)
    {
        first = 1;
    }
    
    if(first == 1)
    {
        [self showWelcomeDialog];
        //set the plist first value to zero so the welcome message doesn't show up anymore
        [plist setFirst:0];
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
    PlistHelper *plist = [PlistHelper alloc];
    [plist resetEmail];
    [plist resetIvisited];
    [plist resetPk];
    
    uid = [plist getPk];
    
    if(uid <= 0)
    {
        //now signed out
        [signinBtn setTitle:@"Sign In" forState:UIControlStateNormal];
        
        //set email label back
        [emailLabel setText:[plist getEmail]];
        
        //updated visited number
        self.visited.text = [NSString stringWithFormat:@"%d", [self countVisited]];
        
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


-(IBAction)emailButtonPress
{
    NSString *recipients = @"mailto:tony@flooreeda.com?subject=Frictlist iOS App";
    NSString *body = @"";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

-(IBAction)resetButtonPress
{
    [self showConfirmAlert];
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
    //reset data
    if(alertView.tag == 1)
    {
        NSLog(@"1");
        if (buttonIndex == 0)
        {
            // Yes, reset
            [self resetVisited];
            self.visited.text = [NSString stringWithFormat:@"%i", [self countVisited]];
        }
        else if (buttonIndex == 1)
        {
            //Cancel, dismiss
        }
    }
    //sign in
    else if(alertView.tag == 2)
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
//#if defined(FREE)
//        else if (buttonIndex == 1)
//        {
//            //Cancel, dismis
//        }
//#endif /* FREE */
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"sign_in"])
    {
        //SignInViewController *destViewController = segue.destinationViewController;
    }
}

- (void) resetVisited
{
    PlistHelper * plist = [PlistHelper alloc];
    [plist resetIvisited];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self checkFirstAppOpen];
    
    //check signed in
    PlistHelper * plist = [PlistHelper alloc];
    
    //update #visits text
    self.visited.text = [NSString stringWithFormat:@"%i", [self countVisited]];

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
}



@end
