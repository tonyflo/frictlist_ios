//
//  FrictViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/22/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrictViewController : UIViewController
{
    
    IBOutlet UIButton *editButton;
    IBOutlet UILabel *nameText;
    IBOutlet UILabel *mateNameText;
    IBOutlet UITextView *notesText;
    IBOutlet UITextView *mateNotesText;
    IBOutlet UILabel *dateRangeText;
    IBOutlet UIImageView *baseImageView;
    IBOutlet UILabel *scoreText;
    IBOutlet UILabel *ratingText;
    IBOutlet UILabel *mateRatingText;
}

@property (readwrite, assign) NSUInteger frict_id;
@property (readwrite, assign) NSUInteger mate_id;
@property (readwrite, assign) NSUInteger request_id;
@property (readwrite, assign) NSUInteger creator;
@property (readwrite, assign) NSUInteger accepted;


@end
