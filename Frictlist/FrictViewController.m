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

@interface FrictViewController ()

@end

@implementation FrictViewController

NSString *firstName;
NSString *lastName;
int gender;
int base;
NSString * fromDate;
NSString * toDate;
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
    if(self.frict_id <=0)
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
        PlistHelper *plist = [PlistHelper alloc];
        NSMutableArray * huidArray = [plist getHuIdArray];
        NSMutableArray * frictidArray = [plist getFrictIdArray];
        NSMutableArray * fnArray = [plist getFirstNameArray];
        NSMutableArray * lnArray = [plist getLastNameArray];
        NSMutableArray * genderArray = [plist getGenderArray];
        NSMutableArray * baseArray = [plist getBaseArray];
        NSMutableArray * fromArray = [plist getFromArray];
        NSMutableArray * toArray = [plist getToArray];
        NSMutableArray * notesArray = [plist getNoteArray];
        
        int row = 0;
        //get local index of mate id
        for(; row < huidArray.count; row++)
        {
            if(self.mate_id == [[huidArray objectAtIndex:row] intValue])
            {
                break;
            }
        }

        int col = 0;
        //get local index of frict id
        for(; col < frictidArray.count; col++)
        {
            if(self.frict_id == [frictidArray[row][col] intValue])
            {
                break;
            }
        }
        NSLog(@"row %d col %d", row, col);

        firstName = fnArray[row];
        NSLog(@"%@", firstName);
        lastName = lnArray[row];
        NSLog(@"%@", lastName);
        gender = [genderArray[row] intValue];
        NSLog(@"%d", gender);
        base = [baseArray[row][col] intValue];
        NSLog(@"%d", base);
        fromDate = fromArray[row][col];
        NSLog(@"%@", fromDate);
        toDate = toArray[row][col];
        NSLog(@"%@", toDate);
        notesStr = notesArray[row][col];
        NSLog(@"%@", notesStr);
        
        //set name
        nameText.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        //set gender
        NSString *genderStr = [NSString stringWithFormat:@"gender_%d.png", [genderArray[row] intValue]];
        genderImageView.image = [UIImage imageNamed:genderStr];
        NSLog(@"GENDER IMAGE: %@", genderStr);
        
        //set base
        NSString *baseStr = [NSString stringWithFormat:@"base_%d.png", [baseArray[row][col] intValue] + 1];
        baseImageView.image = [UIImage imageNamed:baseStr];
        
        
        //set notes
        [notesText setText:notesStr];
        
        //dates
        if([toDate isEqualToString: @"0000-00-00"])
        {
            //current
            dateRangeText.text = [NSString stringWithFormat:@"Fricting since %@", fromDate];
        }
        else
        {
            if([fromDate isEqualToString:toDate])
            {
                //one night stand
                dateRangeText.text = [NSString stringWithFormat:@"One night stand on %@", [toDate description]];
            }
            else
            {
                //ended in past
                dateRangeText.text = [NSString stringWithFormat:@"%@ to %@", fromDate, toDate];
            }

        }
        
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
