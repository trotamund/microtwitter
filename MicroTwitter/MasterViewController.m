//
//  MasterViewController.m
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import "MasterViewController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import <AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "DetailViewController.h"
#import "Models/Tweet.h"
#import "Models/User.h"
#import "ViewControllers/TweetCell.h"


@interface MasterViewController () {
    NSMutableArray *_objects;
    
    UIFont *tweetFont;
}

@property (nonatomic) ACAccountStore *accountStore;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) User *user;
@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Cuenta", @"Micro Twitter");
        
        _user = nil;
        _username = nil;
        
        tweetFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        
        _accountStore = [[ACAccountStore alloc] init];

    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    self.navigationController.view.layer.cornerRadius = 10;
    self.navigationController.view.layer.masksToBounds = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(fetchTimeline) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _user.tweets.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        
        UINib *theNib = [UINib nibWithNibName:CellIdentifier bundle:nil];
        cell = [[theNib instantiateWithOwner:self options:nil] objectAtIndex:0];        
    }

    Tweet *tweet = _user.tweets[indexPath.row];
    
    [cell setObjectToShow:tweet user:_user];
    
    [cell.userImageView setImageWithURL:_user.imageURL placeholderImage:nil];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!_user) {
        return 70;
    }
    
    Tweet *tweet = _user.tweets[indexPath.row];
    NSString *text = tweet.text;
    
    return [TweetCell calculateHeightForText:text];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailViewController) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    }
    
    [self.detailViewController setUser:_user tweetIndexPath:indexPath];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}


#pragma mark - SearchBar Controller Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    if ([searchBar.text length] == 0) {
        return;
    }
    self.username = searchBar.text;
    searchBar.placeholder = _username;
    
    [self.searchDisplayController setActive:NO animated:YES];
    
    [self showHUD];
    
    [self fetchInfoForUser:_username];
}

#pragma mark - Tweeter Methods

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void) fetchInfoForUser:(NSString *)username
{
    if ([self userHasAccessToTwitter]) {

        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 
                 NSDictionary *params = @{@"screen_name" : username};                 
                 
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {

                     if (responseData) {
                         
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             
                             
                             NSError *jsonError;
                             NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                     options:NSJSONReadingAllowFragments
                                                                                       error:&jsonError];

                             if (userInfo) {
                                 
                                 User *user = [[User alloc] init];
                                 if ([userInfo valueForKey:@"screen_name"]) {
                                     user.screenName = [@"@" stringByAppendingString:[userInfo valueForKey:@"screen_name"]];
                                 }
                                
                                 user.userName = [userInfo valueForKey:@"name"];
                                 [user setImageURLString:[userInfo valueForKey:@"profile_image_url_https"]];
                                 
                                 _user = user;
                                 
                                 [self fetchTimelineForUser:_user.screenName];
                               
                             }
                             else {
                                 // Our JSON deserialization went awry
                                 [self.refreshControl endRefreshing];
                                 [self hideHUD];
                             }
                         }
                         else {
                             // The server did not respond successfully... were we rate-limited?
                             [self.refreshControl endRefreshing];
                             [self cleanAllView];
                             
                         }
                     }
                     else
                     {
                         [self.refreshControl endRefreshing];
                         [self cleanAllView];
                     }
                 }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
                 [self.refreshControl endRefreshing];
                 [self cleanAllView];
             }
         }];
    }
}


- (void) fetchTimeline
{
    if (_username) {
        [self fetchTimelineForUser:_username];
    }
    else
    {
        [self.refreshControl endRefreshing];
    }
}

- (void)fetchTimelineForUser:(NSString *)username
{
    if (!username) {
        NSLog(@"user name nil");
        [self.refreshControl endRefreshing];
        return;
    }
    
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [self.accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 
                 NSDictionary *params = @{@"screen_name" : username,
                                          @"include_rts" : @"0",
                                          @"trim_user" : @"1" };
                 
                 
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             
                             NSError *jsonError;
                             NSArray *timelineData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                          options:NSJSONReadingAllowFragments
                                                                                            error:&jsonError];
                             
                             if (timelineData) {
                                 __block NSMutableArray *temp = [NSMutableArray arrayWithCapacity:[timelineData count]];
                                 
                                 [timelineData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                     Tweet *tweet = [self parseDictionary:obj];
                                     
                                     [temp addObject:tweet];
                                 }];
                                 
                                 
                                 if (_user) {
                                     _user.tweets = temp;
                                 }
                                                                  
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     self.title = _user.screenName;
                                     [self.tableView reloadData];
                                     [self.refreshControl endRefreshing];
                                     [self hideHUD];
                                 });
                                 
                                 
                             }
                             else {
                                 // Our JSON deserialization went awry
                                 NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                                 [self.refreshControl endRefreshing];
                                 [self cleanAllView];
                             }
                         }
                         else {
                             // The server did not respond successfully... were we rate-limited?
                             NSLog(@"The response status code is %d", urlResponse.statusCode);
                             [self.refreshControl endRefreshing];
                             [self cleanAllView];

                         }
                     }
                 }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
                 [self cleanAllView];
             }
         }];
    }
}


- (Tweet *) parseDictionary:(NSDictionary *)dictionary
{
    Tweet *tweet = [[Tweet alloc] init];
    
    tweet.tweetID = [dictionary valueForKey:@"id"];
    tweet.text = [dictionary valueForKey:@"text"];
    
    return tweet;
}


#pragma mark - Other Methods

- (void) cleanAllView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _user = nil;
        self.title = @"Cuenta";
        
        [self.searchDisplayController.searchBar setText:@""];
        [self.searchDisplayController.searchBar setPlaceholder:@"input username"];
        
        [self.tableView reloadData];
        
        [self hideHUD];
    });

}

- (void) showHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Downloading tweets...";
}

- (void) hideHUD
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
}

@end
