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
    NSArray *images;
}

@synthesize stateImageView;
@synthesize pageController;
@synthesize state;
@synthesize stateNameLabel;
@synthesize visitedSegmentedControl;

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
    
    //set the segmented control to the appropriate side depending on visited or not
    if(state.getVisited == TRUE)
    {
        visitedSegmentedControl.selectedSegmentIndex = 1;
    }
    else
    {
        visitedSegmentedControl.selectedSegmentIndex = 0;
    }
    
    //set the label text with the selected state
    NSString *visitedQuestion = @"Have you visited ";
    visitedQuestion = [[visitedQuestion stringByAppendingString:state.getName] stringByAppendingString:@"?"];
    stateNameLabel.text = visitedQuestion;
    
    //path to each image (plate, flag, quarter
    NSString *statePlate = [[@"plates/" stringByAppendingString:[state.getName.lowercaseString stringByAppendingString:@"Plate.jpg"]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *stateFlag = [[@"flags/" stringByAppendingString:[state.getName.lowercaseString stringByAppendingString:@"Flag.jpg"]]stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *stateCoin = [[@"coins/" stringByAppendingString:[state.getName.lowercaseString stringByAppendingString:@"Coin.gif"]]stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *stateOutline = [[@"outlines/" stringByAppendingString:[state.getName.lowercaseString stringByAppendingString:@"-outline.png"]]stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *stateSeal = [[@"seals/" stringByAppendingString:[state.getName.lowercaseString stringByAppendingString:@"-seal.png"]]stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    //populate image array
    images = [[NSArray alloc] initWithObjects:statePlate, stateFlag, stateCoin, stateOutline, stateSeal, nil];

    //show the previously shown image when the view loads
    stateImageView.image = [UIImage imageNamed:[images objectAtIndex:imageIndex]];
    
    //update page controller
    [self updatePageController];
    
    //set the title
    self.title = state.getName;
}

-(void) updatePageController
{
    //update the page controller
    NSString * indexString = [NSString stringWithFormat:@"%d", imageIndex];
    NSString * pageImage = [@"pages/page-" stringByAppendingString:[indexString stringByAppendingString:@".png"]];
    //NSLog(@"%@", pageImage);
    pageController.image = [UIImage imageNamed:pageImage];
}

//change visited boolean value via the segmented control
- (IBAction)changeVisited
{
    BOOL visited;
    if(visitedSegmentedControl.selectedSegmentIndex == 0)
    {
        visited = 0;
    }
    else
    {
        visited = 1;
    }
    
    PlistHelper * plist = [PlistHelper alloc];
    NSString * updated_visited = [[plist getIvisited] stringByReplacingCharactersInRange:NSMakeRange(state.primaryKey, 1) withString:[NSString stringWithFormat:@"%d",visited]];
    [plist setIvisited:updated_visited];
}

//swipe left or right will change the image (plate, flag, quarter)
- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *) sender direction];
    
    switch (direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
            //NSLog(@"Left");
            imageIndex++;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            //NSLog(@"Right");
            imageIndex--;
            break;
        default:
            break;
    }
    
    //circular array logic
    imageIndex = (imageIndex < 0) ? ([images count] - 1) : (imageIndex % [images count]);
    
    //update image
    stateImageView.image = [UIImage imageNamed:[images objectAtIndex:imageIndex]];
    stateImageView.contentMode = UIViewContentModeCenter;
    stateImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //update page controller
    [self updatePageController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
