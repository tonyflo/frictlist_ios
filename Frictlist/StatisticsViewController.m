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
@property (strong, nonatomic) IBOutlet UIButton *syncBtn;
@property (strong, nonatomic) IBOutlet UIButton *ivisitedLink;


@end

@implementation StatisticsViewController

//bad globals
static int uid = -1; //uid (pk) of an user that's not signed in
UIAlertView *alertView;
NSString * address = @"http://ivisited.flooreeda.com/scripts/";
NSString *syncdatetime;

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
    //[[self.tabBarController.tabBar.items objectAtIndex:2] setTitle:@"Map"];
    
    //tab bar icons
    [[self.tabBarController.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"list_icon.png"]];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"gear_icon.png"]];
    //[[self.tabBarController.tabBar.items objectAtIndex:2] setImage:[UIImage imageNamed:@"map_icon.png"]];
}

-(void)checkFirstAppOpen
{
    //check first sign in
    PlistHelper *plist = [[PlistHelper alloc] initDefaults];
    int first = [plist getFirst];
#if !defined(FREE)
    if([plist getPk] == -1)
    {
        first = 1;
    }
#endif /* PAID */
    
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
    //sign out for a free user only
    //else
    //{
    //    //signed in, now sign out
    //    [self showSignOutConfirmationDialog];
    //}
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
    [plist resetLastSyncDateTime];
    [plist resetPk];
    
    uid = [plist getPk];
    
    if(uid <= 0)
    {
        //now signed out
        [signinBtn setTitle:@"Sign In" forState:UIControlStateNormal];
        
        //set email label back
        [emailLabel setText:[plist getEmail]];
        
        //set sync label back
        [syncLabel setText:[NSString stringWithFormat:@"Last Sync: %@", [plist getLastSyncDateTime]]];
        
        //disable sync button
        self.syncBtn.enabled = false;
        self.syncBtn.alpha = 0.4;
        
        //updated visited number
        self.visited.text = [NSString stringWithFormat:@"%d", [self countVisited]];
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

//sign out was failure
- (void)showSyncErrorDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Sync Unsuccessful"];
    [alert setMessage:@"Something went wrong when syncing your data. Please try again. Make sure you are connected to the internet. If the problem presists, please contact the developer."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//call sync script to update database entry
-(BOOL) sync
{
    //get ivisited data
    PlistHelper *plist = [PlistHelper alloc];
    NSString *ivisited = [plist getIvisited];
    
    BOOL rc = true;
    //1. Set post string with actual username and password.
    NSString *post = [NSString stringWithFormat:@"&uid=%d&ivisited=%@&datetime=%@",uid, ivisited, syncdatetime];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@sync.php", address]]];
    
    //Now, set HTTP method (POST or GET). Write this lines as it is in your code
    [request setHTTPMethod:@"POST"];
    
    //Set HTTP header field with length of the post data.
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    //Also set the Encoded value for HTTP header Field.
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    
    //Set the HTTPBody of the urlrequest with postData.
    [request setHTTPBody:postData];
    
    //4. Now, create URLConnection object. Initialize it with the URLRequest.
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    //It returns the initialized url connection and begins to load the data for the url request. You can check that whether you URL connection is done properly or not using just if/else statement as below.
    if(conn)
    {
        NSLog(@"Connection Successful");
    }
    else
    {
        NSLog(@"Connection could not be made");
        rc = false;
    }
    
    //5. To receive the data from the HTTP request , you can use the delegate methods provided by the URLConnection Class Reference. Delegate methods are as below
    return rc;
}

//Below method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)rsp  
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"Did receive data");
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:rsp encoding:NSUTF8StringEncoding];
    NSInteger intResult = [strResult integerValue];
    NSLog(@"int result %d", intResult);
    //Assuming that a user can only sync if signed in, compare the known uid to the pk that's returned... if that's true, sync was successful
    if(intResult == uid)
    {
        //update plist sync value
        PlistHelper *plist = [PlistHelper alloc];
        [plist setLastSyncDateTime:syncdatetime];
        
        //success syncing data
        syncLabel.text = [NSString stringWithFormat:@"Last Sync: %@", syncdatetime];
    }
    //error code was returned
    else
    {
        if(intResult == -3)
        {
            //error syncing data
            [self showSyncErrorDialog];
        }
        else
        {
            //unknown error
            [self showUnknownSyncFailureDialog];
        }
    }
    self.syncBtn.enabled = true;
}

//This method , you can use to receive the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"Did fail with error");
    NSLog(@"%@", error);
    self.syncBtn.enabled = true;
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error"];
    [alert setMessage:[error localizedDescription]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.syncBtn.enabled = true;
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"Did finish loading");
}

-(void)showLoadingDataDialog
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Syncing iVisited Data"
                                           message:@"\n"
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [alertView addSubview:spinner];
    [spinner startAnimating];
    [alertView show];
}

//if sync connection was not successful
- (void)showUnknownSyncFailureDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Something Went Wrong"];
    [alert setMessage:[NSString stringWithFormat:@"Sorry about this. Things to try:\n %C Check your internet connection\n %C Check your credentials\nIf the problem persists, email the developer.", (unichar) 0x2022, (unichar) 0x2022]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
    
    NSArray *subViewArray = alert.subviews;
    for(int x = 0; x < [subViewArray count]; x++){
        
        //If the current subview is a UILabel...
        if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]]) {
            UILabel *label = [subViewArray objectAtIndex:x];
            label.textAlignment = NSTextAlignmentLeft;
        }
    }
}

//sync
-(IBAction)syncButtonPress
{
    self.syncBtn.enabled = false;
    if(uid > 0)
    {
        //loading indicator
        [self showLoadingDataDialog];
        
        //get date time
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        syncdatetime = [DateFormatter stringFromDate:[NSDate date]];
        
        int rc = [self sync];
        if(!rc)
        {
            //something went wrong with the sync
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self showUnknownSyncFailureDialog];
        }
    }
    else
    {
        self.syncBtn.enabled = true;
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        
        //this shouldn't execute because the sync button is diabled until the user signs in
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Please Sign In First"];
        [alert setMessage:@"You must be signed in to sync your data."];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"Sign In"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setTag:2];
        [alert show];
    }
}

-(IBAction)emailButtonPress
{
#if defined(FREE)
    NSString *recipients = @"mailto:tony@flooreeda.com?subject=Frictlist Free iOS App";
#else
    NSString *recipients = @"mailto:tony@flooreeda.com?subject=Frictlist iOS App";
#endif
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

#ifdef NOT_IMPLEMENTED
- (void)showUpgradeDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Feature Not Available"];
    [alert setMessage:@"The ability to sync your data to this only available in the paid version"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Buy Now"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setTag:3];
    [alert show];
}
#endif

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
    //sync
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
        NSString * sync_text = [plist getLastSyncDateTime];
        [signinBtn setTitle:@"Sign Out" forState:UIControlStateNormal];
        [syncLabel setText: [NSString stringWithFormat:@"Last Sync: %@", sync_text]];
        [emailLabel setText:[NSString stringWithFormat:@"%@", email_text]];

        //enable sync button
        self.syncBtn.enabled = true;
        self.syncBtn.alpha = 1.0;
#if !defined(FREE)
        //disable signin button
        signinBtn.enabled = false;
        signinBtn.alpha = 0.4;
        //self.syncBtn.hidden = true;
#endif /* PAID */
    }
    else
    {
        [emailLabel setText:[plist getEmail]];
        //disable sync button
        self.syncBtn.enabled = false;
        self.syncBtn.alpha = 0.4;
    }
}



@end
