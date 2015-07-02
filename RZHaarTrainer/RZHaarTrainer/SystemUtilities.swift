//
//  SystemUtilities.swift
//  RZHaarTrain
//
//  Created by Spencer Poff on 6/24/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

import Foundation

func deleteFileAtPath(filePath: String) {
    let fileManager = NSFileManager.defaultManager()
    
    if fileManager.fileExistsAtPath(filePath) {
        var err: NSError?
        fileManager.removeItemAtPath(filePath, error: &err)
        
        if err != nil {
            println("Error deleting temporary file: \(err)")
        }
    }
}

func filenamesInDirectoryWithExtension(pathToImages: String, fileExtension: String) -> NSMutableArray {
    let fileManager = NSFileManager.defaultManager()
    let positiveFiles = fileManager.enumeratorAtPath(pathToImages)
    
    var imagePaths: NSMutableArray = []
    
    while let file = positiveFiles?.nextObject() as? String {
        if file.pathExtension.lowercaseString == fileExtension {
            imagePaths.addObject(pathToImages.stringByAppendingPathComponent(file).stringByStandardizingPath)
        }
    }
    
    return imagePaths
}

func runBundledScriptAndWait(command: String, arguments: [String]) -> (task: NSTask?, outputData: NSData?) {
    // Find file with command name in bundle
    NSBundle.mainBundle().resourcePath
    if let executablePath = NSBundle.mainBundle().pathForAuxiliaryExecutable(command) {
        let constructedCommandString = executablePath.stringByAppendingString(" " + " ".join(arguments))
        
        let outputPipe = NSPipe()
        var scriptTask = NSTask()
        
        scriptTask.standardOutput = outputPipe
        scriptTask.launchPath = "/bin/bash"
        scriptTask.arguments = ["-l", "-c", constructedCommandString]
        
        scriptTask.launch()
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        
        scriptTask.waitUntilExit()
        
        return (scriptTask, data)
    }
    
    return (nil, nil)
}

func createTaskAndPipeFromBundledScript(command: String, arguments: [String]) -> (task: NSTask?, pipe: NSPipe?) {
    // Find file with command name in bundle
    NSBundle.mainBundle().resourcePath
    if let executablePath = NSBundle.mainBundle().pathForAuxiliaryExecutable(command) {
        let constructedCommandString = executablePath.stringByAppendingString(" " + " ".join(arguments))
        
        let outputPipe = NSPipe()
        var scriptTask = NSTask()
        
        scriptTask.standardOutput = outputPipe
        scriptTask.launchPath = "/bin/bash"
        scriptTask.arguments = ["-l", "-c", constructedCommandString]
        
        return (scriptTask, outputPipe)
    }
    
    return (nil, nil)
}

func createTemporaryDirectory() -> String! {
    let tempDirectoryTemplate = NSTemporaryDirectory().stringByAppendingPathComponent("XXXXX")
    var tempDirectoryTemplateCString = tempDirectoryTemplate.fileSystemRepresentation()
    
    let result = mkdtemp(&tempDirectoryTemplateCString)
    if result == nil { return nil }
    
    let fileManager = NSFileManager.defaultManager()
    return fileManager.stringWithFileSystemRepresentation(result, length: Int(strlen(result)))
}

extension String {
    var parentDirectoryPath: String {
        let pathComponents = self.pathComponents
        return "/".join(pathComponents[0..<pathComponents.count-1])
    }
}
