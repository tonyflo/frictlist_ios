//
//  RequestViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/29/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "RequestViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"

@interface RequestViewController ()

@end

@implementation RequestViewController

@synthesize tableView;

int maxFieldLen = 255;
UIAlertView * alertView;
NSString * frict_scripts_url_str = @"http://frictlist.flooreeda.com/scripts/";
NSMutableArray * userIdArray;
NSMutableArray * usernameArray;
NSMutableArray * userBdayArray;

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
}

- (void)search
{
    int rc = 1;
    
    [self showSearchingDialog];
    
    SqlHelper *sql = [SqlHelper alloc];
    NSArray * mate_data = [sql get_mate:self.mate_id];
    
    rc = [self search_mate:mate_data[0] lastname:mate_data[1] gender:[mate_data[2] intValue]];
        
    //take action if something went wrong
    if(!rc)
    {
        //something went wrong with the signin
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self showUnknownFailureDialog];
    }
}




//search for mate
-(BOOL) search_mate:(NSString *) firstname lastname:(NSString *)lastname gender:(int)gender
{
    BOOL rc = true;
    
    NSString *post = [NSString stringWithFormat:@"&firstname=%@&lastname=%@&gender=%d", firstname, lastname, gender];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    

    //search for mate
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@search_mate.php", frict_scripts_url_str]]];
    
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

//the field is too long
-(void) showFieldTooLong:(NSString *)fieldName
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:[NSString stringWithFormat:@"%@ Too Long", fieldName]];
    [alert setMessage:[NSString stringWithFormat:@"The %@ that you entered is too long. The max is %d characters.", fieldName, maxFieldLen]];
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
            if(user.count == 3)
            {
                [userIdArray addObject: user[0]];
                [usernameArray addObject:user[1]];
                [userBdayArray addObject:user[2]];
                
                
            }
        }
        
        statusText.text = @"No luck? Invite your mate to Frictlist by text or email!";
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
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -100 || //id was null or not positive
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
        } else {
            [self presentModalViewController:composeViewController animated:YES];
        }
        //[self presentViewController:composeViewController animated:YES completion:nil];
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
        } else {
            [self presentModalViewController:controller animated:YES];
        }
    }
}

//catch result of sms
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch(result)
    {
        case MessageComposeResultCancelled: break; //handle cancelled event
        case MessageComposeResultFailed: break; //handle failed event
        case MessageComposeResultSent: break; //handle sent event
    }
    [self dismissModalViewControllerAnimated:YES];
}

//catch result of email
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
