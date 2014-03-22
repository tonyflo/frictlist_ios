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
    
    //set the title
    self.title = [NSString stringWithFormat:@"%d", hu_id];
}

//change visited boolean value via the segmented control
- (IBAction)changeVisited
{
//    BOOL visited;
//    if(visitedSegmentedControl.selectedSegmentIndex == 0)
//    {
//        visited = 0;
//    }
//    else
//    {
//        visited = 1;
//    }
//    
//    PlistHelper * plist = [PlistHelper alloc];
//    NSString * updated_visited = [[plist getIvisited] stringByReplacingCharactersInRange:NSMakeRange(state.primaryKey, 1) withString:[NSString stringWithFormat:@"%d",visited]];
//    [plist setIvisited:updated_visited];
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
    
    //TODO validate user input
    
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
        
        rc = [self save_frict:uid firstname:firstname lastname:lastname gender:gender base:base from:from to:to notes:hu_notes];
    }
    
    //take action if something went wrong
    if(!rc)
    {
        //something went wrong with the signin
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self showUnknownFailureDialog];
    }

}

//save frict data
-(BOOL) save_frict:(int) uid firstname:(NSString *) firstname lastname:(NSString *)lastname gender:(int)gender base:(int)base from:(NSDate *)from to:(NSDate *)to notes:(NSString *)hu_notes
{
    BOOL rc = true;

    //1. Set post string with actual username and password.
    NSString *post = [NSString stringWithFormat:@"&uid=%d&firstname=%@&lastname=%@&gender=%d&base=%d&from=%@&to=%@&notes=%@",uid, firstname, lastname, gender, base, [from description], [to description], hu_notes];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@add_frict.php", frict_url]]];
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
        //todo: presist data locally
        
        //write the pk to the plist
        //To insert the data into the plist
        PlistHelper *plist = [PlistHelper alloc];
        [plist addFrict:intResult first:firstNameText.text last:lastNameText.text];
        
        //alert that it was successful then
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
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
