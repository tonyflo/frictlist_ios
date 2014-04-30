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
#import "version.h"

//mmedia
#import "FrictlistAppDelegate.h"
#import <MillennialMedia/MMInterstitial.h>

#define PIN_INDEX (0)
#define BOTH_INDEX (1)
#define LOC_INDEX (2)

@interface FrictDetailViewController ()

@end

@implementation FrictDetailViewController

@synthesize frict_id, mapView, pinToRemember;


//bad globals
UIAlertView * alertView;
int maxStringLen = 255;
int minAge = 14;
int row = 0; //local index of mate
int col = 0; //local index of frict
int MAX_LENGTH_NOTES = 1024;
bool able_to_drop = true;

int base;
NSString * fromDate;
int rating;
NSString * notesStr;
bool keyboardIsShown = NO;

-(IBAction)valueChanged:(UISlider*)sender {
    int discreteValue = roundl([sender value]); // Rounds float to an integer
    [sender setValue:(float)discreteValue]; // Sets your slider to this value
    sliderText.text = [NSString stringWithFormat:@"%d", discreteValue ];
}

//get user's location
-(void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(!(self.frict_id > 0))
    {
        [self goToUserLocation];
    }
}

-(void)goToUserLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = ZOOM;
    mapRegion.span.longitudeDelta = ZOOM;
    
    [mapView setRegion:mapRegion animated: YES];
}

-(void)goToPin
{
    NSLog(@"pintoremember %@", pinToRemember);
    NSLog(@"lat %f", (double)pinToRemember.coordinate.latitude);
    NSLog(@"lon %f", (double)pinToRemember.coordinate.longitude);
    
    //zoom into current location
    MKCoordinateRegion mapRegion;
    mapRegion.center = pinToRemember.coordinate;
    mapRegion.span.latitudeDelta = ZOOM;
    mapRegion.span.longitudeDelta = ZOOM;
    
    [mapView setRegion:mapRegion animated: YES];
}

-(void)registerTouch
{
    //register touch
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 1 seconds
    [mapView addGestureRecognizer:lpgr];
}

//animate pin drop
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    if(able_to_drop)
    {
        MKAnnotationView *aV;
        for (aV in views) {
            CGRect endFrame = aV.frame;
            
            aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 230.0, aV.frame.size.width, aV.frame.size.height);
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.45];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [aV setFrame:endFrame];
            [UIView commitAnimations];
            
        }
    }
}

//add pin
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        //unhide pin if necessary
        if(locationToggle.selectedSegmentIndex == LOC_INDEX)
        {
            NSLog(@"hereee");
            //[[mapView viewForAnnotation:pinToRemember] setHidden:NO];
            [locationToggle setSelectedSegmentIndex:BOTH_INDEX];
        }
        
        //remove pin if it exists
        if(pinToRemember != NULL)
        {
            //then remove it
            [mapView removeAnnotation:pinToRemember];
            pinToRemember = NULL;
            NSLog(@"Pin is now null");
        }
    }
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = touchMapCoordinate;
    [mapView addAnnotation:annot];
    pinToRemember = annot;
    [[mapView viewForAnnotation:pinToRemember] setHidden:NO];
    
    NSLog(@"coords: %f, %f", pinToRemember.coordinate.latitude, pinToRemember.coordinate.longitude);
}

//location segmented control was changed
-(IBAction)locationToggled:(id)sender
{
    NSInteger selectedSegment = locationToggle.selectedSegmentIndex;
    MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
    
    
    switch (selectedSegment) {
        case PIN_INDEX:
            NSLog(@"PIN LOCATION");
            
            if(pinToRemember != NULL)
            {
                //show pin
                [[mapView viewForAnnotation:pinToRemember] setHidden:NO];
                
                //go to pin
                [self goToPin];
            }
            
            //hide blue dot
            ulv.hidden = YES;
            
            break;
        case BOTH_INDEX:
            NSLog(@"BOTH LOCATIONS");
            //note: pin is shown in regionDidChangeAnimated
            
            bool pinExists = (pinToRemember == NULL) ? false : true;
            
            if(pinExists)
            {
                //show both pin and user location in map view
                [self zoomToFitMapAnnotations];
                
                //show pin
                [[mapView viewForAnnotation:pinToRemember] setHidden:NO];
                
            }
            else
            {
                //move view to user location
                [self goToUserLocation];
            }
 
            break;
        case LOC_INDEX:
            NSLog(@"USER LOCATION");
            //go to the blue dot
            [self goToUserLocation];
            
            //show blue dot
            ulv.hidden = NO;
            
            if(pinToRemember != NULL)
            {
                //hide pin
                [[mapView viewForAnnotation:pinToRemember] setHidden:YES];
            }
            
            break;
            
        default:
            break;
    }
}


//finish animation
-(void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"done animating");
    int index = locationToggle.selectedSegmentIndex;
    if(index == BOTH_INDEX)
    {
        //show blue dot
        MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
        ulv.hidden = NO;
        
        //show pin if exists
        if(pinToRemember != NULL)
        {
            [[mapView viewForAnnotation:pinToRemember] setHidden:NO];
        }
    }
    
    if(index == LOC_INDEX)
    {
        MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
        ulv.hidden = NO;
    }
    
    if(index == PIN_INDEX)
    {
        //show pin if exists
        if(pinToRemember != NULL)
        {
            [[mapView viewForAnnotation:pinToRemember] setHidden:NO];
        }
    }

    
}

- (void)zoomToFitMapAnnotations {
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    
    // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    //validate region
    
    if(region.center.latitude >= 90.0 || region.center.latitude <= -90.0)
    {
        //invalid latitude center
        region.center.latitude = 0.0;
        NSLog(@"Invalid center latatude");
    }
    
    if(region.center.longitude >= 180.0 || region.center.longitude <= -180.0)
    {
        //invalid longitude center
        region.center.longitude = 0.0;
        NSLog(@"Invalid center longitude");
    }
    
    float map_span_lat = mapView.region.span.latitudeDelta;
    float map_span_lon = mapView.region.span.longitudeDelta;
    NSLog(@"map span lat: %f", map_span_lat);
    NSLog(@"map span lon: %f", map_span_lon);
    
    if(region.span.latitudeDelta > map_span_lat || region.span.latitudeDelta <= 0.0)
    {
        //invalid latitude span
        NSLog(@"Invalid span latitude %f", region.span.latitudeDelta);
        region.span.latitudeDelta = map_span_lat;
    }
    
    if(region.span.longitudeDelta >= map_span_lon || region.span.longitudeDelta <= 0.0)
    {
        //invalid longitude span
        NSLog(@"Invalid span longitude %f", region.span.longitudeDelta);
        region.span.longitudeDelta = map_span_lon;
    }
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    NSLog(@"Done zooming");
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"pintoremember %@", pinToRemember);
    NSLog(@"lat %f", (double)pinToRemember.coordinate.latitude);
    NSLog(@"lon %f", (double)pinToRemember.coordinate.longitude);
    
    //show user's location if a new frict
    if(!(self.frict_id > 0))
    {
        //wait for user's location
        
        //set toggle to both
        [locationToggle setSelectedSegmentIndex:LOC_INDEX];
    }
    else
    {
        //add pin
        [mapView addAnnotation:pinToRemember];
        
        //go to the location of the "pin"
        [self goToPin];
        
        //set segmented control to index pin
        [locationToggle setSelectedSegmentIndex:PIN_INDEX];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear frict detail");
    
    //disable editing date, location, and base of a shared frict
    if(self.frict_id > 0)
    {
        fromSwitch.enabled = false;
        fromSwitch.alpha = 0.5;
        baseSwitch.enabled = false;
        baseSwitch.alpha = 0.5;
    }
    
    //allow droping of new pins if new frict or not accepted (shared)
    if(!(self.frict_id > 0) || !(self.accepted))
    {
        //only allow changing location of frict on new fricts
        [self registerTouch];
    }
    
    //if the frict exists
    if(self.frict_id > 0)
    {
        self.title = @"Update Frict";
        
        //initialize helpers
        SqlHelper *sql = [SqlHelper alloc];
        
        //get mate data
        NSArray *mate = [sql get_mate:self.mate_id];
        NSString *mateFirstName = mate[0];
        NSString *mateLastName = mate[1];
        //int mateGender = [mate[2] intValue];
        
        //declare frict data
        NSArray *frict;
        NSString * fromDate = @"";
        int rating = 0;
        int base = -1;
        NSString * notesStr = @"";
        int mateRating = 0;
        NSString * mateNotesStr = @"";
        int mateDeleted = 0;
        int creator = 1;
        double lat = 0;
        double lon = 0;
        
        //get frict data
        frict = [sql get_frict:self.frict_id];
        fromDate = frict[0];
        rating = [frict[1] intValue];
        base = [frict[2] intValue];
        notesStr = frict[3];
        mateRating = [frict[4] intValue];
        mateNotesStr = frict[5];
        mateDeleted = [frict[6] intValue];
        creator = [frict[7] intValue];
        lat = [frict[9] doubleValue];
        lon = [frict[10] doubleValue];
        
        if(mateNotesStr == nil || mateNotesStr == NULL || [mateNotesStr isEqualToString: @"(null)"])
        {
            mateNotesStr = @"";
        }
            
        //show date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate * fromAsDate = [formatter dateFromString:fromDate];
        [fromSwitch setDate:fromAsDate];
            
        //set base
        [baseSwitch setSelectedSegmentIndex:base];
        
        //set lat/lon
        MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D pin;
        pin.latitude = lat;
        pin.longitude = lon;
        annot.coordinate = pin;
        //set the pin as the pintoremember
        pinToRemember = annot;
        NSLog(@"lat %f lon %f in viewwillappear", lat, lon);
        
        //creator: the creator of the frict | 1 if the creator of the frictlist, 0 otherwise
        //self.creator: the creator of the frictlist | 1 if this user, 0 otherwise
        if(creator == 1 && self.creator == 1)
        {
            //I created this frict and I created this frictlist
            NSLog(@"I created this frict and I created this frictlist");//
            
            sliderText.text = [NSString stringWithFormat:@"%d", rating ];
            ratingSlider.value = rating;
            [notes setText:notesStr];
        }
        else if(creator == 0 && self.creator == 1)
        {
            //My mate created this frict but I created this frictlist
            NSLog(@"My mate created this frict but I created this frictlist");////
            
            sliderText.text = [NSString stringWithFormat:@"%d", rating ];
            ratingSlider.value = rating;
            [notes setText:notesStr];
        }
        else if(creator == 1 && self.creator == 0)
        {
            //My mate created this frict and my mate created the frictlist
            NSLog(@"My mate created this frict and my mate created the frictlist");//
            
            sliderText.text = [NSString stringWithFormat:@"%d", mateRating ];
            ratingSlider.value = mateRating;
            [notes setText:mateNotesStr];
        }
        else if(creator == 0 && self.creator == 0)
        {
            //I created this frict but my mate created the frictlist
            NSLog(@"I created this frict but my mate created the frictlist");////
            
            sliderText.text = [NSString stringWithFormat:@"%d", mateRating ];
            ratingSlider.value = mateRating;
            [notes setText:mateNotesStr];
        }
        else
        {
            //todo, should never happen, throw error code
            NSLog(@"BAD");
        }

    }
    else
    {
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
    NSLog(@"view did load frict edit");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    notes.delegate = self;
    mapView.delegate = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
    
    //enable tabbaar items
    [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:FALSE];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:FALSE];
    
    //keyboard below cursor
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    keyboardIsShown = NO;
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
    
    //ensure a location was selected
    if(rc && pinToRemember == NULL)
    {
        [self showNeedALocationDialog];
        rc = 0;
    }
    
    if(rc && [sliderText.text intValue] == 0)
    {
        [self showNeedSliderValueDialog];
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
        post = [NSString stringWithFormat:@"&frict_id=%d&mate_id=%d&base=%d&from=%@&rating=%d&notes=%@&creator=%d&lat=%f&lon=%f",self.frict_id, self.mate_id, base, from, rate, hu_notes, self.creator, pinToRemember.coordinate.latitude, pinToRemember.coordinate.longitude];
    }
    else
    {
        //add
        post = [NSString stringWithFormat:@"&mate_id=%d&base=%d&from=%@&rating=%d&notes=%@&creator=%d&lat=%f&lon=%f",self.mate_id, base, from, rate, hu_notes, self.creator, pinToRemember.coordinate.latitude, pinToRemember.coordinate.longitude];
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
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@update_frict.php", SCRIPTS_URL]]];
    }
    else
    {
        //this hookup is new hookup, insert it into the mysql db
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@add_frict.php", SCRIPTS_URL]]];
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
            if(self.creator == 1)
            {
                //the creator of the frictlist is updating this frict
                [sql update_frict_as_fl_creator:intResult from:fromFormatted rating:ratingSlider.value base:baseSwitch.selectedSegmentIndex notes:notes.text lat:pinToRemember.coordinate.latitude lon:pinToRemember.coordinate.longitude];
                NSLog(@"updating frict as creator");
            }
            else if(self.creator == 0)
            {
                //the recipient of the frictlist is updating this frict
                [sql update_frict_as_fl_recipient:intResult from:fromFormatted base:baseSwitch.selectedSegmentIndex mate_rating:ratingSlider.value mate_notes:notes.text mate_deleted:0];
                NSLog(@"updating frict as recipient");
            }
            else
            {
                 //bad error, todo: error code
            }

        }
        else
        {
            if(self.creator == 1)
            {
                //creator of the frictlist is adding a frict
                [sql add_frict:intResult mate_id:self.mate_id from:fromFormatted rating:ratingSlider.value base:baseSwitch.selectedSegmentIndex notes:notes.text mate_rating:0 mate_notes:NULL mate_deleted:0 creator:self.creator deleted:0 lat:pinToRemember.coordinate.latitude lon:pinToRemember.coordinate.longitude];
            }
            else if(self.creator == 0)
            {
                //recipient of the frictlist is adding a frict
                [sql add_frict:intResult mate_id:self.mate_id from:fromFormatted rating:0 base:baseSwitch.selectedSegmentIndex notes:@"" mate_rating:ratingSlider.value mate_notes:notes.text mate_deleted:0 creator:self.creator deleted:0 lat:pinToRemember.coordinate.latitude lon:pinToRemember.coordinate.longitude];
            }
            else
            {
                //bad error, todo: error code
            }
        }
        
        //enable tabbaar items
        [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:TRUE];
        [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:TRUE];
        
        //go back to settings view
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        //[self dismissViewControllerAnimated:YES completion:nil];
        //[self.navigationController popViewControllerAnimated:YES];
        //self.navigationController popToRootViewControllerAnimated:YES];
        
        [self interstatialAd];
        
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
    }
    //error code was returned
    else
    {
        //known error codes
        if(intResult == -80 || //adding frict may have failed
           intResult == -90 || //updating frict may have failed
           intResult == -91 || //creator flag wasn't 1 or 0 when updating frict
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

//need a rating before pressing save
-(void) showNeedSliderValueDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Need a Rating"];
    [alert setMessage:@"Please give this frict a rating before continuing."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//user needs to select a locatin before saving a frict
-(void) showNeedALocationDialog
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Need a Pin"];
    [alert setMessage:@"Please add a pin to the map before continuing."];
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

- (void)keyboardWillHide:(NSNotification *)n
{
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // resize the scrollview
    CGRect viewFrame = scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height += (keyboardSize.height - TAB_BAR_HEIGHT);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow:(NSNotification *)n
{
    // This is an ivar I'm using to ensure that we do not do the frame size adjustment on the `UIScrollView` if the keyboard is already shown.  This can happen if the user, after fixing editing a `UITextField`, scrolls the resized `UIScrollView` to another `UITextField` and attempts to edit the next `UITextField`.  If we were to resize the `UIScrollView` again, it would be disastrous.  NOTE: The keyboard notification will fire even when the keyboard is already shown.
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the noteView
    CGRect viewFrame = scrollView.frame;
    // I'm also subtracting a constant kTabBarHeight because my UIScrollView was offset by the UITabBar so really only the portion of the keyboard that is leftover pass the UITabBar is obscuring my UIScrollView.
    viewFrame.size.height -= (keyboardSize.height - TAB_BAR_HEIGHT);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [scrollView setFrame:viewFrame];
    [UIView commitAnimations];
    keyboardIsShown = YES;
}

-(void)interstatialAd
{
    //Location Object
    FrictlistAppDelegate *appDelegate = (FrictlistAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Replace YOUR_APID with the APID provided to you by Millennial Media
    if ([MMInterstitial isAdAvailableForApid:@"161158"]) {
        [MMInterstitial displayForApid:@"161158"
                    fromViewController:self
                       withOrientation:MMOverlayOrientationTypeAll
                          onCompletion:nil];
    }
    else {
        //MMRequest Object
        MMRequest *request = [MMRequest requestWithLocation:appDelegate.locationManager.location];
        
        [MMInterstitial fetchWithRequest:request
                                    apid:@"161158"
                            onCompletion:^(BOOL success, NSError *error) {
                                if (success) {
                                    [MMInterstitial displayForApid:@"161158"
                                                fromViewController:self
                                                   withOrientation:MMOverlayOrientationTypeAll
                                                      onCompletion:nil];
                                }
                                else
                                {
                                    NSLog(@"INTERSTATIAL DISPLAY ERROR");
                                }
                            }];
    }
}


@end
