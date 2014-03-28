//
//  MateViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/24/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MateViewController : UIViewController {
    
    IBOutlet UILabel *frictScore;
    IBOutlet UILabel *frictCount;
    IBOutlet UILabel *homeCount;
    IBOutlet UILabel *homeScore;
    IBOutlet UILabel *thirdCount;
    IBOutlet UILabel *thirdScore;
    IBOutlet UILabel *secondCount;
    IBOutlet UILabel *secondScore;
    IBOutlet UILabel *firstCount;
    IBOutlet UILabel *firstScore;
    IBOutlet UIButton *editButton;
}

@property (readwrite, assign) NSUInteger hu_id;

@end
