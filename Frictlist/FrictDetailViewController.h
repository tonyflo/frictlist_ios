//
//  FrictDetailViewController.h
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Frict.h"

@interface FrictDetailViewController : UIViewController

//image view
@property (strong, nonatomic) IBOutlet UIImageView *stateImageView;

@property (strong, nonatomic) IBOutlet UIImageView *pageController;

@property (nonatomic, strong) IBOutlet UILabel *stateNameLabel;
//@property (nonatomic, strong) NSString *stateName;
@property (nonatomic, strong) Frict *state;
@property (nonatomic, weak) IBOutlet UISegmentedControl *visitedSegmentedControl;

- (IBAction)changeVisited;

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;


@end
