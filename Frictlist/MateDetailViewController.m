//
//  MateDetailViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "MateDetailViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"

@interface MateDetailViewController ()

@end

@implementation MateDetailViewController

@synthesize hu_id;


//bad globals
UIAlertView * alertView;
NSString * frict_url_str = @"http://frictlist.flooreeda.com/scripts/";
int maxStringLength = 255;
int row_num = 0; //local index of frict (the row of the frict)

NSString *firstName;
NSString *lastName;
int gender;

-(void)viewWillAppear:(BOOL)animated
{
    //check if this is an existing hookup
    //this mean that we have to display the data for edit
    if(self.hu_id > 0)
    {
        SqlHelper *sql = [SqlHelper alloc];
        NSArray * mate = [sql get_mate:self.hu_id];
        
        firstName = mate[0];
        NSLog(@"%@", firstName);
        lastName = mate[1];
        NSLog(@"%@", lastName);
        gender = [mate[2] intValue];
        NSLog(@"%d", gender);
        
        firstNameText.text = firstName;
        lastNameText.text = lastName;
        genderSwitch.selectedSegmentIndex = gender;
        
        //set the title
        self.title = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
    }
    else
    {
        //set the title
        self.title = @"New Mate";
    }
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
	// Do any additional setup after loading the view.
    
    firstNameText.delegate = self;
    lastNameText.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
    
    //to hide the keyboard when done is pressed
    lastNameText.delegate = self;
    
    //enable tabbaar items
    [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:FALSE];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:FALSE];
}

-(void)goBack:(id)sender
{
    //enable tabbaar items
    [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:TRUE];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:TRUE];
    
    if(hu_id >0)
    {
        //if frict exists, go to frict view
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //if frict doesn't exist, go back to frictlist view
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)savePressed:(id)sender
{
    BOOL rc = true;
    
    NSString * firstname = firstNameText.text;
    NSString * lastname = lastNameText.text;
    int gender = genderSwitch.selectedSegmentIndex;
    
    //validate user input
    if(firstname.length > maxStringLength)
    {
        rc = 0;
        [self showFieldTooLong:@"First Name"];
    } else if(lastname.length > maxStringLength) {
        rc = 0;
        [self showFieldTooLong:@"Last Name"];
    } else if(firstname.length == 0)
    {
        rc = 0;
        [self showFieldTooShort:@"First Name"];
    } else if(lastname.length == 0) {
        rc = 0;
        [self showFieldTooShort:@"Last Name"];
    }

    //get uid
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    if(rc && uid < 0)
    {
        rc = 0;
    }
    
    //add the mate to the remote db
    if(rc)
    {
        [self showAddingMateDialog];
        
        rc = [self save_mate:uid firstname:firstname lastname:lastname gender:gender];
        
        //take action if something went wrong
        if(!rc)
        {
            //something went wrong with the signin
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self showUnknownFailureDialog];
        }
    }
}

//save frict data
-(BOOL) save_mate:(int) uid firstname:(NSString *) firstname lastname:(NSString *)lastname gender:(int)gender
{
    BOOL rc = true;
    
    NSString *post;
    
    if(self.hu_id > 0)
    {
        //update
        post = [NSString stringWithFormat:@"&uid=%d&mate_id=%d&firstname=%@&lastname=%@&gender=%d",uid, hu_id, firstname, lastname, gender];
    }
    else
    {
        //add
         post = [NSString stringWithFormat:@"&uid=%d&firstname=%@&lastname=%@&gender=%d",uid, firstname, lastname, gender];
    }
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if(self.hu_id > 0)
    {
        //this hookup has already been written to the mysql db, updated it now
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@update_mate.php", frict_url_str]]];
    }
    else
    {
        //this hookup is new hookup, insert it into the mysql db
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@add_mate.php", frict_url_str]]];
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

-(void)showAddingMateDialog
{
    NSString *desc = @"Adding Mate";
    if(self.hu_id > 0)
    {
        desc = @"Updating Mate";
    }
    alertView = [[UIAlertView alloc] initWithTitle:desc
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

//Below method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)rsp
{
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:rsp encoding:NSUTF8StringEncoding];
    
    NSInteger intResult = [strResult integerValue];
    
    NSLog(@"Did receive data int: %d str %@ strlen %d", intResult, strResult, strResult.length);
    if(intResult > 0)
    {
        NSLog(@"Success");
        
        //PlistHelper *plist = [PlistHelper alloc];
        SqlHelper * sql = [SqlHelper alloc];
        if(self.hu_id > 0)
        {
            //todo
            //update the local database
            //[plist updateMate:intResult index:row_num first:firstNameText.text last:lastNameText.text gender:genderSwitch.selectedSegmentIndex];
            [sql update_mate:intResult fn:firstNameText.text ln:lastNameText.text gender:genderSwitch.selectedSegmentIndex];
        }
        else
        {
            //insert the data that has already been inserted on the remote database into the sqlite local db
            //[plist addMate:intResult first:firstNameText.text last:lastNameText.text gender:genderSwitch.selectedSegmentIndex]
            [sql add_mate:intResult fn:firstNameText.text ln:lastNameText.text gender:genderSwitch.selectedSegmentIndex];
        }

        
        //enable tabbaar items
        [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:TRUE];
        [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:TRUE];
        
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
        //[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -60 || //adding mate may have failed
           intResult == -70 || //updating mate may have failed
           intResult == -100 || //id was null or not positive
           intResult == -101) //id doesn't exist or isn't unique
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

//the field is too long
-(void) showFieldTooLong:(NSString *)fieldName
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"%@ Too Long", fieldName]];
    [alert setMessage:[NSString stringWithFormat:@"The %@ that you entered is too long. The max is %d characters.", fieldName, maxStringLength]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//the field is null
-(void) showFieldTooShort:(NSString *)fieldName
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"%@ Is Empty", fieldName]];
    [alert setMessage:[NSString stringWithFormat:@"Please enter a %@.", fieldName]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//generic error message. message string can be pased in
-(void) showGenericErrorDialog:(NSString *)title msg:(NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:title];
    [alert setMessage:message];
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
