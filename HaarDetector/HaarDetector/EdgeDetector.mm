//
//  EdgeDetector.m
//  HaarDetector
//
//  Created by Spencer Poff on 7/21/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//
//  Adapted from the OpenCV Canny Edge Detector tutorial: http://docs.opencv.org/doc/tutorials/imgproc/imgtrans/canny_detector/canny_detector.html

#import "EdgeDetector.h"

#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>

#import <stdlib.h>
#import <stdio.h>

using namespace cv;

static double thresholdRatio = 3;

@implementation EdgeDetector

+ (void)detectAndOverlay:(Mat &)rawImage withThreshold:(NSInteger)threshold
{
    // Convert the image to grayscale
    Mat grayImage;
    cvtColor(rawImage, grayImage, CV_BGR2GRAY);
    
    /// Reduce noise with a 3x3 kernel
    blur(grayImage, grayImage, cv::Size(3, 3));
    
    // Write output to original image
    double dblThreshold = threshold;
    Canny(grayImage, rawImage, dblThreshold, dblThreshold*thresholdRatio);
}

@end
