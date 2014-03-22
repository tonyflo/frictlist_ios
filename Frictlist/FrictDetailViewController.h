//
//  FrictDetailViewController.h
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrictDetailViewController : UIViewController

//image view

@property (nonatomic, strong) IBOutlet UILabel *stateNameLabel;
@property (readwrite, assign) NSUInteger hu_id;
@property (nonatomic, weak) IBOutlet UISegmentedControl *visitedSegmentedControl;

- (IBAction)changeVisited;


@end
