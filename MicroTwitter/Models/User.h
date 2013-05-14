//
//  User.h
//  MicroTwitter
//
//  Created by Luis Gutierrez on 11-05-13.
//  Copyright (c) 2013 Trotamund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSArray *tweets;

- (void) setImageURLString:(NSString *)imageURLString;

@end
