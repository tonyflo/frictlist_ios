//
//  RequestViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/30/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "RequestViewController.h"
#import "SqlHelper.h"
#import "PlistHelper.h"
#import "version.h"

#define ACCEPT (1)
#define REJECT (-1)

@interface RequestViewController ()

@end

@implementation RequestViewController

int mate_id = -1; //mate id of the user who made the request
UIAlertView * alertView;

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
    SqlHelper *sql = [SqlHelper alloc];
    
    NSMutableArray * requst;
    if(self.viewRequest == 1)
    {
        //responding to request
        requst = [sql get_notification:(int)self.request_id];
    }
    else if(self.viewRequest == -1)
    {
        //changing rejected
        requst = [sql get_rejected:(int)self.request_id];
        //disable pending index of segmented control
        [segmentedControl setEnabled:NO forSegmentAtIndex:1];
        [segmentedControl setSelectedSegmentIndex:0]; //set rejected as selected
    }
    else
    {
        [self showErrorCodeDialog:-421];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSString *fn = requst[0];
    NSString *ln = requst[1];
    NSString *un = requst[2];
    int gender = [requst[3] intValue];
    NSLog(@"request: %@", requst);
    NSString *bday = requst[4];
    mate_id = [requst[5] intValue];
    
    nameText.text = [NSString stringWithFormat:@"%@ %@", fn, ln];
    usernameText.text = un;
    
    // gender
    NSString *genderStr = [NSString stringWithFormat:@"gender_%d.png", gender];
    genderImage.image = [UIImage imageNamed:genderStr];
    
    //age
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * birthday = [formatter dateFromString:bday];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    ageText.text = [NSString stringWithFormat:@"%ld", (long)age];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"request id %lu", (unsigned long)self.request_id);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)segmentSwitch:(id)sender
{
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if(selectedSegment == 0)
    {
        //accepted
        [self showResponding:@"Rejecting"];
        [self respond_mate_request:REJECT];
    }
    else if(selectedSegment == 2)
    {
        //rejected
        [self showResponding:@"Accepting"];
        [self respond_mate_request:ACCEPT];
    }
    else
    {
        //do nothing
    }
}

//respond mate request
-(BOOL) respond_mate_request:(int)status
{
    BOOL rc = true;
    
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    NSLog(@"STATUS: %d", status);
    NSString *post = [NSString stringWithFormat:@"&uid=%d&request_id=%lu&mate_id=%d&status=%d", uid, (unsigned long)self.request_id, mate_id, status];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    //search for mate
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@respond_mate_request.php", SCRIPTS_URL]]];
    
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
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_frictlist.php", SCRIPTS_URL]]];
    
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
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get_notifications.php", SCRIPTS_URL]]];
    
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


-(void)showResponding:(NSString *)status
{
    alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ request", status]
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
    
    NSLog(@"Did receive data int: %ld str %@ strlen %lu", (long)intResult, strResult, (unsigned long)strResult.length);
    NSArray *query_result = [strResult componentsSeparatedByString:@"\n"];
    NSString *searchFlag = query_result[0];
    SqlHelper *sql = [SqlHelper alloc];
    
    //if the request id is returned, the response was successful
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
            NSLog(@"Frict count = %lu", (unsigned long)frict.count);
            if(frict.count == 18)
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
                    [sql add_frict:[frict[6] intValue] mate_id:[frict[0] intValue] from:frict[7] rating:[frict[8] intValue] base:[frict[9] intValue] notes:frict[10] mate_rating:[frict[12] intValue] mate_notes:frict[13] mate_deleted:[frict[14] intValue] creator:[frict[15] intValue] deleted:[frict[11] intValue] lat:[frict[16] doubleValue] lon:[frict[17] doubleValue]];
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
            
            if(notification.count == 21)
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
                        [sql add_accepted:[notification[0] intValue] mate_id:[notification[1] intValue] first:notification[3] last:notification[4] un:notification[5] gender:[notification[6] intValue] birthdate:notification[7] deleted:[notification[20] intValue]];
                        [acceptedRequestIdArray addObject:notification[0]];
                    }
                    
                    //check for frict data. make sure frict_id is not null and that the recipient hasn't already deleted this frict
                    if(notification[8] != NULL && notification[8] != nil && ![notification[8] isEqual:@""] && [notification[16] intValue] != 1)
                    {
                        NSLog(@"FOUND FRICT DATA");
                        [sql add_frict:[notification[8] intValue] mate_id:[notification[1] intValue] from:notification[9] rating:[notification[10] intValue] base:[notification[11] intValue] notes:notification[12] mate_rating:[notification[14] intValue] mate_notes:notification[15] mate_deleted:[notification[16] intValue] creator:[notification[17] intValue] deleted:[notification[13] intValue] lat:[notification[18] doubleValue] lon:[notification[19] doubleValue]];
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
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    //responding to request
    else if(intResult == 1 || intResult == -1)
    {
        NSLog(@"request was successfully responded to");
        
        //save request status to sqlite
        SqlHelper *sql = [SqlHelper alloc];
        //get the data from this request
        NSMutableArray * request;
        if(self.viewRequest == 1)
        {
            //responding to request
            request = [sql get_notification:(int)self.request_id];
        }
        else if(self.viewRequest == -1)
        {
            //changing reject to accept
            request = [sql get_rejected:(int)self.request_id];
            
            //remove rejected frict
            [sql remove_rejected:(int)self.request_id];
        }
        else
        {
            [self showErrorCodeDialog:-422];
        }
        //delete the request from the table
        [sql remove_notification:(int)self.request_id];
        //add the reqeust to the appropriate table
        if(intResult == 1)
        {
            NSLog(@"accepted");
            //accepted
            [sql add_accepted:(int)self.request_id mate_id:[request[5] intValue] first:request[0] last:request[1] un:request[2] gender:[request[3] intValue] birthdate:request[4] deleted:0];
            
            //get frictlist after accepting mate
            PlistHelper * plist = [PlistHelper alloc];
            SqlHelper *sql = [SqlHelper alloc];
            
            BOOL success = [sql removeSqliteFile];
            [sql createEditableCopyOfDatabaseIfNeeded];
            if(success)
            {
                [self get_frictlist:[plist getPk]];
            }
        }
        else
        {
            NSLog(@"rejected");
            //rejected
            [sql add_rejected:(int)self.request_id mate_id:[request[5] intValue] first:request[0] last:request[1] un:request[2] gender:[request[3] intValue] birthdate:request[4]];
            //go back
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -100 || //id was null or not positive
           intResult == -101 || //id doesn't exist or isn't unique
           intResult == -120 || //accepte/reject update wasn't successful
           intResult == -121) //accept/reject value wasn't 1/-1
        {
            [self showErrorCodeDialog:(int)intResult];
        }
        else
        {
            //unknown error
            [self showErrorCodeDialog:-414];
        }
        
    }
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
