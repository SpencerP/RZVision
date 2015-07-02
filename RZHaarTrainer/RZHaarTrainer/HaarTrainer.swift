//
//  HaarTrainer.swift
//  RZHaarTrain
//
//  Created by Spencer Poff on 6/24/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

import Foundation

protocol HaarTrainerDelegateProtocol {
    func handleGeneratedOutput(textOutput: String) -> Void
}

class HaarTrainer {
    
    var delegate: HaarTrainerDelegateProtocol
    
    init(delegate: HaarTrainerDelegateProtocol) {
        self.delegate = delegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "outputUpdated:", name: NSFileHandleDataAvailableNotification, object: nil)
    }
    
    func trainClassifier(positiveSamplesVectorFilePath: String, negativeImagesPath: String, trainedClassifierOutputPath: String, positiveSampleCount: Int = 1000, imageWidth: Int = 20, imageHeight: Int = 20, completion: (() -> Void)?) {
        // numPos should be about .8 to .9 times the number of positive training samples in the vector ("...vec-file has to contain >= (numPose + (numStages-1) * (1 - minHitRate) * numPose) + S,
        // where S is a count of samples from vec-file that can be recognized as background right away.")
        let numPos = Int( 0.8 * Float(positiveSampleCount) )
        
        let pathsToNegativeImages = filenamesInDirectoryWithExtension(negativeImagesPath, "jpg")
        
        // Write negative sample paths to temporary text file
        let negativeImagesPathComponents = negativeImagesPath.pathComponents
        let negativeImagesFolderName = negativeImagesPathComponents.last
        let negativeImagesParentDirectory = "/".join(negativeImagesPathComponents[0..<negativeImagesPathComponents.count-1])
        
        let negSamplesFilePathsFilename = negativeImagesParentDirectory.stringByAppendingPathComponent("negatives.txt")
        
        // Convert array to newline delimited string
        var negSamplePathsString = ""
        for obj in pathsToNegativeImages {
            if let sampleVecPath = obj as? String {
                let negImageRelativePath = negativeImagesFolderName?.stringByAppendingPathComponent(sampleVecPath.pathComponents.last!)
                negSamplePathsString += negImageRelativePath! + "\n"
            }
        }
        
        // Write that string to a temporary text file
        var err: NSError?
        negSamplePathsString.writeToFile(negSamplesFilePathsFilename, atomically: false, encoding: NSUTF8StringEncoding, error: &err)
        
        if err != nil {
            self.delegate.handleGeneratedOutput("While writing vector files to temp file, encountered error: \(err)")
        }
        
        let args = ["-data", "\(trainedClassifierOutputPath)", "-vec", "\(positiveSamplesVectorFilePath)", "-bg", "\(negSamplesFilePathsFilename)", "-numStages", "20", "-minHitRate", "0.999", "-maxFalseAlarmRate", "0.5", "-numPos", "\(numPos)", "-numNeg", "\(pathsToNegativeImages.count)", "-w", "\(imageWidth)", "-h", "\(imageHeight)", "-mode", "ALL", "-precalcValBufSize", "1024", "-precalcIdxBufSize", "1024"]
        
        
        let taskAndPipe = createTaskAndPipeFromBundledScript("opencv_traincascade", args)
        
        if let pipe = taskAndPipe.pipe {
            pipe.fileHandleForReading.readabilityHandler = { (fileHandle: NSFileHandle!) -> Void in
                let newData = fileHandle.availableData
                if NSThread.currentThread().isMainThread {
                    self.delegate.handleGeneratedOutput(NSString(data: newData, encoding: NSUTF8StringEncoding)! as String)
                }
                else {
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.delegate.handleGeneratedOutput(NSString(data: newData, encoding: NSUTF8StringEncoding)! as String)
                    })
                }
                
            }
//            pipe.fileHandleForReading.readInBackgroundAndNotify()
        }
        
        if let task = taskAndPipe.task {
            task.terminationHandler = { (task: NSTask!) -> Void in
                deleteFileAtPath(negSamplesFilePathsFilename)
                
                if completion != nil {
                    completion!()
                }
            }
            task.launch()
        }
    }

}
