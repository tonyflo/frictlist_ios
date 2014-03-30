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
NSString * address = @"http://frictlist.flooreeda.com/scripts/";

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

-(IBAction)checkNotificationsPress:(id)sender
{
    [self get_outgoing_status];
}

//get status of requests
-(BOOL) get_outgoing_status
{
    BOOL rc = true;
    
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d", uid];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    //search for mate
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_outgoing_status.php", address]]];
    
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

//something went wrong, but we have an error code to report
- (void)showErrorCodeDialog:(int)errorCode
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"Error Code %d", errorCode]];
    [alert setMessage:[NSString stringWithFormat:@"Sorry about this. Things to try:\n %C Check your internet connection\n %C Check your credentials\nIf the problem persists, email the developer and mention the %d error code.", (unichar) 0x2022, (unichar) 0x2022, errorCode]];
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

//unknown failure
- (void)showUnknownFailureDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Dagnabbit!"];
    [alert setMessage:[NSString stringWithFormat:@"Something went wrong. Sorry about this. Things to try:\n %C Check your internet connection\n %C Check your credentials\nIf the problem persists, email the developer.", (unichar) 0x2022, (unichar) 0x2022]];
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

//Below method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)rsp
{
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:rsp encoding:NSUTF8StringEncoding];
    
    NSInteger intResult = [strResult integerValue];
    
    NSLog(@"Did receive data int: %d str %@ strlen %d", intResult, strResult, strResult.length);
    NSArray *outgoing_status = [strResult componentsSeparatedByString:@"\n"];
    NSString *searchFlag = outgoing_status[0];
    NSMutableArray * notifications = [[NSMutableArray alloc] init];
    SqlHelper *sql = [SqlHelper alloc];
    NSArray * localStatus = [sql getOutgoingRequestStatus];
    //NSLog(@"compare sqlite3: %d mysql: %d", ((NSArray *)localStatus[0]).count, outgoing_status.count);
    NSLog(@"sqlite3: %@", localStatus);
    
    if([searchFlag isEqual:@"outgoing"])
    {
        //we have gotten data back from the server
        
        //for each row in the table
        //start at 1 to skip over flag row
        for(int i = 1; i < outgoing_status.count - 1; i++)
        {
            //split the row into columns
            NSArray *mateMysql = [outgoing_status[i] componentsSeparatedByString:@"\t"];
            
            //make sure array is proper length
            if(mateMysql.count == 3)
            {
                //todo
                //compare to and update data in sqlite db
                NSLog(@"%@\t%@\t%@", localStatus[0][i-1], localStatus[1][i-1], localStatus[2][i-1]);
                NSLog(@"%@\t%@\t%@", mateMysql[0], mateMysql[1], mateMysql[2]);
                NSLog(@"---");
            }
        }
        
        
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        //[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -100 || //id was null or not positive
           intResult == -101) //request insert wasn't successful
        {
            [self showErrorCodeDialog:intResult];
        }
        else
        {
            //unknown error
            [self showUnknownFailureDialog];
        }
        
    }
    NSLog(@"Result: %@", strResult);
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

//This method , you can use to receive the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"Did fail with error");
    NSLog(@"%@", error);
    
    //most likely a network error
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
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"Did finish loading");
}

@end
