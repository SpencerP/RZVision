//
//  EdgeDetector.h
//  HaarDetector
//
//  Created by Spencer Poff on 7/21/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EdgeDetector : NSObject

+ (void)detectAndOverlay:(cv::Mat &)rawImage withThreshold:(NSInteger)threshold;

@end
