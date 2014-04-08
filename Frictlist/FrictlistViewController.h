//
//  FrictlistViewController.h
//  Frictlist
//
//  Created by Tony Flo on 6/16/13.
//  Copyright (c) 2013 FLooReeDA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrictlistViewController : UITableViewController
//@interface FrictlistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (readwrite, assign) NSUInteger hu_id;
@property (readwrite, assign) NSUInteger request_id;
@property (readwrite, assign) NSUInteger creator;
@property (readwrite, assign) NSUInteger accepted;

@end
