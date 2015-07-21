//
//  ViewController.m
//  HaarDetector
//
//  Created by Spencer Poff on 7/13/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"

#import "ObjectDetector.h"
#import "EdgeDetector.h"

#import <opencv2/highgui/cap_ios.h>

@interface ViewController () <CvVideoCameraDelegate> {
    ObjectDetector *objDetector;
}

@property (weak, nonatomic) IBOutlet UIImageView *videoView;
@property (strong, nonatomic) CvVideoCamera *camera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.camera = [[CvVideoCamera alloc] initWithParentView:self.videoView];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.camera.defaultFPS = 30;
    self.camera.delegate = self;
    
    objDetector = [[ObjectDetector alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.camera start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.camera stop];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processImage:(cv::Mat &)image
{
//    [objDetector detectAndMark:image];
    [EdgeDetector detectAndOverlay:image withThreshold:25];
}

@end
