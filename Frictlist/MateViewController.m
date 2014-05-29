//
//  MateViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "MateViewController.h"
#import "MateDetailViewController.h"
#import "FrictlistViewController.h"
#import "SqlHelper.h"
#import "SearchViewController.h"
#import "version.h"

#define NUM_SWIPE_ZERO_BASED (1)

@interface MateViewController ()

@end

@implementation MateViewController

@synthesize pinToRemember;
NSMutableArray * pinArray;

int curSwipeIndex = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)goToFrictlist
{
    [self performSegueWithIdentifier:@"showFrictlist" sender:self];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *frictlistButton = [[UIBarButtonItem alloc] initWithTitle:@"Frictlist" style:UIBarButtonItemStyleBordered target:self action:@selector(goToFrictlist)];
    [self.navigationItem setRightBarButtonItem:frictlistButton];
    
    mapView.delegate = self;
    
    fieldImage.userInteractionEnabled = NO;
    
    //disalow nav bar from hiding content
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]){ //if ios 7
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(void)goBack:(id)sender
{
    NSLog(@"go to root");
    //if frict doesn't exist, go back to frictlist view
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//send data from table view to detail view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"editMate"])
    {
        NSLog(@"edit mate segue");
        MateDetailViewController *destViewController = segue.destinationViewController;
        destViewController.hu_id = self.hu_id;
    }
    else if([segue.identifier isEqualToString:@"showFrictlist"])
    {
        NSLog(@"show frictlist segue");
        FrictlistViewController *destViewConroller = segue.destinationViewController;
        destViewConroller.hu_id = self.hu_id;
        destViewConroller.request_id = self.request_id;
        destViewConroller.accepted = self.accepted;
        destViewConroller.creator = self.creator;
    }
    else if([segue.identifier isEqualToString:@"searchMate"])
    {
        NSLog(@"search mate segue");
        SearchViewController *destViewConroller = segue.destinationViewController;
        destViewConroller.mate_id = self.hu_id;
    }
}

- (IBAction)swipeRight:(id)sender
{
    NSLog(@"Swipe right");
    curSwipeIndex--;
    if(curSwipeIndex < 0)
    {
        curSwipeIndex = 0;
    }
    
    [self checkDisplay];
}

- (IBAction)swipeLeft:(id)sender
{
    NSLog(@"Swipe left");
    curSwipeIndex++;
    if(curSwipeIndex > NUM_SWIPE_ZERO_BASED)
    {
        curSwipeIndex = NUM_SWIPE_ZERO_BASED;
    }
    
    [self checkDisplay]; 
}

-(void)checkDisplay
{
    if(curSwipeIndex < NUM_SWIPE_ZERO_BASED)
    {
        [self showFields];
        mapView.hidden = true;
        NSLog(@"hide map");
        [fieldSwitch setImage:[UIImage imageNamed:@"selected_1.png"] forState:UIControlStateNormal];
        [mapSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self hideFields];
        mapView.hidden = false;
        NSLog(@"show map");
        [fieldSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
        [mapSwitch setImage:[UIImage imageNamed:@"selected_1.png"] forState:UIControlStateNormal];
    }
}

-(void)hideFields
{
    firstCount.hidden = true;
    secondCount.hidden = true;
    thirdCount.hidden = true;
    homeCount.hidden = true;
    firstScore.hidden = true;
    secondScore.hidden = true;
    thirdScore.hidden = true;
    homeScore.hidden = true;
    fieldImage.hidden = true;
}

-(void)showFields
{
    firstCount.hidden = false;
    secondCount.hidden = false;
    thirdCount.hidden = false;
    homeCount.hidden = false;
    firstScore.hidden = false;
    secondScore.hidden = false;
    thirdScore.hidden = false;
    homeScore.hidden = false;
    fieldImage.hidden = false;
}

/*
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
    
    //float map_span_lat = mapView.region.span.latitudeDelta;
    //float map_span_lon = mapView.region.span.longitudeDelta;
 
    //if(region.span.latitudeDelta > map_span_lat || region.span.latitudeDelta <= 0.0)
    //{
     //   //invalid latitude span
     //   NSLog(@"Invalid span latitude %f", region.span.latitudeDelta);
     //   region.span.latitudeDelta = map_span_lat;
    //}
    
    //if(region.span.longitudeDelta >= map_span_lon || region.span.longitudeDelta <= 0.0)
    //{
    //    //invalid longitude span
    //    NSLog(@"Invalid span longitude %f", region.span.longitudeDelta);
    //    region.span.longitudeDelta = map_span_lon;
    //}
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
    NSLog(@"Done zooming");
}
*/

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360
//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations
{
    NSArray *annotations = mapView.annotations;
    int count = [mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    //jump to the edit view if this is a new row in the list
    if(self.hu_id <=0)
    {
        NSLog(@"moving on");
        [self performSegueWithIdentifier:@"editMate" sender:editButton];
    }
    else
    {
        NSLog(@"staying here");
        NSLog(@"Mate ID: %d", self.hu_id);
        
        [self populateMapWithPins];
    }
}

-(void)populateMapWithPins
{
    for(int i = 0; i < pinArray.count; i++)
    {
        [mapView addAnnotation:[pinArray objectAtIndex:i]];
    }
    
    //[self zoomToFitMapAnnotations];
    [self zoomMapViewToFitAnnotations];
}

-(void)viewWillAppear:(BOOL)animated
{
    //reset swipe index
    curSwipeIndex = 0;
    
    //set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
    
    SqlHelper *sql = [SqlHelper alloc];
    NSArray * mate_details;
    
    //get mate info
    if(self.creator == 0)
    {
        NSLog(@"Accpted this incomming request");
        //if coming from an accepted incomming request row, use the request id to get the data for the accepted mate
        mate_details=[sql get_accepted:self.request_id];
    }
    else
    {
        //if coming from a personal row, use the mate id to get the data for this mate
        mate_details=[sql get_mate:self.hu_id];
    }
     
    
    //get mate name
    NSString *mate_name;
    if(mate_details[0] == NULL || [mate_details[0] isEqual: @""])
    {
        
        mate_name = @"New Mate";
    }
    else
    {
        mate_name = [NSString stringWithFormat:@"%@ %@", mate_details[0], mate_details[1]];
    }
    
    //set back button text
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: mate_name
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];
    
    //set title
    self.title = mate_name;
    
    int counts[4] = {0,0,0,0};
    
    //get frict bases count
    NSArray *fl = [sql get_frict_list:self.hu_id];
    
    if(fl != NULL)
    {
        //init pin array
        pinArray = [[NSMutableArray alloc] init];
        
        int count = ((NSArray *)fl[0]).count;
        for(int i = 0; i < count; i++)
        {
            //sick logic to determine score and base count
            counts[[fl[3][i] intValue]]++;
            
            //add pin to map
            MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
            CLLocationCoordinate2D pin;
            NSLog(@"lat: %f lon: %f", [fl[5][i] doubleValue], [fl[6][i] doubleValue]);
            pin.latitude = [fl[5][i] doubleValue];
            pin.longitude = [fl[6][i] doubleValue];;
            annot.coordinate = pin;
            if(annot != nil && annot != NULL)
            {
                [pinArray addObject:annot];
            }
        }
    }
    
    //determine scores
    int scores[4] ={0,0,0,0};
    scores[0]=counts[0] * 1;
    scores[1]=counts[1] * 3;
    scores[2]=counts[2] * 5;
    scores[3]=counts[3] * 9;

    //display the counts
    firstCount.text = [NSString stringWithFormat:@"%d",counts[0]];
    firstCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:17.0];
    secondCount.text = [NSString stringWithFormat:@"%d",counts[1]];
    secondCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:15.0];
    thirdCount.text = [NSString stringWithFormat:@"%d",counts[2]];
    thirdCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:17.0];
    homeCount.text = [NSString stringWithFormat:@"%d",counts[3]];
    homeCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:19.0];
    
    //display the scores
    firstScore.text = [NSString stringWithFormat:@"%d",scores[0]];
    firstScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:25.0];
    secondScore.text = [NSString stringWithFormat:@"%d",scores[1]];
    secondScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:20.0];
    thirdScore.text = [NSString stringWithFormat:@"%d",scores[2]];
    thirdScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:25.0];
    homeScore.text = [NSString stringWithFormat:@"%d",scores[3]];
    homeScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:30.0];
    
    //calculate totals
    int totalScore = 0;
    int totalCount = 0;
    for(int i = 0; i < 4; i++)
    {
        totalScore += scores[i];
        totalCount += counts[i];
    }
    
    //display the total score and count
    frictCount.text = [NSString stringWithFormat:@"%d", totalCount];
    frictCount.font = [UIFont fontWithName:@"DBLCDTempBlack" size:27];
    frictScore.text = [NSString stringWithFormat:@"%d", totalScore];
    frictScore.font = [UIFont fontWithName:@"DBLCDTempBlack" size:27];
    
    if(self.creator == 1)
    {
        //disable sending multiple requests or editing a mate by checking
        // - if there's a request uid: mate_details[4]
        // - if accepted is pending (0) or accepted (1). we allow to re-rearch upon a rejection (-1)
        if([mate_details[4] intValue] > 0)
        {
            if([mate_details[3] intValue] == 1)
            {
                searchButton.hidden = true;
                editButton.hidden = true;
                
                sharedInfo.hidden = false;
                sharedText.hidden = false;
            }
            else if([mate_details[3] intValue] == 0)
            {
                searchButton.hidden = true;
                editButton.hidden = true;
                
                sharedInfo.hidden = false;
                sharedText.hidden = false;
                [sharedText setText:@"Pending"];
            }
        }
    }
    else
    {
        searchButton.hidden = true;
        editButton.hidden = true;
        
        sharedInfo.hidden = false;
        sharedText.hidden = false;
    }

}

- (IBAction)sharedInfoPress:(id)sender
{SqlHelper *sql = [SqlHelper alloc];
    NSArray * mate_details;
    
    //get mate info
    if(self.creator == 0)
    {
        NSLog(@"Accpted this incomming request");
        //if coming from an accepted incomming request row, use the request id to get the data for the accepted mate
        mate_details=[sql get_accepted:self.request_id];
    }
    else
    {
        //if coming from a personal row, use the mate id to get the data for this mate
        mate_details=[sql get_mate:self.hu_id];
    }
    
    
    //get mate name
    NSString *mate_name = mate_details[0];
    
    if([sharedText.text isEqualToString:@"Pending"])
    {
        [self showPendingInfoDialog:mate_name];
    }
    else
    {
        [self showSharedInfoDialog:mate_name];
    }
    
}

//explain what a shared mate is
- (void)showSharedInfoDialog:(NSString *)name
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"What does Shared mean?"];
    [alert setMessage:[NSString stringWithFormat:@"All Fricts associated with this Mate are visible to both you and %@.", name]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

//explain what a pending mate is
- (void)showPendingInfoDialog:(NSString *)name
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"What does Pending mean?"];
    [alert setMessage:[NSString stringWithFormat:@"You are waiting for %@ to respond to the request that you sent.", name]];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Okay"];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fieldSwitchSelected:(id)sender
{
    curSwipeIndex = 0;
    [fieldSwitch setImage:[UIImage imageNamed:@"selected_1.png"] forState:UIControlStateNormal];
    [mapSwitch setImage:[UIImage imageNamed:@"selected_0.png"] forState:UIControlStateNormal];
    [self checkDisplay];
}

- (IBAction)mapSwitchSelected:(id)sender
{
    curSwipeIndex = 1;
    [self checkDisplay];
}
@end
