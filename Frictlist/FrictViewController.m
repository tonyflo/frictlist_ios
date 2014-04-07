//
//  FrictViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/22/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "FrictViewController.h"
#import "FrictDetailViewController.h"
#import "PlistHelper.h"
#import "SqlHelper.h"

@interface FrictViewController ()

@end

@implementation FrictViewController

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
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Frict id: %d", self.frict_id);
    //jump to the edit view if this is a new row in the list
    if(self.frict_id <= 0)
    {
        NSLog(@"going to frict detail view");
        [self performSegueWithIdentifier:@"editFrict" sender:editButton];
    }
    else{
        NSLog(@"Staying at frict view");
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
}

-(void) viewWillAppear:(BOOL)animated
{
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
        creator = [frict[7] intValue];
        
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
    
    //creator of frict goes on the left
    
    //creator: the creator of the frict | 1 if the creator of the frictlist, 0 otherwise
    //self.creator: the creator of the frictlist | 1 if this user, 0 otherwise
    if(creator == 1 && self.creator == 1)
    {
        //I created this frict and I created this frictlist
        NSLog(@"I created this frict and I created this frictlist");//

        //left
        nameText.text = userFirstName;
        [notesText setText:notesStr];
        ratingText.text = [NSString stringWithFormat:@"%d",rating];
        
        //right
        mateNameText.text = mateFirstName;
        [mateNotesText setText:mateNotesStr];
        mateRatingText.text = [NSString stringWithFormat:@"%d",mateRating];
    }
    else if(creator == 0 && self.creator == 1)
    {
        //My mate created this frict but I created this frictlist
        NSLog(@"My mate created this frict but I created this frictlist");////

        //left
        nameText.text = mateFirstName;
        [notesText setText:mateNotesStr];
        ratingText.text = [NSString stringWithFormat:@"%d",mateRating];

        
        //right
        mateNameText.text = userFirstName;
        [mateNotesText setText:notesStr];
        mateRatingText.text = [NSString stringWithFormat:@"%d",rating];        
    }
    else if(creator == 1 && self.creator == 0)
    {
        //My mate created this frict and my mate created the frictlist
        NSLog(@"My mate created this frict and my mate created the frictlist");//
        
        NSArray * accepted = [sql get_accepted:self.request_id];
        mateFirstName = accepted[0];
        mateLastName = accepted[1];
        
        //left
        nameText.text = mateFirstName;
        [notesText setText:notesStr];
        ratingText.text = [NSString stringWithFormat:@"%d",rating];
        
        //right
        mateNameText.text = userFirstName;
        [mateNotesText setText:mateNotesStr];
        mateRatingText.text = [NSString stringWithFormat:@"%d",mateRating];
    }
    else if(creator == 0 && self.creator == 0)
    {
        //I created this frict but my mate created the frictlist
        NSLog(@"I created this frict but my mate created the frictlist");////
        
        NSArray * accepted = [sql get_accepted:self.request_id];
        mateFirstName = accepted[0];
        mateLastName = accepted[1];
        
        //left
        nameText.text = userFirstName;
        [notesText setText:mateNotesStr];
        ratingText.text = [NSString stringWithFormat:@"%d",mateRating];
        
        //right
        mateNameText.text = mateFirstName;
        [mateNotesText setText:notesStr];
        mateRatingText.text = [NSString stringWithFormat:@"%d",rating];
    }
    else
    {
        //todo, should never happen, throw error code
        NSLog(@"BAD");
    }
    
        
    /*
    //check if this is an existing hookup
    //this mean that we have to display the data for edit
    if(self.frict_id > 0)
    {
        SqlHelper *sql = [SqlHelper alloc];
        NSArray *mate;
        //if this is an incomming request that has been accepted, get the data for the mate from the accepted table
        if(self.accepted == 1)
        {
            mate = [sql get_accepted:self.request_id];
        }
        else
        {
            mate = [sql get_mate:self.mate_id];    
        }
        
        
        
        
        
        
        NSLog(@"okay frict id is %d", self.frict_id);
        firstName = mate[0];
        lastName = mate[1];
        if(self.accepted)
        {
            gender = [mate[3] intValue];
        }
        else
        {
            gender = [mate[2] intValue];
        }
        
        

        
        //set name
        //nameText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        //set gender
        //NSString *genderStr = [NSString stringWithFormat:@"gender_%d.png", gender];
        //genderImageView.image = [UIImage imageNamed:genderStr];
        //NSLog(@"GENDER IMAGE: %@", genderStr);
        

        
        // display rating
        ratingText.text = [NSString stringWithFormat:@"%d",rating ];
        
        //set notes
        [notesText setText:notesStr];
        
*/

    self.title = [NSString stringWithFormat:@"%@ %@", mateFirstName, mateLastName];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

@end
