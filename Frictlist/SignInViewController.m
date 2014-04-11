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
#import "SqlHelper.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize signinButton, bakcButton;

//bad globals
UIAlertView * alertView;
int minPwLen = 6;
int maxPwLen = 255;
int maxEmailLen = 35;
int ageLimit = 14;
int maxUnLen = 20;
NSString * url = @"http://frictlist.flooreeda.com/scripts/";

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
    checkboxSelected = 0;
    self.view.userInteractionEnabled = TRUE;
    
    lastNameText.delegate = self;
    firstNameText.delegate = self;
    passwordText.delegate = self;
    emailText.delegate = self;
    usernameText.delegate = self;
    
    self.navigationItem.title = @"Sign Up";
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

// called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextTag == 6) {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
        
    } else {
        [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    }
    
    if(checkboxButton.selected == 0)
    {
        [textField resignFirstResponder];
        [scrollView setContentOffset:CGPointMake(0,scrollView.contentSize.height - scrollView.bounds.size.height) animated:YES];
        return YES;
    }
    
    return NO;
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
        self.navigationItem.title = @"Sign Up";
        //enable new account fields
        firstNameText.enabled = true;
        lastNameText.enabled = true;
        genderSwitch.enabled = true;
        birthdatePicker.enabled = true;
        emailText.enabled = true;
        firstNameText.alpha = 1;
        lastNameText.alpha = 1;
        genderSwitch.alpha = 1;
        birthdatePicker.alpha = 1;
        birthdateLabel.alpha = 1;
        newAccountLabel.alpha = 1;
        emailText.alpha = 1;
    }
    else
    {
        [signinButton setTitle:@"Sign In" forState:UIControlStateNormal];
        self.navigationItem.title = @"Sign In";
        //disable new account fields
        firstNameText.enabled = false;
        lastNameText.enabled = false;
        genderSwitch.enabled = false;
        birthdatePicker.enabled = false;
        emailText.enabled = false;
        firstNameText.alpha = 0.5;
        lastNameText.alpha = 0.5;
        genderSwitch.alpha = 0.5;
        birthdatePicker.alpha = 0.5;
        birthdateLabel.alpha = 0.5;
        newAccountLabel.alpha = 0.5;
        emailText.alpha = 0.5;
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
    NSString * username = usernameText.text;
    NSString * email = emailText.text;
    NSString * password = passwordText.text;
    NSString * firstName = firstNameText.text;
    NSString * lastName = lastNameText.text;
    BOOL gender = genderSwitch.selectedSegmentIndex;
    NSDate *birthdate = birthdatePicker.date;
    
    bool rc = 1;
    
    //check valid password
    if(password.length < minPwLen || password.length > maxPwLen)
    {
        rc = 0;
        [self showInvalidPasswordDialog];
    }
    //check username too long
    else if(username.length < minPwLen || username.length > maxUnLen)
    {
        rc = 0;
        [self showInvalidUsernameDialog];
    }
    
    
    //if making a new account, check for valid name, birthdate fields
    if(rc && checkboxButton.selected == 1)
    {
        //check valid email
        rc = [self NSStringIsValidEmail:email];
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

        if(rc)
        {
            if(firstName.length > maxPwLen)
            {
                rc = 0;
                [self showFieldTooLong:@"First Name"];
            } else if(lastName.length > maxPwLen) {
                rc = 0;
                [self showFieldTooLong:@"Last Name"];
            } else if(firstName.length == 0)
            {
                rc = 0;
                [self showFieldTooShort:@"First Name"];
            } else if(lastName.length == 0) {
                rc = 0;
                [self showFieldTooShort:@"Last Name"];
            }
            else {
                int yearsold = [self checkAgeLimit:birthdate];
                if(yearsold < ageLimit)
                {
                    rc = 0;
                    [self showTooYoung:yearsold];
                }
            }
        }
    }
    
    if(rc)
    {
        [self showSigningInSpinnerDialog];
        
        if(checkboxButton.selected == 1)
        {
            rc = [self signUp:email username:username password:password firstName:firstName lastName:lastName gender:gender birthdate:birthdate];
        }
        else
        {
            //sign in
            rc = [self signIn:username password:password];
        }        
        
        if(!rc)
        {
            //something went wrong with the signin
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self showUnknownFailureDialog];
        }
    }
}

//sign in logic
-(BOOL) signIn:(NSString *) username password:(NSString *)password
{
    BOOL rc = true;

    //1. Set post string with actual username and password.
    NSString *post = [NSString stringWithFormat:@"&username=%@&password=%@",username,password];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@signin.php", url]]];
    NSLog(@"Sign in");
    
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

//sign in logic
-(BOOL) signUp:(NSString *) email username:username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName gender:(BOOL)gender birthdate:(NSDate *)birthdate
{
    BOOL rc = true;

    //1. Set post string with actual username and password.
    NSString *post = [NSString stringWithFormat:@"&firstname=%@&lastname=%@&email=%@&username=%@&password=%@&gender=%d&birthdate=%@",firstName, lastName, email, username, password, gender, [birthdate description]];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@signup.php", url]]];
    NSLog(@"Sign up");

    
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

//get frictlist
-(BOOL) get_frictlist:(int) uid
{
    BOOL rc = true;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d",uid];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_frictlist.php", url]]];
  
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

//get notifications
-(BOOL) get_notifications:(int) uid
{
    BOOL rc = true;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d",uid];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_notifications.php", url]]];
    
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

//check old enough
-(int) checkAgeLimit:(NSDate *)bday
{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger units = NSYearCalendarUnit;
    NSDateComponents *components = [gregorian components:units fromDate:bday toDate:now options:0];
    NSUInteger years = [components year];
    
    return years;
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
    [alert setTitle:@"Email Address Way Too Long"];
    [alert setMessage:[NSString stringWithFormat:@"I don't believe that that is your email address. Keep email addresses under %d characters. Please use another email address.", maxEmailLen]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//the field is too long
-(void) showFieldTooLong:(NSString *)fieldName
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"%@ Way To Long", fieldName]];
    [alert setMessage:[NSString stringWithFormat:@"Is your %@ really that long? The max is %d characters. Try again.", fieldName, maxEmailLen]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//the field is null
-(void) showFieldTooShort:(NSString *)fieldName
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"I'm Goning To Need Your %@", fieldName]];
    [alert setMessage:[NSString stringWithFormat:@"Please enter a %@.", fieldName]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//if sign is connection was not successful
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

//if user enters an invalid email, show this dialog
- (void)showInvalidEmailDialog:(NSString *)email
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Real Email Please"];
    [alert setMessage:[NSString stringWithFormat:@"The email address you entered (%@) is not a valid email. Please try again.", email]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//user is too young
- (void)showTooYoung:(int)yearsold
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Sorry, You're Not Old Enough"];
    [alert setMessage:[NSString stringWithFormat:@"Please come back when you're %d or older.", ageLimit]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//if user enters a password that is too short/long, show this dialog
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

//if user enters a username that is too short/long, show this dialog
- (void)showInvalidUsernameDialog
{
    NSString *title;
    NSString *message;
    if(usernameText.text.length < minPwLen)
    {
        title = @"Username Too Short";
        message = [NSString stringWithFormat:@"Your username must be at least %d characters.", minPwLen];
    }
    else
    {
        title = @"Username Too Long";
        message = [NSString stringWithFormat:@"Your username may be no more than %d characters.", maxUnLen];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    [alert setMessage:message];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//user entered wrong credentials
- (void)showUsernameNotFoundDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"I Don't Recognize That Username"];
    [alert setMessage:@"An unknown username was entered. Please try again."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//user entered wrong credentials
- (void)showWrongPasswordDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Wrong!"];
    [alert setMessage:@"The password that was entered is incorrect. Please try again."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//unknown sign up failure
- (void)showSignupFailureDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Whoops!"];
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

//email address not available
- (void)showUsernameNotAvailableDialog:username
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Username In Use"];
    [alert setMessage:[NSString stringWithFormat:@" The username %@ is not available to use. Please try a different username.", username]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
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
    NSArray *query_result = [strResult componentsSeparatedByString:@"\n"];
    NSString *searchFlag = query_result[0];
    SqlHelper *sql = [SqlHelper alloc];
    
    if([searchFlag isEqual:@"frictlist"])
    {
        //we have received the frictlist because the user has just signed in. now loop over it and save it to the sqlite db
        
        //store the mate_ids to avoid adding the same mate more than once
        NSMutableArray *mateIds = [[NSMutableArray alloc] init];
        
        //for each row in the frictlist table
        //start at 2 to skip over frictlist line and user data array
        for(int i = 2; i < query_result.count - 1; i++)
        {
            //split the row into columns
            NSArray *frict = [query_result[i] componentsSeparatedByString:@"\t"];
            NSLog(@"Frict count = %d", frict.count);
            if(frict.count == 16)
            {
                //check if mate has already been added to sqlite
                if(![mateIds containsObject:frict[0]])
                {
                    NSLog(@"New mate %@", frict[0]);
                    [sql add_mate:[frict[0] intValue] fn:frict[3] ln:frict[4] gender:[frict[5] intValue] accepted:[frict[1] intValue] mates_uid:[frict[2] intValue]];
                    [mateIds addObject:frict[0]];
                }
                
                //check for frict data
                if(frict[6] != NULL && frict[6] != nil && ![frict[6] isEqual:@""] && [frict[11] intValue] != 1)
                {
                    NSLog(@"FOUND FRICT DATA");
                    [sql add_frict:[frict[6] intValue] mate_id:[frict[0] intValue] from:frict[7] rating:[frict[8] intValue] base:[frict[9] intValue] notes:frict[10] mate_rating:[frict[12] intValue] mate_notes:frict[13] mate_deleted:[frict[14] intValue] creator:[frict[15] intValue] deleted:[frict[11] intValue]];
                }
            }
            else
            {
                //number of columns in frictlist is not correct
                [self showErrorCodeDialog:-402];
                break;
            }
        }
        
        //get user data
        NSArray *user_data = [query_result[1] componentsSeparatedByString:@"\t"];
        PlistHelper *plist = [PlistHelper alloc];
        
        //set users birthday
        NSString *bdayStr = user_data[2];
        [plist setBirthday:bdayStr];
        NSLog(@"user fn: %@ ln: %@ bday: %@", user_data[0], user_data[1], bdayStr);
        
        //set user's first and last name
        [plist setFirstName:user_data[0]];
        [plist setLastName:user_data[1]];
        
        //now, get notifications
        [self get_notifications:[plist getPk]];
    }
    //notifications
    else if([searchFlag isEqual:@"notifications"])
    {
        //we have received the notification list because the user has just signed in. now loop over it and save it to the sqlite db
        
        NSMutableArray *incommingRequestIdArray = [[NSMutableArray alloc] init];
        NSMutableArray *acceptedRequestIdArray = [[NSMutableArray alloc] init];
        NSMutableArray *rejectedRequestIdArray = [[NSMutableArray alloc] init];
        
        //for each row in the notification table
        //start at 1 to skip over notification flag line
        for(int i = 1; i < query_result.count - 1; i++)
        {
            //split the row into columns
            NSArray *notification = [query_result[i] componentsSeparatedByString:@"\t"];
            
            if(notification.count == 18)
            {
                int status = [notification[2] intValue];
                //pending
                if(status == 0)
                {
                    //check if pending mate has already been added to sqlite
                    if(![incommingRequestIdArray containsObject:notification[0]])
                    {
                        NSLog(@"heres a pending: %@", notification[3]);
                        //this is a new or untouched notification that hasn't been accepted or rejected
                        [sql add_notification:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7]];
                        [incommingRequestIdArray addObject:notification[0]];
                    }
                }
                //accepted
                else if(status == 1)
                {
                    //check if accepted mate has already been added to sqlite
                    if(![acceptedRequestIdArray containsObject:notification[0]])
                    {
                        NSLog(@"heres a new accepted: %@", notification[3]);
                        //this is an incomming request that has already been accepted
                        [sql add_accepted:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7]];
                        [acceptedRequestIdArray addObject:notification[0]];
                    }
                    
                    //check for frict data. make sure frict_id is not null and that the recipient hasn't already deleted this frict
                    if(notification[8] != NULL && notification[8] != nil && ![notification[8] isEqual:@""] && [notification[16] intValue] != 1)
                    {
                        NSLog(@"FOUND FRICT DATA");
                        [sql add_frict:[notification[8] intValue] mate_id:[notification[1] intValue] from:notification[9] rating:[notification[10] intValue] base:[notification[11] intValue] notes:notification[12] mate_rating:[notification[14] intValue] mate_notes:notification[15] mate_deleted:[notification[16] intValue] creator:[notification[17] intValue] deleted:[notification[13] intValue]];
                    }
                }
                //rejected
                else if(status == -1)
                {
                    //check if pending mate has already been added to sqlite
                    if(![rejectedRequestIdArray containsObject:notification[0]])
                    {
                        NSLog(@"heres a rejected: %@", notification[3]);
                        //this is an incomming request that has already been accepted
                        [sql add_rejected:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7]];
                        [rejectedRequestIdArray addObject:notification[0]];
                    }
                }
                else
                {
                    //status is not -1, 0, or 1
                    [self showErrorCodeDialog:-400];
                    break;
                }
                
            }
            else
            {
                //number of columns in notification is not correct
                [self showErrorCodeDialog:-401];
                break;
            }
        }
        
        //get outa here
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //sign in success because we got the uid
    else if(intResult > 0)
    {
        //To insert username and pk into the plist
        PlistHelper *plist = [PlistHelper alloc];
        [plist setPk:intResult];
        [plist setEmail:usernameText.text];
        
        //now, get the frictlist
        if(checkboxButton.selected == 0)
        {
            //get the frictlist because this is not a new account
            [self get_frictlist:intResult];
        }
        else
        {
            //capture the input data into the local plist
            [plist setFirstName:firstNameText.text];
            [plist setLastName:lastNameText.text];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString * bday = [formatter stringFromDate:birthdatePicker.date];
            [plist setBirthday:bday];
        }
        
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //error code was returned
    else
    {
            //sign in errors below until sign up errors
            if(intResult == -1)
            {
                //username was not found
                [self showUsernameNotFoundDialog];
            }
            else if(intResult == -2)
            {
                //password was wrong
                [self showWrongPasswordDialog];
            }
            //sign up errors below
            else if(intResult == -4)
            {
                //email address not available
                [self showEmailNotAvailableDialog:emailText.text];
            }
            else if(intResult == -5)
            {
                //username not available
                [self showUsernameNotAvailableDialog:usernameText.text];
            }
            else if(intResult == -7)
            {
                //insert into db was not successful
                [self showSignupFailureDialog];
            }
            else if(intResult == -10)
            {
                //insert into db was not successful
                [self showErrorCodeDialog:intResult];
            }
            else
            {
                //unknown error code returned from server
                [self showErrorCodeDialog:-403];
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

- (IBAction)backButonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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


@end
