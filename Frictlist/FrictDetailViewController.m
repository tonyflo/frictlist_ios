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

@synthesize visitedSegmentedControl;
@synthesize hu_id;


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
    
    firstNameText.delegate = self;
    lastNameText.delegate = self;
    notes.delegate = self;
    
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [scrollView setContentOffset:CGPointMake(0,textView.center.y) animated:YES];
}

// called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if(textField.tag == 1) {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
    } else if (nextResponder) {
        [scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
        NSLog(@"a");
    } else {
        NSLog(@"b");
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}

-(BOOL)textView:(UITextView *)textView  shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)savePressed:(id)sender
{
    
}



@end
