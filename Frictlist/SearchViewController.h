//
//  SearchViewController.h
//  Frictlist
//
//  Created by Tony Flo on 3/29/14.
//  Copyright (c) 2014 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SearchViewController : UIViewController  <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
    IBOutlet UIButton *emailButton;
    IBOutlet UIButton *textButton;
    IBOutlet UILabel *statusText;
    
    IBOutlet UILabel *resultsText;
}


@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)textPressed:(id)sender;
- (IBAction)emailPressed:(id)sender;

@property (readwrite, assign) NSUInteger mate_id;

@end
