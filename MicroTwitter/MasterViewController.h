//
//  MasterViewController.h
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <UISearchBarDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
