//
//  DropView.swift
//  DropTestArticle
//
//  Created by Sven Ewers on 27.04.20.
//  Copyright © 2020 Bearly Digital. All rights reserved.
//

import Cocoa
import Witness

class DropView: NSView {
    
    @IBOutlet weak var statusLable: NSTextField!
    
    let destinationFolder: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
    let supportedTypes = NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) }
    var witness: Witness?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        try! FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.red.cgColor
    
        registerForDraggedTypes(supportedTypes)
  }
    
    private lazy var workQueue: OperationQueue = {
        let providerQueue = OperationQueue()
        providerQueue.qualityOfService = .userInitiated
        return providerQueue
    }()

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        wantsLayer = true
        layer?.backgroundColor = NSColor.blue.cgColor
        return sender.draggingSourceOperationMask.intersection([.copy])
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.red.cgColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: [ kUTTypeEmailMessage ]
        ]
        
        sender.enumerateDraggingItems(options: [], for: nil, classes: [NSFilePromiseReceiver.self], searchOptions: searchOptions) { (draggingItem, _, _) in
            switch draggingItem.item {
            case let filePromiseReceiver as NSFilePromiseReceiver:
                print("Resolving promise...")
                self.statusLable.stringValue = "Resolving dropped files..."
                
                // We're about to trigger promise resolution, so let's watch the folder the promised files will be written to
                let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first!
                print(desktopPath)
                print(self.destinationFolder.absoluteString)
                self.witness = Witness(paths: [self.destinationFolder.relativePath], flags: .FileEvents, latency: 0.3) { events in
                    self.statusLable.stringValue = "Promised files have been placed at \n \(events[0].path)"
                }
                
                // Trigger promise resolution...
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationFolder, options: [:],
                                                         operationQueue: self.workQueue) { (fileURL, error) in
                    // ... but don't do anything here because promise resolution is unreliable
                }
            default: break
            }
        }
        
        return true
    }
}
