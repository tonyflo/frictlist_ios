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

#define ACCEPT (1)
#define REJECT (-1)

@interface RequestViewController ()

@end

@implementation RequestViewController

NSString * url_str = @"http://frictlist.flooreeda.com/scripts/";
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
    
    NSMutableArray * requst = [sql get_notification:self.request_id];
    NSString *fn = requst[0];
    NSString *ln = requst[1];
    NSString *un = requst[2];
    int gender = [requst[3] intValue];
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
    ageText.text = [NSString stringWithFormat:@"%d", age];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"request id %d", self.request_id);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acceptPressed:(id)sender
{
    [self showResponding:@"Accepting"];
    [self respond_mate_request:ACCEPT];
}
- (IBAction)rejectPressed:(id)sender
{
    [self showResponding:@"Rejecting"];
    [self respond_mate_request:REJECT];
}

//respond mate request
-(BOOL) respond_mate_request:(int)status
{
    BOOL rc = true;
    
    PlistHelper *plist = [PlistHelper alloc];
    int uid = [plist getPk];
    NSLog(@"STATUS: %d", status);
    NSString *post = [NSString stringWithFormat:@"&uid=%d&request_id=%d&mate_id=%d&status=%d", uid, self.request_id, mate_id, status];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format.
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    
    //search for mate
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@respond_mate_request.php", url_str]]];
    
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
    
    NSLog(@"Did receive data int: %d str %@ strlen %d", intResult, strResult, strResult.length);
    
    //if the request id is returned, the response was successful
    if(intResult == 1 || intResult == -1)
    {
        NSLog(@"request was successfully responded to");
        
        //save request status to sqlite
        SqlHelper *sql = [SqlHelper alloc];
        //get the data from this request
        NSArray * request = [sql get_notification:self.request_id];
        //delete the request from the table
        [sql remove_notification:self.request_id];
        //add the reqeust to the appropriate table
        if(intResult == 1)
        {
            NSLog(@"accepted");
            //accepted
            [sql add_accepted:self.request_id mate_id:[request[5] intValue] first:request[0] last:request[1] un:request[2] gender:[request[3] intValue] birthdate:request[4]];
        }
        else
        {
            NSLog(@"rejected");
            //rejected
            [sql add_rejected:self.request_id mate_id:[request[5] intValue] first:request[0] last:request[1] un:request[2] gender:[request[3] intValue] birthdate:request[4]];
        }
        
        //go back on success
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
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
            [self showErrorCodeDialog:intResult];
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
