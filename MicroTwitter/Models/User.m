//
//  User.m
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import "User.h"

@implementation User

- (void)setImageURLString:(NSString *)imageURLString
{
    if (imageURLString) {
        self.imageURL = [NSURL URLWithString:imageURLString];
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"username:%@, screenName:%@, imageURL:%@, tweets:%@", _userName, _screenName, [_imageURL absoluteString], _tweets];
}


@end
