//
//  DetailViewController.m
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import "DetailViewController.h"

#import <AFNetworking/AFNetworking.h>

#import "Models/User.h"
#import "Models/Tweet.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item



- (void)setUser:(User *)user tweetIndexPath:(NSIndexPath *)indexPath
{
    self.user = user;
    self.indexPath = indexPath;
    
    [self configureView];
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.user) {
        self.usernameLabel.text = _user.userName;
        self.screenNameLabel.text = _user.screenName;
        
        Tweet *tweet = _user.tweets[_indexPath.row];
        self.tweetLabel.text = tweet.text;
        
        [self.userImageView setImageWithURL:_user.imageURL];
        
        
        CGSize virtualSize = CGSizeMake(CGRectGetWidth(_tweetLabel.frame), 1000);
        CGSize size = [tweet.text sizeWithFont:_tweetLabel.font constrainedToSize:virtualSize lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect frame = _tweetLabel.frame;
        frame.size.height = size.height;
        
        _tweetLabel.frame = frame;
        
        
        NSLog(@"%@",self.tweetLabel.text);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _userImageView.layer.cornerRadius = 8;
    _userImageView.layer.masksToBounds = YES;
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Tweet", @"Detail");
    }
    return self;
}
							
@end
