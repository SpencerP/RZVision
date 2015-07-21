//
//  ObjectDetector.h
//  HaarDetector
//
//  Created by Spencer Poff on 7/13/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectDetector : NSObject

- (void)detectAndMark:(cv::Mat &)rawImage;

@end
