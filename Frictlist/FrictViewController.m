//
//  FrictViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/22/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "FrictViewController.h"
#import "FrictDetailViewController.h"
#import "SearchViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"
#import "version.h"

#define FRICT_CREATOR_INDEX (0)
#define FRICT_MATE_INDEX (1)

#define NUM_SWIPE_INDEX_ZERO_BASED (2)

#define FIRST_NAME_INDEX (0)
#define NOTES_INDEX (1)
#define RATING_INDEX (2)

@interface FrictViewController ()

@end

@implementation FrictViewController

@synthesize pinToRemember;

NSMutableArray * frictInfo; //array of creator and mate data
int swipeIndex = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)handleSwipeRight:(id)sender {
    NSLog(@"right");
    swipeIndex--;
    if(swipeIndex < 0)
    {
        swipeIndex = NUM_SWIPE_INDEX_ZERO_BASED;
    }
    
    [self checkDisplay];
}
- (IBAction)handleSwipeLeft:(id)sender {
    NSLog(@"left");
    swipeIndex++;
    if(swipeIndex > NUM_SWIPE_INDEX_ZERO_BASED)
    {
        swipeIndex = 0;
    }
    
    [self checkDisplay];
} 

-(void)checkDisplay
{
    if(swipeIndex < NUM_SWIPE_INDEX_ZERO_BASED)
    {
        [self showFields];
        [self setAppropirateFrictInfo];
        mapView.hidden = true;
    }
    else
    {
        [self hideFields];
        mapView.hidden = false;
        searchButton.hidden = true;
    }
    
    if(swipeIndex == 0)
    {
        [creatorSwitch setImage:[UIImage imageNamed:@"selected_1.png"] forState:UIControlStateNormal];
        [mateSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
        [mapSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
    }
    else if(swipeIndex == 1)
    {
        [creatorSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
        [mateSwitch setImage:[UIImage imageNamed:@"selected_1.png"] forState:UIControlStateNormal];
        [mapSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
    }
    else
    {
        [creatorSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
        [mateSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
        [mapSwitch setImage:[UIImage imageNamed:@"selected_1.png"] forState:UIControlStateNormal];
    }
}

-(void)hideFields
{
    nameText.hidden = true;
    notesText.hidden = true;
    ratingText.hidden = true;
    notesText.hidden = true;
    creatorStatusImage.hidden = true;
}

-(void)showFields
{
    nameText.hidden = false;
    notesText.hidden = false;
    ratingText.hidden = false;
    notesText.hidden = false;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapView.delegate = self;

    
    UIBarButtonItem *editFrictButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editFrictButtonPressed)];
    [self.navigationItem setRightBarButtonItem:editFrictButton];
}

-(void)editFrictButtonPressed
{
    NSLog(@"going to frict detail view");
    [self performSegueWithIdentifier:@"editFrict" sender:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Frict id: %d", self.frict_id);
    //jump to the edit view if this is a new row in the list
    if(self.frict_id <= 0)
    {
        [self editFrictButtonPressed];
    }
    else{
        NSLog(@"Staying at frict view");
        [self goToPin];
    }
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//send data from table view to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Prepare for segue");
    if([segue.identifier isEqualToString:@"editFrict"])
    {
        NSLog(@"mate id: %d frict id: %d", self.mate_id, self.frict_id);
        FrictDetailViewController *destViewController = segue.destinationViewController;
        destViewController.mate_id = self.mate_id;
        destViewController.frict_id = self.frict_id;
        destViewController.accepted = self.accepted;
        destViewController.creator = self.creator;
    }
    else if([segue.identifier isEqualToString:@"searchMate"])
    {
        NSLog(@"search mate segue");
        SearchViewController *destViewConroller = segue.destinationViewController;
        destViewConroller.mate_id = self.mate_id;
    }
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

-(void) viewWillAppear:(BOOL)animated
{
    swipeIndex = 0;
    
    NSMutableArray * creatorOfFrict = [[NSMutableArray alloc] init];
    NSMutableArray * mateOfFrict = [[NSMutableArray alloc] init];
    
    //initialize helpers
    PlistHelper * plist = [PlistHelper alloc];
    SqlHelper *sql = [SqlHelper alloc];
    
    //get user data
    NSString *userFirstName = [plist getFirstName];
    
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
    int deleted = 0;
    double lat = 0;
    double lon = 0;
    
    //override the creator variable if this is a new frict
    if(self.frict_id > 0)
    { 
        //get frict data
        frict = [sql get_frict:self.frict_id];
        fromDate = frict[0];
        rating = [frict[1] intValue];
        base = [frict[2] intValue];
        notesStr = frict[3];
        mateRating = [frict[4] intValue];
        mateNotesStr = frict[5];
        mateDeleted = [frict[6] intValue];
        NSLog(@"Mate deleted %d frict id %d", mateDeleted,self.frict_id);
        creator = [frict[7] intValue];
        deleted = [frict[8] intValue];
        lat = [frict[9] doubleValue];
        lon = [frict[10] doubleValue];
        
        if(mateNotesStr == nil || mateNotesStr == NULL || [mateNotesStr isEqualToString: @"(null)"])
        {
            mateNotesStr = @"";
            NSLog(@"NULL");
        }
        else
        {
            NSLog(@"NOT NULL");
        }
    }
    
    //show date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, YYYY"];
    NSDateFormatter *converter = [[NSDateFormatter alloc] init];
    [converter setDateFormat:@"yyyy-MM-dd"];
    dateRangeText.text = [formatter stringFromDate:[converter dateFromString:fromDate]];
    
    //set base
    NSString *baseStr = [NSString stringWithFormat:@"base_%d.png", base + 1];
    baseImageView.image = [UIImage imageNamed:baseStr];
    
    if(base != -1)
    {
        //set score for this frict
        int score[4] = {1, 3, 5, 9};
        scoreText.text = [NSString stringWithFormat:@"%d", score[base]];
        scoreText.font = [UIFont fontWithName:@"DBLCDTempBlack" size:28.0];
    }
    else
    {
        scoreText.text = [NSString stringWithFormat:@"%d", 0];
        scoreText.font = [UIFont fontWithName:@"DBLCDTempBlack" size:28.0];
    }
    
    //set lat/lon
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D pin;
    pin.latitude = lat;
    pin.longitude = lon;
    annot.coordinate = pin;
    //set the pin as the pintoremember
    pinToRemember = annot;
    NSLog(@"lat %f lon %f in viewwillappear", lat, lon);
    [mapView addAnnotation:annot];
    
    //creator of frict used to go on the left
    
    //creator: the creator of the frict | 1 if the creator of the frict, 0 otherwise
    //self.creator: the creator of the frictlist | 1 if this user, 0 otherwise
    if(creator == 1 && self.creator == 1)
    {
        //I created this frict and I created this frictlist
        NSLog(@"I created this frict and I created this frictlist");//

        //left
        [creatorOfFrict addObject:userFirstName];
        [creatorOfFrict addObject:notesStr];
        [creatorOfFrict addObject:[NSString stringWithFormat:@"%d",rating]];
        
        //right
        [mateOfFrict addObject:mateFirstName];
        [mateOfFrict addObject:mateNotesStr];
        [mateOfFrict addObject:[NSString stringWithFormat:@"%d",mateRating]];
        
        if(mateDeleted == 1)
        {
            [mateOfFrict addObject:@"1"];
        }
        else
        {
            [mateOfFrict addObject:@"0"];
        }
        [creatorOfFrict addObject:@"0"];
    }
    else if(creator == 0 && self.creator == 1)
    {
        //My mate created this frict but I created this frictlist
         NSLog(@"My mate created this frict but I created this frictlist");////

        //left
        [creatorOfFrict addObject:mateFirstName];
        [creatorOfFrict addObject:mateNotesStr];
        [creatorOfFrict addObject:[NSString stringWithFormat:@"%d",mateRating]];
        
        //right
        [mateOfFrict addObject:userFirstName];
        [mateOfFrict addObject:notesStr];
        [mateOfFrict addObject:[NSString stringWithFormat:@"%d",rating]];
        
        if(mateDeleted == 1)
        {
            [creatorOfFrict addObject:@"1"];
        }
        else
        {
            [creatorOfFrict addObject:@"0"];
        }
        [mateOfFrict addObject:@"0"];
    }
    else if(creator == 1 && self.creator == 0)
    {
        //My mate created this frict and my mate created the frictlist
        NSLog(@"My mate created this frict and my mate created the frictlist");//
        
        NSArray * accepted = [sql get_accepted:self.request_id];
        mateFirstName = accepted[0];
        mateLastName = accepted[1];
        
        //left
        [creatorOfFrict addObject:mateFirstName];
        [creatorOfFrict addObject:notesStr];
        [creatorOfFrict addObject:[NSString stringWithFormat:@"%d",rating]];

        //right
        [mateOfFrict addObject:userFirstName];
        [mateOfFrict addObject:mateNotesStr];
        [mateOfFrict addObject:[NSString stringWithFormat:@"%d",mateRating]];
        
        if(deleted == 1)
        {
            [creatorOfFrict addObject:@"1"];
        }
        else
        {
            [creatorOfFrict addObject:@"0"];
        }
        [mateOfFrict addObject:@"0"];
    }
    else if(creator == 0 && self.creator == 0)
    {
        //I created this frict but my mate created the frictlist
        NSLog(@"I created this frict but my mate created the frictlist");////
        
        NSArray * accepted = [sql get_accepted:self.request_id];
        mateFirstName = accepted[0];
        mateLastName = accepted[1];

        //left
        [creatorOfFrict addObject:userFirstName];
        [creatorOfFrict addObject:mateNotesStr];
        [creatorOfFrict addObject:[NSString stringWithFormat:@"%d",mateRating]];

        //right
        [mateOfFrict addObject:mateFirstName];
        [mateOfFrict addObject:notesStr];
        [mateOfFrict addObject:[NSString stringWithFormat:@"%d",rating]];
        
        if(deleted == 1)
        {
            [mateOfFrict addObject:@"1"];
        }
        else
        {
            [mateOfFrict addObject:@"0"];
        }
        [creatorOfFrict addObject:@"0"];
    }
    else
    {
        //todo, should never happen, throw error code
        NSLog(@"BAD");
    }
    
    //set creator flag
    [creatorOfFrict addObject:[NSString stringWithFormat:@"%d", creator]];
    [mateOfFrict addObject:[NSString stringWithFormat:@"%d", !creator]];
    
    frictInfo = [[NSMutableArray alloc] initWithObjects:creatorOfFrict, mateOfFrict, nil];

    [self setAppropirateFrictInfo];
        
    self.title = [NSString stringWithFormat:@"%@ %@", mateFirstName, mateLastName];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
    
    
}

//0 if user cannot invite mate
//1 if user can invite mate
//2 if user already invited mate and the status is pending
-(int)canUserInviteMate
{
    SqlHelper *sql = [SqlHelper alloc];
    NSArray * mate_details;
    
    //get mate info
    if(self.creator == 0)
    {
        //Accpted this incomming request
        return 0;
    }
    else
    {
        //if coming from a personal row, use the mate id to get the data for this mate
        mate_details=[sql get_mate:self.mate_id];
    }
    
    if(self.creator == 1)
    {
        //disable sending multiple requests or editing a mate by checking
        // - if there's a request uid: mate_details[4]
        // - if accepted is pending (0) or accepted (1). we allow to re-rearch upon a rejection (-1)
        if([mate_details[4] intValue] > 0)
        {
            if([mate_details[3] intValue] == 1)
            {
                //accepted
                return 0;
            }
            else if([mate_details[3] intValue] == 0)
            {
                //pending
                return 2;
            }
        }
    }
    else
    {
        //this user already accepted
        return 1;
    }

    return true;
}

//populate visible text fields
-(void) setAppropirateFrictInfo
{
    NSString * name = frictInfo[swipeIndex][0];
    NSString * notes = frictInfo[swipeIndex][1];
    NSString * rating = frictInfo[swipeIndex][2];
    NSString * deleted = frictInfo[swipeIndex][3];
    
    nameText.text = name;
    [notesText setText:notes];
    ratingText.text = rating;
    
    //default hide status and button
    statusImage.hidden = true;
    searchButton.hidden = true;
    
    //default white text color
    notesText.textColor = [UIColor whiteColor];
    notesText.textAlignment = NSTextAlignmentJustified;
    
    if([rating intValue] == 0)
    {
        statusImage.image = [UIImage imageNamed:@"waiting.png"];
        statusImage.hidden = false;
        ratingText.hidden = true;
        notesText.textColor = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0f];
        notesText.textAlignment = NSTextAlignmentCenter;
        [notesText setText:[NSString stringWithFormat:@"%@ hasn't acknowledged this Frict yet", name]];
    }
    
    if([deleted intValue] == 1)
    {
        statusImage.image = [UIImage imageNamed:@"request_deleted.png"];
        statusImage.hidden = false;
        ratingText.hidden = true;
        notesText.textColor = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0f];
        notesText.textAlignment = NSTextAlignmentCenter;
        [notesText setText:[NSString stringWithFormat:@"%@ deleted this Frict", name]];
    }
    
    //give the option to search for a frict if the following conditions are met
    // - the frict hasn't been previously or isn't currently accepted
    // - this isn't a share frictlist
    if([rating intValue] == 0 && [deleted intValue] != 1)
    {
        
        //if this user if the creator of the frictlist and is looking at his uninvited mate
        if(swipeIndex == 1 && self.creator == 1)
        {
            statusImage.hidden = true;
            
            int status = [self canUserInviteMate];
            if(status == 1)
            {
                //user is able to search for this mate
                searchButton.hidden = false;
                [notesText setText:[NSString stringWithFormat:@"Click the Search button to find and share your Frictlist with %@!", name]];
                notesText.textColor = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0f];
                notesText.textAlignment = NSTextAlignmentCenter;
            }
            else if(status == 2)
            {
                //user has already sent a request to this mate
                searchButton.hidden = false;
                searchButton.enabled = false;
                searchButton.alpha = 0.5;
                [searchButton setTitle:@"Pending" forState:UIControlStateNormal];
                [notesText setText:[NSString stringWithFormat:@"You have already sent a request to %@", name]];
                notesText.textColor = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0f];
                notesText.textAlignment = NSTextAlignmentCenter;
            }
            else
            {
                statusImage.hidden = false;
            }
        }
    }
}

- (IBAction)creatorButtonPress:(id)sender
{
    swipeIndex = 0;
    [self checkDisplay];
}
- (IBAction)mateButtonPress:(id)sender
{
    swipeIndex = 1;
    [self checkDisplay];
}
- (IBAction)mapButtonPress:(id)sender
{
    swipeIndex = 2;
    [self checkDisplay];
}

@end
