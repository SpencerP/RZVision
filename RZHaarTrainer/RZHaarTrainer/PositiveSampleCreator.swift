//
//  PositiveSampleCreator.swift
//  RZHaarTrain
//
//  Created by Spencer Poff on 6/23/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

import Foundation

protocol PositiveSampleCreatorProtocol {
    func handleGeneratedOutput(textOutput: String) -> Void
}

class PositiveSampleCreator {
    
    var delegate: PositiveSampleCreatorProtocol
    
    init (delegate: PositiveSampleCreatorProtocol) {
        self.delegate = delegate
    }
    
    // Creates samples, combines them into a single vector, then returns the path to that combined vector file
    func createSamples(positiveImagesPath: String, negativeImagesPath: String, outputDirectory: String, totalSampleCount: Int = 1500, imageWidth: Int = 20, imageHeight: Int = 20) -> String {
        let command = "opencv_createsamples"
        var arguments: NSMutableArray = ["-bgcolor", "0", "-bgthresh", "0", "-maxxangle", "1.1", "-maxyangle", "1.1", "-maxzangle", "0.5", "-maxidev", "40", "-w", "\(imageWidth)", "-h", "\(imageHeight)"]
        
        // read positive and negative samples to array
        let pathsToPositiveImages = filenamesInDirectoryWithExtension(positiveImagesPath, "jpg")
        let pathsToNegativeImages = filenamesInDirectoryWithExtension(negativeImagesPath, "jpg")
        
        // extract necessary URI components
        let negativeImagesFolderName = negativeImagesPath.pathComponents.last!
        let negativeImagesParentDirectory = negativeImagesPath.parentDirectoryPath
        
        let tempBgFilePath = negativeImagesParentDirectory.stringByAppendingPathComponent("backgrounds.txt")
        
        // determine number of vector variations to generate for each positive image
        let generatedImageCountPerImage = totalSampleCount / pathsToPositiveImages.count
        let numRemaining = totalSampleCount % pathsToPositiveImages.count
        
        // collect intermediate vector filenames for cleaning up later
        var intermediateVectorFilenames: NSMutableArray = []
        
        for i in 0..<pathsToPositiveImages.count {
            let imagePath: String = pathsToPositiveImages[i] as! String
            
            // create negative backgrounds string to be written to temporary file
            var negativeBackgroundsString = ""
            for j in 0..<generatedImageCountPerImage {
                // grab random negative image to use as background
                let randomIndex = Int(arc4random_uniform(UInt32(pathsToNegativeImages.count)))
                
                if let randomNegImagePath: String = pathsToNegativeImages[randomIndex] as? String {
                    // opencv_createsamples requires that the backgrounds text file be formatted such that it sits in a directory above the
                    // negative images and contains a newline delimitted list of relative paths to the negative images being used
                    let negImageRelativePath = negativeImagesFolderName.stringByAppendingPathComponent(randomNegImagePath.pathComponents.last!)
                    negativeBackgroundsString += negImageRelativePath + "\n"
                }
            }
            
            // write negative backgrounds string to temporary file
            var err: NSError?
            negativeBackgroundsString.writeToFile(tempBgFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: &err)
            
            if err == nil {
                let vecFilename = outputDirectory.stringByAppendingPathComponent(imagePath.lastPathComponent.stringByDeletingPathExtension + ".vec")
                
                arguments.addObjectsFromArray(["-img", "\(imagePath)", "-bg", "\(tempBgFilePath)", "-vec", "\(vecFilename)", "-num", "\(generatedImageCountPerImage)"])
                
                if let argv = arguments as NSArray as? [String] {
                    let taskAndOutput = runBundledScriptAndWait(command, argv)
                    if let generatingPositivesTask = taskAndOutput.task {
                        let finishStatus = generatingPositivesTask.terminationStatus
                        if finishStatus == 0 {
                            if let outputData = taskAndOutput.outputData {
                                let outputString = NSString(data: outputData, encoding: NSUTF8StringEncoding)! as String
                                self.delegate.handleGeneratedOutput(outputString)
                            }
                            
                            self.delegate.handleGeneratedOutput("Vector file for \(imagePath) generated successfully")
                            
                            intermediateVectorFilenames.addObject(vecFilename)
                        }
                        else {
                            self.delegate.handleGeneratedOutput("Creating vector file for \(imagePath) failed with error code: \(finishStatus)")
                        }
                    }
                }
            }
            else {
                println("Writing background to file failed with error: \(err)")
            }
        }
        
        deleteFileAtPath(tempBgFilePath)
        
        let combinedVectorFilePath = combineVectorFiles(outputDirectory)
        
        for obj in intermediateVectorFilenames {
            if let intermediateVectorFilePath = obj as? String {
                deleteFileAtPath(intermediateVectorFilePath)
            }
        }
        
        return combinedVectorFilePath
    }
    
    func combineVectorFiles(vectorsDirectory: String) -> String {
        let outputFilePath = vectorsDirectory.stringByAppendingPathComponent("combined.vec")
        let temporaryVectorPathsFilename = "samples.txt"
        
        // Get vectors as array
        let vectorPaths: NSArray = filenamesInDirectoryWithExtension(vectorsDirectory, "vec")
        
        // Convert array to newline delimited string
        var vecSamplePathsString = ""
        for obj in vectorPaths {
            if let sampleVecPath = obj as? String {
                vecSamplePathsString += sampleVecPath + "\n"
            }
        }
        
        // Write that string to a temporary text file
        var err: NSError?
        vecSamplePathsString.writeToFile(temporaryVectorPathsFilename, atomically: false, encoding: NSUTF8StringEncoding, error: &err)
        
        if err != nil {
            println("While writing vector files to temp file, encountered error: \(err)")
        }
        
        // Run mergevec command
        let command = "mergevec"
        let args = ["\(temporaryVectorPathsFilename)", "\(outputFilePath)"]
        
        let taskAndOutput = runBundledScriptAndWait(command, args)
        if let generateCombinedVectorTaskOutput = taskAndOutput.outputData {
            let outputString = NSString(data: generateCombinedVectorTaskOutput, encoding: NSUTF8StringEncoding)! as String
            self.delegate.handleGeneratedOutput(outputString)
        }
        
        
        // Clean up
        deleteFileAtPath(temporaryVectorPathsFilename)
        
        return outputFilePath
    }
}
