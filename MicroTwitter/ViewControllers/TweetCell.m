//
//  TweetCell.m
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import "TweetCell.h"


#import "User.h"

#define defaultHeight 70
#define separation 5
#define usernameHeight 20
#define usernameWidth 230



@interface TweetCell()
{
    CGFloat calculatedHeight;
}

@end

@implementation TweetCell


- (void)awakeFromNib
{
    _userImageView.layer.cornerRadius = 8;
    _userImageView.layer.masksToBounds = YES;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setObjectToShow:(id)object user:(User *)user
{
    _usernameLabel.text = user.userName;
    _screenNameLabel.text = user.screenName;
    _tweettextLabel.text = [object valueForKey:@"text"];
//    _usernameLabel.text = [object valueForKey:@""];
    CGSize size = [_tweettextLabel.text sizeWithFont:_tweettextLabel.font forWidth:300 lineBreakMode:NSLineBreakByWordWrapping];
    
    calculatedHeight = size.height + CGRectGetHeight(_usernameLabel.frame) +  (3 * separation);
    
}

- (CGFloat) heightCalculated
{
    return calculatedHeight;
}

+ (CGFloat)calculateHeightForText:(NSString *)text
{
    static UIFont *font = nil;
    
    if (!font) {
        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    }
    
    
    CGSize virtualSize = CGSizeMake(usernameWidth, 1000);
    CGSize size = [text sizeWithFont:font constrainedToSize:virtualSize lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat calculatedHeight = usernameHeight + (3 * separation) + size.height;
    
    return MAX(calculatedHeight, defaultHeight);
}

+ (CGFloat)calculateHeight:(CGFloat)height
{
    
    CGFloat calculatedHeight = usernameHeight + (3 * separation) + height;
    
    return MAX(calculatedHeight, defaultHeight);
}

+ (CGFloat) userNameWidth
{
    return usernameWidth;
}

+ (CGFloat)parcialHeight
{
    CGFloat parcialHeight = usernameHeight + (3 * separation);
    return parcialHeight;
}

@end
