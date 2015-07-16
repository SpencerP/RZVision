//
//  ViewController.m
//  HaarDetector
//
//  Created by Spencer Poff on 7/13/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "ViewController.h"

#import "ObjectDetector.h"

#import <opencv2/highgui/cap_ios.h>

@interface ViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *videoView;
@property (strong, nonatomic) CvVideoCamera *camera;
@property (strong, nonatomic) ObjectDetector *detector;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.camera = [[CvVideoCamera alloc] initWithParentView:self.videoView];
    self.camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.camera.defaultFPS = 30;
    self.camera.delegate = self;
    
    self.detector = [[ObjectDetector alloc] init];
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
    cv::Mat markedImage = [self.detector detectAndMark:image];
    // TODO: Display on the camera
}

@end
