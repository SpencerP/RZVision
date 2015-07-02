//
//  ViewController.swift
//  RZHaarTrainTwo
//
//  Created by Spencer Poff on 6/29/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, PositiveSampleCreatorProtocol, HaarTrainerDelegateProtocol {

    @IBOutlet weak var choosePositiveImagesDirectoryButton: NSButton!
    @IBOutlet weak var chooseNegativeImagesDirectoryButton: NSButton!
    @IBOutlet weak var chooseOutputDirectoryButton: NSButton!
    
    @IBOutlet weak var positiveImagesDirectoryTextField: NSTextField!
    @IBOutlet weak var negativeImagesDirectoryTextField: NSTextField!
    @IBOutlet weak var outputDirectoryTextField: NSTextField!
    
    @IBOutlet var consoleOutputTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "HaarTrainer"
        
        // FOR DEBUG
        self.positiveImagesDirectoryTextField.stringValue = "/Users/spencerpoff/RaizLabs/TestProjects/classifier_training/positive"
        self.negativeImagesDirectoryTextField.stringValue = "/Users/spencerpoff/RaizLabs/TestProjects/classifier_training/negative"
        self.outputDirectoryTextField.stringValue = "/Users/spencerpoff/RaizLabs/TestProjects/classifier_training/classifier"
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func runPushed(sender: AnyObject) {
        let positiveImagesPath = positiveImagesDirectoryTextField.stringValue
        let negativeImagesPath = negativeImagesDirectoryTextField.stringValue
        let classifierOutputPath = outputDirectoryTextField.stringValue
        
        // create temporary vectors directory
        let tempPositiveVectorPath = createTemporaryDirectory()
        
        self.consoleOutputTextView.string = "Temporary vector directory created...\n"
        
        let sampleCreator = PositiveSampleCreator(delegate: self)
        
        // generate positive sample vec
        // combine positive sample vectors
        let generatedVectorFilePath = sampleCreator.createSamples(positiveImagesPath, negativeImagesPath: negativeImagesPath, outputDirectory: tempPositiveVectorPath, totalSampleCount: 1500)
        
        // begin training
        let trainer = HaarTrainer(delegate: self)
        trainer.trainClassifier(generatedVectorFilePath, negativeImagesPath: negativeImagesPath,
            trainedClassifierOutputPath: classifierOutputPath, positiveSampleCount: 1500,
            imageWidth: 20, imageHeight: 20,
            completion: { () -> Void in
                // clean up temporary vectors directory
                deleteFileAtPath(generatedVectorFilePath)
        })
    }
        
    func handleGeneratedOutput(outputText: String) {
        self.consoleOutputTextView.string = consoleOutputTextView.string! + outputText
    }
    
    @IBAction func chooseDirectoryPressed(sender: AnyObject) {
        var directoryChooserPanel = NSOpenPanel()
        directoryChooserPanel.canChooseFiles = false
        directoryChooserPanel.canChooseDirectories = true
        directoryChooserPanel.allowsMultipleSelection = false
        
        directoryChooserPanel.beginWithCompletionHandler { (choice) -> Void in
            if choice == NSFileHandlingPanelOKButton {
                if let chosenPathComponents = directoryChooserPanel.URL?.pathComponents as? [String] {
                    let chosenPathString = "/".join(chosenPathComponents)
                    
                    let button = sender as! NSObject
                    
                    if button == self.choosePositiveImagesDirectoryButton {
                        self.positiveImagesDirectoryTextField.stringValue = chosenPathString.stringByStandardizingPath
                    }
                    else if button == self.chooseNegativeImagesDirectoryButton {
                        self.negativeImagesDirectoryTextField.stringValue = chosenPathString.stringByStandardizingPath
                    }
                    else if button == self.chooseOutputDirectoryButton {
                        self.outputDirectoryTextField.stringValue = chosenPathString.stringByStandardizingPath
                    }
                    else {
                        println("Uh, weird...")
                    }
                }
                else {
                    // TODO: handle unsuccessful cast
                }
                
            }
        }
        
    }

}

