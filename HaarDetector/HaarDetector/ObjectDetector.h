//
//  ObjectDetector.h
//  HaarDetector
//
//  Created by Spencer Poff on 7/13/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectDetector : NSObject

- (cv::Mat &)detectAndMark:(cv::Mat &)rawImage;

@end
