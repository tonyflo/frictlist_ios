//
//  FrictDetailViewController.m
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import "FrictDetailViewController.h"
#import "PlistHelper.h"

@interface FrictDetailViewController ()

@end

@implementation FrictDetailViewController
{
   
}

@synthesize stateNameLabel;
@synthesize visitedSegmentedControl;
@synthesize hu_id;

//globals are bad
static int imageIndex = 0;

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
    
    
    //set the title
    self.title = [NSString stringWithFormat:@"%d", hu_id];
}

//change visited boolean value via the segmented control
- (IBAction)changeVisited
{
//    BOOL visited;
//    if(visitedSegmentedControl.selectedSegmentIndex == 0)
//    {
//        visited = 0;
//    }
//    else
//    {
//        visited = 1;
//    }
//    
//    PlistHelper * plist = [PlistHelper alloc];
//    NSString * updated_visited = [[plist getIvisited] stringByReplacingCharactersInRange:NSMakeRange(state.primaryKey, 1) withString:[NSString stringWithFormat:@"%d",visited]];
//    [plist setIvisited:updated_visited];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
