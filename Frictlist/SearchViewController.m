//
//  SearchViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/29/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "SearchViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"
#import "version.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize tableView;

int maxFieldLen = 255;
UIAlertView * alertView;
NSMutableArray * userIdArray;
NSMutableArray * usernameArray;
NSMutableArray * userBdayArray;
NSMutableArray * userAlreadyRequestedArray;
int selectedMateIndex = -1;
NSString * sentTo = @"the recipient";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    //kickoff the search when the view loads
    [self search];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
    
    tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
    
    userIdArray = [[NSMutableArray alloc] init];
    usernameArray = [[NSMutableArray alloc] init];
    userBdayArray = [[NSMutableArray alloc] init];
    userAlreadyRequestedArray = [[NSMutableArray alloc] init];
    
    SqlHelper *sql = [SqlHelper alloc];
    NSArray * mate_data = [sql get_mate:self.mate_id];
    
    NSString * mate_name = [NSString stringWithFormat:@"%@ %@", mate_data[0], mate_data[1]];
    self.title = mate_name;
}

- (void)search
{
    int rc = 1;
    
    [self showSearchingDialog];
    
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    
    SqlHelper *sql = [SqlHelper alloc];
    NSArray * mate_data = [sql get_mate:self.mate_id];
    
    rc = [self search_mate:uid firstname:mate_data[0] lastname:mate_data[1] gender:[mate_data[2] intValue]];
        
    //take action if something went wrong
    if(!rc)
    {
        //something went wrong with the signin
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self showUnknownFailureDialog];
    }
}

//search for mate
-(BOOL) search_mate:(int)uid firstname:(NSString *) firstname lastname:(NSString *)lastname gender:(int)gender
{
    BOOL rc = true;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d&firstname=%@&lastname=%@&gender=%d", uid, firstname, lastname, gender];
    NSLog(@"%@", post);
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    

    //search for mate
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@search_mate.php", SCRIPTS_URL]]];
    
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


-(void)showSearchingDialog
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Searching"
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

-(void)showSendingRequest
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Sending Request"
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
    NSArray *user_list = [strResult componentsSeparatedByString:@"\n"];
    NSString *searchFlag = user_list[0];
    
    if([searchFlag isEqual:@"user_search"])
    {
        //we have gotten data (potentially null at this point) back from the server
        
        //for each row in the table
        //start at 1 to skip over flag row
        for(int i = 1; i < user_list.count - 1; i++)
        {
            //split the row into columns
            NSArray *user = [user_list[i] componentsSeparatedByString:@"\t"];
            
            //make sure array is proper length
            if(user.count == 4)
            {
                [userIdArray addObject: user[0]];
                [usernameArray addObject:user[1]];
                [userBdayArray addObject:user[2]];
                [userAlreadyRequestedArray addObject:user[3]];
            }
            else
            {
                [self showErrorCodeDialog:-412];
                break;
            }
        }
        
        statusText.text = @"No luck? Invite your mate to Frictlist by text or email.";
        textButton.hidden = false;
        emailButton.hidden = false;
        
        if(userIdArray.count > 0)
        {
            resultsText.text = [NSString stringWithFormat:@"%d Results Below", userIdArray.count];
            [self.tableView reloadData];
        }
        else
        {
            resultsText.text = @"No Results";
        }
        
        
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        //[self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    //check for successful request where a request id is returned
    else if(intResult > 0)
    {
        NSLog(@"request sent");
        
        //save request status to sqlite
        SqlHelper *sql = [SqlHelper alloc];
        [sql update_mate_status:self.mate_id accepted:0 request:[userIdArray[selectedMateIndex] intValue]];
        
        [self showRequestSentConfirmation: sentTo];
    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -100 || //id was null or not positive
           intResult == -101 || //id doesn't exist or isn't unique
           intResult == -110) //request insert wasn't successful
        {
            [self showErrorCodeDialog:intResult];
        }
        else
        {
            //unknown error
            [self showErrorCodeDialog:-413];
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

//count rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [userIdArray count];
    if(self.editing) {
        count++;
    }
    return count;
}

//code for each row
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SearchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.editingAccessoryType = YES;
    }
    
    int i = indexPath.row;
    
    NSString *un = usernameArray[i];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * birthday = [formatter dateFromString:userBdayArray[i]];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    //set text color
    cell.textLabel.textColor = [UIColor greenColor];
    
    //set cell icon
    //NSString *base = [NSString stringWithFormat:@"gender_%d.png", [genderArray[i] intValue]];
    //cell.imageView.image = [UIImage imageNamed:base];
    
    //set cell text
    cell.textLabel.text = [NSString stringWithFormat:@"%@ Age: %d", un, age];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if(![userAlreadyRequestedArray[i] isEqual:@""])
    {
        //this request has already been made so disable this row
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.alpha = 0.5;
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (IBAction)emailPressed:(id)sender
{
    
    if ([MFMailComposeViewController canSendMail]) {
        SqlHelper *sql = [SqlHelper alloc];
        NSArray * mate_data = [sql get_mate:self.mate_id];
        
        PlistHelper *plist = [PlistHelper alloc];
        NSString * fn = [plist getFirstName];
        
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@""]];
        [composeViewController setSubject:@"Frictlist App"];
        [composeViewController setMessageBody:[NSString stringWithFormat:@"Hey %@,\n\nYou should download Frictlist from the app store.  It's a great app and I recommend it ;)\n\nHappy Fricting!\n%@", mate_data[0], fn] isHTML:NO];
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:composeViewController animated:YES completion:nil];
        }
    }
}

- (IBAction)textPressed:(id)sender
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"You should download Frictlist from the app store. It's a great app and I recommend it ;) Happy Fricting!";
        controller.messageComposeDelegate = self;
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

//catch result of sms
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch(result)
    {
        case MessageComposeResultCancelled:
        {
            //handle cancelled event
            NSLog(@"Message cancelled");
            break;
        }
        case MessageComposeResultFailed:
        {
            //handle failed event
            NSLog(@"Message failed");
            break;
        }
        case MessageComposeResultSent:
        {
            //handle sent event
            NSLog(@"Message sent");
            break;
        }

    }
    
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//catch result of email
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch(result)
    {
        case MFMailComposeResultCancelled:
        {
            NSLog(@"Mail cancelled");
            break;
        }
        case MFMailComposeResultSaved:
        {
            NSLog(@"Mail saved");
            break;
        }
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail failed");
            break;
        }
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
            break;
        }
            
            
    }
    
    //done
    [self dismissViewControllerAnimated:YES completion:nil];
}

//click on a table cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedMateIndex = indexPath.row;
    sentTo=usernameArray[selectedMateIndex];
    [self showRequestConfirmationDialog:sentTo];
}

//show final warning before making request
-(void) showRequestConfirmationDialog:(NSString *)username
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Is That Your Final Answer?"];
    [alert setMessage:[NSString stringWithFormat:@"You are about to send a request to %@. In doing so, your Frictlist will be shared privately amongst the two of you.  Do you want continue?", username]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setTag:1];
    [alert show];
}

//show request sent dialog
-(void) showRequestSentConfirmation:(NSString *)username
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Your Request Has Been Sent!"];
    [alert setMessage:[NSString stringWithFormat:@"Your request to %@ was successfully sent.", username]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert setTag:2];
    [alert show];
}

//take an action when a choice is made in an alert dialog
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //reset data
    if(alertView.tag == 1)
    {
        if (buttonIndex == 0)
        {
            //send request
            [self send_mate_request];
        }
        else if (buttonIndex == 1)
        {
            //Cancel, dismiss
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if(alertView.tag == 2)
    {
        //request has been sent
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//send mate request
-(BOOL) send_mate_request
{
    BOOL rc = true;
    
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    
    NSString *post = [NSString stringWithFormat:@"&uid=%d&users_mate_id=%d&mates_uid=%d", uid, self.mate_id, [userIdArray[selectedMateIndex] intValue]];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    //search for mate
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@send_mate_request.php", SCRIPTS_URL]]];
    
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

@end
