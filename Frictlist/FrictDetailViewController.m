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
int MAX_LENGTH_NOTES = 1024;

int base;
NSString * fromDate;
int rating;
NSString * notesStr;

-(IBAction)valueChanged:(UISlider*)sender {
    int discreteValue = roundl([sender value]); // Rounds float to an integer
    [sender setValue:(float)discreteValue]; // Sets your slider to this value
    sliderText.text = [NSString stringWithFormat:@"%d", discreteValue ];
}

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
        rating = [frict[1] intValue];
        base = [frict[2] intValue];
        notesStr = frict[3];
        
        baseSwitch.selectedSegmentIndex = base;
        [notes setText:notesStr];
        
        //dates
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * fromAsDate = [formatter dateFromString:fromDate];
        [fromSwitch setDate:fromAsDate];
        
        //set the title
        self.title = @"Update Frict";
        
        //set the slider
        sliderText.text = [NSString stringWithFormat:@"%d", rating ];
        ratingSlider.value = rating;
        
        if(self.accepted == 1)
        {
            fromSwitch.enabled = false;
            fromSwitch.alpha = 0.5;
            baseSwitch.enabled = false;
            baseSwitch.alpha = 0.5;
        }
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
    
    if(self.frict_id > 0)
    {
        NSLog(@"back to frict detail");
        //go back back to frict detail
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"back to frictlist");
        //go back to frictlist
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
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
    
    int base = baseSwitch.selectedSegmentIndex;
    NSDate * from = fromSwitch.date;
    int ratingVal = ratingSlider.value;
    NSString * hu_notes = notes.text;

    //todo logic seems wack
    //get the birthday of the user from the plist then format it into a string
    PlistHelper *plist = [PlistHelper alloc];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* bday = [formatter dateFromString:[plist getBirthday]];
    //get now date
    NSDate* now = [NSDate date];
    NSLog(@"birthday of user: %@", bday);

    //chate date after now
    if([now compare:from] == NSOrderedAscending)
    {
        rc = 0;
        [self showDateAfterNowDialog];
    }
    //check date before bday
    else if([from compare:bday] == NSOrderedAscending)
    {
        rc = 0;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM dd, YYYY"];
        [self showDateBeforeBdayDialog:[formatter stringFromDate:bday]];
    }
    
    NSString *fromFormatted = [formatter stringFromDate:from];
    
    //get uid
    int uid = [plist getPk];
    if(rc && uid < 0)
    {
        rc = 0;
    }
    
    //add the frict to the remote db
    if(rc)
    {
        [self showAddingFrictDialog];
        rc = [self save_frict:base from:fromFormatted rating:ratingVal notes:hu_notes];
        
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
-(BOOL) save_frict:(int)base from:(NSString *)from rating:(int)rate notes:(NSString *)hu_notes
{
    BOOL rc = true;

    NSString *post;
    
    if(self.frict_id > 0)
    {
        //update
        post = [NSString stringWithFormat:@"&frict_id=%d&mate_id=%d&base=%d&from=%@&rating=%d&notes=%@&creator=%d",self.frict_id, self.mate_id, base, from, rate, hu_notes, self.creator];
    }
    else
    {
        //add
        post = [NSString stringWithFormat:@"&mate_id=%d&base=%d&from=%@&rating=%d&notes=%@&creator=%d",self.mate_id, base, from, rate, hu_notes, self.creator];
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
    NSString * desc = @"Adding Frict";
    if(self.frict_id > 0)
    {
        desc = @"Updating Frict";
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

- (void)showDateAfterNowDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Time Travling Error"];
    [alert setMessage:@"Unfortunately, time travel hasn't been invented yet."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

- (void)showDateBeforeBdayDialog:(NSString *)bday
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Fricting Before Birth?"];
    [alert setMessage:[NSString stringWithFormat:@"According to you, you weren't born until %@.", bday]];
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
        
        SqlHelper * sql = [SqlHelper alloc];
        
        if(self.frict_id > 0)
        {
            //update the local database
            [sql update_frict:intResult from:fromFormatted rating:ratingSlider.value base:baseSwitch.selectedSegmentIndex notes:notes.text];
        }
        else
        {
            [sql add_frict:intResult mate_id:self.mate_id from:fromFormatted rating:ratingSlider.value base:baseSwitch.selectedSegmentIndex notes:notes.text mate_rating:0 mate_notes:NULL mate_deleted:0];
        }
        
        //enable tabbaar items
        [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:TRUE];
        [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:TRUE];
        
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
        //self.navigationController popToRootViewControllerAnimated:YES];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -80 || //adding frict may have failed
           intResult == -90 || //updating frict may have failed
           intResult == -100 || //id was null or not positive
           intResult == -101) //id doesn't exist or isn't unique
        {
            [self showErrorCodeDialog:intResult];
        }
        else
        {
            //unknown error
            [self showErrorCodeDialog:-404];
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= MAX_LENGTH_NOTES)
    {
        return YES;
    } else {
        NSUInteger emptySpace = MAX_LENGTH_NOTES - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

@end
