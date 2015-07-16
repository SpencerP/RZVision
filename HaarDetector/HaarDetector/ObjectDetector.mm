//
//  ObjectDetector.m
//  HaarDetector
//
//  Created by Spencer Poff on 7/13/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ObjectDetector.h"

#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/imgproc/imgproc.hpp>

#import <iostream>
#import <stdio.h>

using namespace std;
using namespace cv;

static NSString *cascadeFileName = @"haarcascade_frontalface_default";

@interface ObjectDetector () {
    CascadeClassifier classifier;
}

@end

@implementation ObjectDetector

- (instancetype)init
{
    self = [super init];
    
    if ( self ) {
        NSString* cascadePath = [[NSBundle mainBundle]
                                 pathForResource:cascadeFileName
                                 ofType:@"xml"];
        
        if ( !classifier.load([cascadePath UTF8String]) ) {
            NSLog(@"Error loading cascade file.");
        }
    }
    
    return self;
}

- (cv::Mat &)detectAndMark:(cv::Mat &)rawImage
{
    std::vector<cv::Rect> faces;
    cv::Mat greyImage;
    
    cvtColor(rawImage, greyImage, CV_BGR2GRAY);
    equalizeHist(greyImage, greyImage);
    
    classifier.detectMultiScale(greyImage, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    
    for(size_t i = 0; i < faces.size(); i++) {
        cv::Point upperLeft(faces[i].x, faces[i].y);
        cv::Point lowerRight(faces[i].x + faces[i].width, faces[i].y + faces[i].height);
        rectangle(rawImage, upperLeft, lowerRight, Scalar(57, 255, 20), 2);
    }
    
    return rawImage;
}

@end
