//
//  SignInViewController.m
//  Frictlist
//
//  Created by Tony Flo on 1/2/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "SignInViewController.h"
#import "version.h"
#import "PlistHelper.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize signinButton, bakcButton;

//bad globals
UIAlertView * alertView;
int minPwLen = 6;
int maxPwLen = 255;
int maxEmailLen = 35;
NSString * url = @"http://ivisited.flooreeda.com/scripts/";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
#if !defined(FREE)
    self.navigationItem.leftBarButtonItem = nil;
#endif /* PAID */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    checkboxSelected = 0;
    
    self.navigationItem.title = @"Sign In";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkboxButton:(id)sender{
    checkboxButton.selected = !checkboxButton.selected;
    NSLog(@"%d", checkboxButton.selected);
    
    if(checkboxButton.selected == 1)
    {
        [signinButton setTitle:@"Create Account" forState:UIControlStateNormal];
    }
    else
    {
        [signinButton setTitle:@"Sign In" forState:UIControlStateNormal];

    }
}

-(void)showSigningInSpinnerDialog
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Signing In"
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

- (IBAction)signInButtonClick:(id)sender
{
    NSString * email = emailText.text;
    NSString * password = passwordText.text;
    
    //check valid email
    bool rc = [self NSStringIsValidEmail:email];
    if(!rc)
    {
        [self showInvalidEmailDialog:email];
    }
    
    //check email too long
    if(rc && email.length > maxEmailLen)
    {
        rc = 0;
        [self showEmailTooLongDialog];
    }
    
    //check valid password
    if(rc && (password.length < minPwLen || password.length > maxPwLen))
    {
        rc = 0;
        [self showInvalidPasswordDialog];
    }
    
    if(rc)
    {
        [self showSigningInSpinnerDialog];
        
        //sign in or sign up
        rc = [self signIn:email password:password];
        
        if(!rc)
        {
            //something went wrong with the signin
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self showUnknownFailureDialog];
        }
    }
}

//sign in logic
-(BOOL) signIn:(NSString *) email password:(NSString *)password
{
    BOOL rc = true;
//paid type is 1, free is 0
//this is a flag for the php script to make the account paid
#if defined(FREE)
    int type = 0;
#else
    int type = 1;
#endif
    //1. Set post string with actual username and password.
    NSString *post = [NSString stringWithFormat:@"&email=%@&password=%@&type=%d",email,password,type];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if(checkboxButton.selected == 0)
    {
        //Set the Url for which your going to send the data to that request.
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@signin.php", url]]];
        NSLog(@"Sign in");
    }
    else
    {
        //Set the Url for which your going to send the data to that request.
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@signup.php", url]]];
        NSLog(@"Sign up");
    }

    
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


//check valid email
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; 
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

//the email is too long
-(void) showEmailTooLongDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Email Too Long"];
    [alert setMessage:[NSString stringWithFormat:@"The email address that you entered is too long. Keep email addresses under %d characters. Please use another email address. If this presents a problem, contact the developer.", maxEmailLen]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//if sign is connection was not successful
- (void)showUnknownFailureDialog
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

//if user enters an invalid email, show this dialog
- (void)showInvalidEmailDialog:(NSString *)email
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Invalid Email"];
    [alert setMessage:[NSString stringWithFormat:@"The email address you entered (%@) is not a valid email. Please try again.", email]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//if user enters a password that is too short, show this dialog
- (void)showInvalidPasswordDialog
{
    NSString *title;
    NSString *message;
    if(passwordText.text.length < minPwLen)
    {
        title = @"Password Too Short";
        message = [NSString stringWithFormat:@"Your password must be at least %d characters.", minPwLen];
    }
    else
    {
        title = @"Password Too Long";
        message = [NSString stringWithFormat:@"Your password may be no more than %d characters.", maxPwLen];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//user entered wrong credentials
- (void)showEmailNotFoundDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Sign In Failed"];
    [alert setMessage:@"An unknown email address was entered. Please try again."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//user entered wrong credentials
- (void)showWrongPasswordDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Sign In Failed"];
    [alert setMessage:@"The password that was entered is incorrect. Please try again."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//unknown sign up failure
- (void)showSignupFailureDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Sign Up Failed"];
    [alert setMessage:@"Something went wrong when creating your account. Please try again. If the problem persists, contact the developer."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//email address not available
- (void)showEmailNotAvailableDialog:email
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Emaill Address In Use"];
    [alert setMessage:[NSString stringWithFormat:@" The email address %@ is not available to use. Please try a different email address.", email]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//show reverse sync error
- (void)showReverseSyncErrorDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Reverse Sync Warning"];
    [alert setMessage:@"There was a problem when syncing your iVisited data.  Would you like to try again or cancel?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Try Again"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setTag:1];
    [alert show];
}

//close keyboard when touch outside keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //hides keyboard when another part of layout was touched
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

//Below method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)rsp
{
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:rsp encoding:NSUTF8StringEncoding];
    
    NSInteger intResult = [strResult integerValue];
    
    NSLog(@"Did receive data int: %d str %@ strlen %d", intResult, strResult, strResult.length);
    if(false)
    {
        //no-op
    }
    //check if visited data has arrived
    else if(strResult.length == 50)
    {
        //write data to plist
        NSLog(@"reverse sync data: %@", strResult);
        PlistHelper * plist = [PlistHelper alloc];
        [plist setIvisited:strResult];
        
        //alert that it was successful then
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(intResult == -5)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //reverse sync error
        [self showReverseSyncErrorDialog];
    }
    else if(intResult > 0)
    {
        //write the pk to the plist
        //To insert the data into the plist
        PlistHelper *plist = [PlistHelper alloc];
        [plist setPk:intResult];
        [plist setEmail:emailText.text];
        //make request to sync visited data to phone
        NSLog(@"reverse sync");
        [self reverse_sync:intResult];
    }
    //error code was returned
    else
    {
        //sign in error
        if(checkboxButton.selected == 0)
        {
            if(intResult == -1)
            {
                //email address was not found
                [self showEmailNotFoundDialog];
            }
            else if(intResult == -2)
            {
                //password was wrong
                [self showWrongPasswordDialog];
            }
            else
            {
                //unknown error
                [self showUnknownFailureDialog];
            }
        }
        //sign up error
        else
        {
            if(intResult == -4)
            {
                //email address not available
                [self showEmailNotAvailableDialog:emailText.text];
            }
            else if(intResult == -7)
            {
                //insert into db was not successful
                [self showSignupFailureDialog];
            }
            else
            {
                //unknown error
                [self showUnknownFailureDialog];
            }
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

- (IBAction)flooreedaLinkClick:(id)sender
{
    NSString *ivisitedLink = @"http://ivisited.flooreeda.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ivisitedLink]];
}

#if defined(FREE)
- (IBAction)backButonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#endif

//revers sync logic. sync database visited data to phone
-(BOOL) reverse_sync:(int)pk
{
    BOOL rc = true;

    //1. Set post string with actual username and password.
    NSString *post = [NSString stringWithFormat:@"&uid=%d",pk];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@reverse_sync.php", url]]];
    NSLog(@"Reverse sync");
    
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

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

//take an action when a choice is made in an alert dialog
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //reset data
    if(alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            // Try Again, try to reverse sync again
            [self showSigningInSpinnerDialog];
            
            NSString * email = emailText.text;
            NSString * password = passwordText.text;
            
            //sign in or sign up
            int rc = [self signIn:email password:password];
            
            if(!rc)
            {
                //something went wrong with the signin
                [self showUnknownFailureDialog];
            }

        }
        else if (buttonIndex == 1)
        {
            //Cancel, dismiss
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
