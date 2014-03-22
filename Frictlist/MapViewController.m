//
//  MapViewController.m
//  Frictlist
//
//  Created by Tony Flo on 1/12/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "MapViewController.h"
#import <sqlite3.h>
#import "Frict.h"
#import <QuartzCore/QuartzCore.h>
#import "version.h"
#import "PlistHelper.h"

@interface MapViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIImageView *image;

@end

@implementation MapViewController

@synthesize scroll, image;

//bad globals
NSString * addr = @"http://ivisited.flooreeda.com/scripts/";
NSString * img_addr = @"http://ivisited.flooreeda.com/images/maps/map";
static NSString * prevIvisited = @"";
static NSString * ivisited = @"";
UIAlertView * alertView;
static int pk = -1; //pk (uid) of an user that's not signed in


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//called once
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"view did load");
}

//called everytime
-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");

}

//called everytime
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"view did appear");
    
#if defined(FREE)
    [self showUpgradeDialog];
#else
    //get pk and ivisited data from the plist
    PlistHelper * plist = [[PlistHelper alloc] init];
    pk = [plist getPk];
    ivisited = [plist getIvisited];
    
    if(![ivisited isEqualToString:prevIvisited])
    {
        //show loading dialog
        [self showLoadingDataDialog];

        //get the date and time
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSString * syncdatetime = [DateFormatter stringFromDate:[NSDate date]];
    
        //send request to server to get map
        int rc = [self getIvisitedmap:pk ivisited:ivisited sync:syncdatetime];        
        if(!rc)
        {
            //something went wrong with the signin
            [self showUnknownMapFailureDialog];
        }
    }
#endif

}

//if sync connection was not successful
- (void)showUnknownMapFailureDialog
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

-(void)showLoadingDataDialog
{
    alertView = [[UIAlertView alloc] initWithTitle:@"Generating iVisited Map"
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

-(void) setupScrollView:(int)pk
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.delegate = self;
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%d.png", img_addr, pk]]];
    image = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
    scrollView.contentSize = image.frame.size;
    [scrollView addSubview:image];
    scrollView.minimumZoomScale = scrollView.frame.size.width / image.frame.size.width;
    scrollView.maximumZoomScale = 2.0;
    [scrollView setZoomScale:scrollView.minimumZoomScale];
    self.view = scrollView;
}


//zooming
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return image;
}

//call sync script to update database entry
     -(BOOL) getIvisitedmap:(int)pk ivisited:(NSString *)visits sync:(NSString *)datetime
{    
    BOOL rc = true;
    //1. Set post string with actual username and password.
    NSString *post = [NSString stringWithFormat:@"&uid=%d&ivisited=%@&datetime=%@", pk,visits, datetime];
    
    //2. Encode the post string using NSASCIIStringEncoding and also the post string you need to send in NSData format
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //You need to send the actual length of your data. Calculate the length of the post string.
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    
    //3. Create a Urlrequest with all the properties like HTTP method, http header field with length of the post string. Create URLRequest object and initialize it.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set the Url for which your going to send the data to that request.
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@make_map.php", addr]]];
    
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

//Below method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)rsp
{
    NSLog(@"Did receive data");
    // to receive the returend value
    NSString *strResult = [[NSString alloc] initWithData:rsp encoding:NSUTF8StringEncoding];
    strResult = [strResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSInteger intResult = [strResult integerValue];
    
    //if the pk is valid
    if(intResult == pk)
    {
        //get the png that was created on the server
        [self setupScrollView:intResult];
        
        //set prev ivisited so if there is no change in ivisited a server request won't happen next time the view is accesssed
        prevIvisited = ivisited;
    }
    //error code was returned
    else
    {
        if(intResult == -6)
        {
            //error with compose (imagick plugin)
            [self showProcessingErrorDialog];
        }
        else if(intResult == -3)
        {
            //sync error
            //error with compose (imagick plugin)
            [self showDatabaseErrorDialog];
        }
        else
        {
            //other error
            [self showUnknownMapFailureDialog];
        }
        //go back to settings view
        [self.tabBarController setSelectedIndex:1];
    }
    //close the alert view
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

//This method , you can use to receive the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Did fail with error");
    NSLog(@"%@", error);
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self.tabBarController setSelectedIndex:1];
    
    //show error (connection error most likely)
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
    NSLog(@"Did finish loading");
}

- (void)showDatabaseErrorDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Database Error"];
    [alert setMessage:@"Something went wrong. Sorry about that. Please try again.  If the problem persists, contact the developer."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert setTag:2];
    [alert show];
}

- (void)showProcessingErrorDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Processing Error"];
    [alert setMessage:@"Something went wrong. Sorry about that. Please try again.  If the problem persists, contact the developer."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert setTag:3];
    [alert show];
}

#if defined(FREE)
- (void)showUpgradeDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Feature Not Available"];
    [alert setMessage:@"Viewing your iVisited map is only available in the paid version of the Frictlist app."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Buy Now"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setTag:1];
    [alert show];
}

//take an action when an alertview button is pushed
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //free version
    if(alertView.tag == 1)
    {
        //Map not available in free version
        NSLog(@"Sign in, free");
        if (buttonIndex == 0)
        {
            //Buy Now, redirect to app store
            NSString *iTunesLink = @"https://itunes.apple.com/us/artist/tony-florida/id375847916";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        
        }
        else if (buttonIndex == 1)
        {
            //Cancel, dismiss
        }
        [self.tabBarController setSelectedIndex:1];
    }
    //compose error
    else if(alertView.tag == 2 || alertView.tag == 3)
    {
        [self.tabBarController setSelectedIndex:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#endif

@end
