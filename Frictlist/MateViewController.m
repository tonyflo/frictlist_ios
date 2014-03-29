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

@interface MateViewController ()

@end

@implementation MateViewController

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
	// Do any additional setup after loading the view.
    //UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButton target:self action:@selector(goBack:)];
    //self.navigationItem.leftBarButtonItem = backButton;
    //self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *frictlistButton = [[UIBarButtonItem alloc] initWithTitle:@"Frictlist" style:UIBarButtonItemStyleBordered target:self action:@selector(goToFrictlist)];
    [self.navigationItem setRightBarButtonItem:frictlistButton];
    
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
    }
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
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //set background
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg.gif"]];
    
    //get mate info
    SqlHelper *sql = [SqlHelper alloc];
    NSArray * mate_details =[sql get_mate:self.hu_id];
    
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
        int count = ((NSArray *)fl[0]).count;
        for(int i = 0; i < count; i++)
        {
            //sick logic
            counts[[fl[3][i] intValue]]++;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
