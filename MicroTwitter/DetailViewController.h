//
//  DetailViewController.h
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;


@interface DetailViewController : UIViewController

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

- (void) setUser:(User *)user tweetIndexPath:(NSIndexPath *)indexPath;

@end
