//
//  FrictDetailViewController.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "FrictDetailViewController.h"
#import "PlistHelper.h"

@interface FrictDetailViewController ()

@end

@implementation FrictDetailViewController

@synthesize visitedSegmentedControl;
@synthesize hu_id;

//bad globals
UIAlertView * alertView;
NSString * frict_url = @"http://frictlist.flooreeda.com/scripts/";
int maxStringLen = 255;
int minAge = 14;
int row = 0; //local index of frict (the row of the frict)

NSString *firstName;
NSString *lastName;
int gender;
int base;
NSString * fromDate;
NSString * toDate;
NSString * notesStr;

-(void)viewWillAppear:(BOOL)animated
{
    //check if this is an existing hookup
    //this mean that we have to display the data for edit
    if(self.hu_id > 0)
    {
        PlistHelper *plist = [PlistHelper alloc];
        NSMutableArray * huidArray = [plist getHuIdArray];
        NSMutableArray * fnArray = [plist getFirstNameArray];
        NSMutableArray * lnArray = [plist getLastNameArray];
        NSMutableArray * genderArray = [plist getGenderArray];
        NSMutableArray * baseArray = [plist getBaseArray];
        NSMutableArray * fromArray = [plist getFromArray];
        NSMutableArray * toArray = [plist getToArray];
        NSMutableArray * notesArray = [plist getNoteArray];
        
        //get local index of hu_id
        for(int i = 0; i < huidArray.count; i++)
        {
            if(self.hu_id == [[huidArray objectAtIndex:i] intValue])
                {
                    row = i;
                    break;
                }
        }
    
        NSLog(@"local index of %d is %d", self.hu_id, index);
        
        firstName = fnArray[row];
        NSLog(@"%@", firstName);
        lastName = lnArray[row];
        NSLog(@"%@", lastName);
        gender = [genderArray[row] intValue];
        NSLog(@"%d", gender);
        base = [baseArray[row] intValue];
        NSLog(@"%d", base);
        fromDate = fromArray[row];
        NSLog(@"%@", fromDate);
        toDate = toArray[row];
        NSLog(@"%@", toDate);
        notesStr = notesArray[row];
        NSLog(@"%@", notesStr);
        
        firstNameText.text = firstName;
        lastNameText.text = lastName;
        genderSwitch.selectedSegmentIndex = gender;
        baseSwitch.selectedSegmentIndex = base;
        [notes setText:notesStr];
        
        //dates
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * fromAsDate = [formatter dateFromString:fromDate];
        NSDate * toAsDate = [formatter dateFromString:toDate];
        [fromSwitch setDate:fromAsDate];
        if([toDate isEqual: @"0000-00-00"])
        {
            //current
            currentSwitch.selected = true;
            toSwitch.enabled = false;
            toSwitch.alpha = 0.5;
        }
        else
        {
            //ended in past
            [toSwitch setDate:toAsDate];
        }
        
        //set the title
        self.title = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
    }
    else
    {
        //set the title
        self.title = @"New Frict";
    }
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
    notes.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
}

-(void)goBack:(id)sender
{
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [scrollView setContentOffset:CGPointMake(0,textView.center.y) animated:YES];
}

// called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if(textField.tag == 1) {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
    } else if (nextResponder) {
        [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}

-(BOOL)textView:(UITextView *)textView  shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)savePressed:(id)sender
{
    BOOL rc = true;
    
    NSString * firstname = firstNameText.text;
    NSString * lastname = lastNameText.text;
    int gender = genderSwitch.selectedSegmentIndex;
    int base = baseSwitch.selectedSegmentIndex;
    NSDate * from = fromSwitch.date;
    NSDate * to = toSwitch.date;
    NSString * hu_notes = notes.text;
    
    //if current frict, set null
    if(currentSwitch.selected == 1)
    {
        to = NULL;
    }
    
    //validate user input
    if(firstname.length > maxStringLen)
    {
        rc = 0;
        [self showFieldTooLong:@"First Name"];
    } else if(lastname.length > maxStringLen) {
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
    else {
        //TODO
        //check date for:
        // to before for
        // from/to after now
        // from/to before bday
    }
    
    //format dates
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *fromFormatted = [formatter stringFromDate:from];
    NSString *toFormatted = [formatter stringFromDate:to];
    
    //get uid
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    if(uid < 0)
    {
        rc = 0;
    }
    
    //add the frict to the remote db
    if(rc)
    {
        [self showAddingFrictDialog];
        
        rc = [self save_frict:uid firstname:firstname lastname:lastname gender:gender base:base from:fromFormatted to:toFormatted notes:hu_notes];
        
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
-(BOOL) save_frict:(int) uid firstname:(NSString *) firstname lastname:(NSString *)lastname gender:(int)gender base:(int)base from:(NSString *)from to:(NSString *)to notes:(NSString *)hu_notes
{
    BOOL rc = true;

    NSString *post;
    
    if(self.hu_id > 0)
    {
        post = [NSString stringWithFormat:@"&uid=%d&frict_id=%d&firstname=%@&lastname=%@&gender=%d&base=%d&from=%@&to=%@&notes=%@",uid, hu_id, firstname, lastname, gender, base, from, to, hu_notes];
    }
    else
    {
        post = [NSString stringWithFormat:@"&uid=%d&firstname=%@&lastname=%@&gender=%d&base=%d&from=%@&to=%@&notes=%@",uid, firstname, lastname, gender, base, from, to, hu_notes];
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
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@update_frict.php", frict_url]]];
    }
    else
    {
        //this hookup is new hookup, insert it into the mysql db
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@add_frict.php", frict_url]]];
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

-(void)showAddingFrictDialog
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Adding Frict"
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
        
        //format dates
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *fromFormatted = [formatter stringFromDate:fromSwitch.date];
        NSString *toFormatted = [formatter stringFromDate:toSwitch.date];
        if(currentSwitch.selected == true)
        {
            toFormatted = @"0000-00-00";
        }
        
        PlistHelper *plist = [PlistHelper alloc];
        if(self.hu_id > 0)
        {
            //update the local database
            [plist updateFrict:intResult index:row first:firstNameText.text last:lastNameText.text base:baseSwitch.selectedSegmentIndex accepted:0 from:fromFormatted to:toFormatted notes:notes.text gender:genderSwitch.selectedSegmentIndex];
        }
        else
        {
            //insert the data that has already been inserted on the remote database into the plist
            [plist addFrict:intResult first:firstNameText.text last:lastNameText.text base:baseSwitch.selectedSegmentIndex accepted:0 from:fromFormatted to:toFormatted notes:notes.text gender:genderSwitch.selectedSegmentIndex];
        }
        
        //TODO get this to go back to another view
        //alert that it was successful then
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    //error code was returned
    else
    {
            //TODO handle errors
            if(intResult == -20)
            {
                //null data
                //[self showEmailNotFoundDialog];
            }
            else if(intResult == -21)
            {
                //uid not found
                //[self showWrongPasswordDialog];
            }
            else if(intResult == -22)
            {
                //error adding to hookup table
                //[self showWrongPasswordDialog];
            }
            else if(intResult == -23)
            {
                //error adding to frict table
                //[self showWrongPasswordDialog];
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
    [alert setMessage:[NSString stringWithFormat:@"The %@ that you entered is too long. The max is %d characters.", fieldName, maxStringLen]];
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

- (IBAction)checkboxButton:(id)sender{
    currentSwitch.selected = !currentSwitch.selected;
    
    if(currentSwitch.selected == 1)
    {
        //enable to picker
        toSwitch.enabled = false;
        toSwitch.alpha = 0.5;
    }
    else
    {
        //disable to picker
        toSwitch.enabled = true;
        toSwitch.alpha = 1;
    }
}


@end
