//
//  TweetCell.h
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface TweetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweettextLabel;

- (void) setObjectToShow: (id)object user:(User *)user;
- (CGFloat) heightCalculated;

+ (CGFloat) calculateHeightForText:(NSString *)text;
+ (CGFloat) calculateHeight:(CGFloat)height;
+ (CGFloat) userNameWidth;
+ (CGFloat) parcialHeight;

@end
