//
//  FrictDetailViewController.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "FrictDetailViewController.h"
#import "FrictViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"

@interface FrictDetailViewController ()

@end

@implementation FrictDetailViewController

@synthesize frict_id;


//bad globals
UIAlertView * alertView;
NSString * frict_url = @"http://frictlist.flooreeda.com/scripts/";
int maxStringLen = 255;
int minAge = 14;
int row = 0; //local index of mate
int col = 0; //local index of frict

int base;
NSString * fromDate;
NSString * toDate;
NSString * notesStr;

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear frict detail");
    //check if this is an existing hookup
    //this mean that we have to display the data for edit
    if(self.frict_id > 0)
    {
        SqlHelper *sql = [SqlHelper alloc];
        NSArray *frict = [sql get_frict:self.frict_id];
        
        NSLog(@"single frict : %@", frict);
        
        fromDate = frict[0];
        toDate = frict[1];
        base = [frict[2] intValue];
        notesStr = frict[3];
        
        baseSwitch.selectedSegmentIndex = base;
        [notes setText:notesStr];
        NSLog(@"yooo");
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
        NSLog(@"dne in here");
        
        //todo: proally wana show name of mate
        //set the title
        //self.title = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
    }
    else
    {
        //set the title
        self.title = @"New Frict";
    }
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
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
    
    notes.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
    
    //enable tabbaar items
    [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:FALSE];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:FALSE];
}

-(void)goBack:(id)sender
{
    //enable tabbaar items
    [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:TRUE];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:TRUE];
    
    if(frict_id >0)
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
    
    int base = baseSwitch.selectedSegmentIndex;
    NSDate * from = fromSwitch.date;
    NSDate * to = toSwitch.date;
    NSString * hu_notes = notes.text;
    
    //if current frict, set null
    if(currentSwitch.selected == 1)
    {
        to = NULL;
    }
    

        //get the birthday of the user from the plist then format it into a string
        PlistHelper *plist = [PlistHelper alloc];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* bday = [formatter dateFromString:[plist getBirthday]];
        //get now date
        NSDate* now = [NSDate date];
        
        //validate input dates
        if([to compare:from] == NSOrderedAscending)
        {
            //to before from
            rc = 0;
            [self showToBeforeFromDialog];
        }
        else if([to compare:now] == NSOrderedDescending ||
                [from compare:now] == NSOrderedDescending)
        {
            //to after now
            rc = 0;
            [self showDateAfterNowDialog];
        }
        else if([to compare:bday] == NSOrderedAscending ||
                [from compare:bday] == NSOrderedAscending)
        {
            // from/to before bday
            rc = 0;
            [self showDateBeforeBdayDialog];
        }
    
    NSString *fromFormatted = [formatter stringFromDate:from];
    NSString *toFormatted = [formatter stringFromDate:to];
    
    //get uid
    int uid = [plist getPk];
    if(rc && uid < 0)
    {
        rc = 0;
    }
    
    //add the frict to the remote db
    if(rc)
    {
        //TODO, could distinguish between add and update
        [self showAddingFrictDialog];
        //TODO
        rc = [self save_frict:base from:fromFormatted to:toFormatted notes:hu_notes];
        
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
-(BOOL) save_frict:(int)base from:(NSString *)from to:(NSString *)to notes:(NSString *)hu_notes
{
    BOOL rc = true;

    NSString *post;
    
    if(self.frict_id > 0)
    {
        //update
        post = [NSString stringWithFormat:@"&frict_id=%d&mate_id=%d&base=%d&from=%@&to=%@&notes=%@",self.frict_id, self.mate_id, base, from, to, hu_notes];
    }
    else
    {
        //add
        post = [NSString stringWithFormat:@"&mate_id=%d&base=%d&from=%@&to=%@&notes=%@",self.mate_id, base, from, to, hu_notes];
    }
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    if(self.frict_id > 0)
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

- (void)showDateAfterNowDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Date Error"];
    [alert setMessage:@"One or more of the dates occur after now.  Please fix this before continuing."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

- (void)showDateBeforeBdayDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Date Error"];
    [alert setMessage:@"Whoops! You cannot input a date that occured before your birthdate.  Please fix this before continuing."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

- (void)showToBeforeFromDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Date Error"];
    [alert setMessage:@"The 'To' date cannot occur before the 'From' date."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
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
        
        //format dates
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *fromFormatted = [formatter stringFromDate:fromSwitch.date];
        NSString *toFormatted = [formatter stringFromDate:toSwitch.date];
        if(currentSwitch.selected == true)
        {
            toFormatted = @"0000-00-00";
        }
        
        SqlHelper * sql = [SqlHelper alloc];
        
        //PlistHelper *plist = [PlistHelper alloc];
        if(self.frict_id > 0)
        {
            //todo
            //update the local database
            //[plist updateFrict:intResult index:row first:firstNameText.text last:lastNameText.text base:baseSwitch.selectedSegmentIndex accepted:0 from:fromFormatted to:toFormatted notes:notes.text gender:genderSwitch.selectedSegmentIndex];
            [sql update_frict:intResult from:fromFormatted to:toFormatted base:baseSwitch.selectedSegmentIndex notes:notes.text];
        }
        else
        {
            NSLog(@"adding frict");
            //insert the data that has already been inserted on the remote database into the plist
            //[plist addFrict:intResult huid:self.mate_id base:baseSwitch.selectedSegmentIndex accepted:0 from:fromFormatted to:toFormatted notes:notes.text];
            [sql add_frict:intResult mate_id:self.mate_id from:fromFormatted to:toFormatted base:baseSwitch.selectedSegmentIndex notes:notes.text];
            NSLog(@"%@", [sql get_frict_list:intResult]);
            NSLog(@"added frict");
        }
        
        //enable tabbaar items
        [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:TRUE];
        [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:TRUE];
        
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    //error code was returned
    else
    {
        if(intResult == -20 ||
           intResult == -21 ||
           intResult == -22 ||
           intResult == -23 ||
           intResult == -30 ||
           intResult == -31 ||
           intResult == -32 ||
           intResult == -33 ||
           intResult == -34 ||
           intResult == -35)
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
        oneNightStandCheck.enabled = false;
    }
    else
    {
        //disable to picker
        toSwitch.enabled = true;
        toSwitch.alpha = 1;
        oneNightStandCheck.enabled = true;
    }
}

- (IBAction)oneNightStandCheckboxButton:(id)sender
{
    oneNightStandCheck.selected = !oneNightStandCheck.selected;
    
    if(oneNightStandCheck.selected == 1)
    {
        //enable to picker
        toSwitch.enabled = false;
        toSwitch.alpha = 0.5;
        toSwitch.date = fromSwitch.date;
        currentSwitch.enabled = false;
    }
    else
    {
        //disable to picker
        toSwitch.enabled = true;
        toSwitch.alpha = 1;
        currentSwitch.enabled = true;
    }
}


@end
