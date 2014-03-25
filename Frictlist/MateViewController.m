//
//  MateViewController.m
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import "MateViewController.h"
#import "MateDetailViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
    
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
        MateDetailViewController *destViewController = segue.destinationViewController;
        
        destViewController.hu_id = self.hu_id;
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
    }
}

-(void)viewWillAppear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
