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

NSString *firstName;
NSString *lastName;
int gender;
int base;
NSString * fromDate;
int rating;
NSString * notesStr;

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
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    //check if this is an existing hookup
    //this mean that we have to display the data for edit
    if(self.frict_id > 0)
    {
        SqlHelper *sql = [SqlHelper alloc];
        NSArray *mate;
        //if this is an incomming request that has been accepted, get the data for the mate from the accepted table
        if(self.accepted)
        {
            mate = [sql get_accepted:self.request_id];
        }
        else
        {
            mate = [sql get_mate:self.mate_id];    
        }
        NSArray *frict = [sql get_frict:self.frict_id];
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
        
        
        fromDate = frict[0];
        rating = [frict[1] intValue];
        base = [frict[2] intValue];
        notesStr = frict[3];
        
        //set name
        nameText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        //set gender
        NSString *genderStr = [NSString stringWithFormat:@"gender_%d.png", gender];
        genderImageView.image = [UIImage imageNamed:genderStr];
        NSLog(@"GENDER IMAGE: %@", genderStr);
        
        //set base
        NSString *baseStr = [NSString stringWithFormat:@"base_%d.png", base + 1];
        baseImageView.image = [UIImage imageNamed:baseStr];
        
        //set score for this frict
        int score[4] = {1, 3, 5, 9};
        scoreText.text = [NSString stringWithFormat:@"%d", score[base]];
        scoreText.font = [UIFont fontWithName:@"DBLCDTempBlack" size:28.0];
        
        // display rating
        ratingText.text = [NSString stringWithFormat:@"%d",rating ];
        
        //set notes
        [notesText setText:notesStr];
        
        //show date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM dd, YYYY"];
        NSDateFormatter *converter = [[NSDateFormatter alloc] init];
        [converter setDateFormat:@"yyyy-MM-dd"];
        dateRangeText.text = [formatter stringFromDate:[converter dateFromString:fromDate]];
        
        //set the title
        self.title = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    else
    {
        //set the title
        self.title = @"New Frict";
    }

    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
}

@end
