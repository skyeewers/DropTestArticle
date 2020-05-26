//
//  DropView.swift
//  DropTestArticle
//
//  Created by Sven Ewers on 27.04.20.
//  Copyright © 2020 Bearly Digital. All rights reserved.
//

import Cocoa

class DropView: NSView {
    var filePath: String?
    let destinationFolder: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Drops")
    let supportedTypes = NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        try! FileManager.default.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
    
        registerForDraggedTypes(supportedTypes)
  }
    
    private lazy var workQueue: OperationQueue = {
        let providerQueue = OperationQueue()
        providerQueue.qualityOfService = .userInitiated
        return providerQueue
    }()

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return sender.draggingSourceOperationMask.intersection([.copy])
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
                // This is where we hang for ~60 seconds
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationFolder, options: [:],
                                                         operationQueue: self.workQueue) { (fileURL, error) in
                    if let error = error {
                        // Apple mail fails here, resulting in this error:
                        // Error Domain=NSURLErrorDomain Code=-1001 "(null)"
                        print("Encountered errror: ")
                        print(error)
                    } else {
                        // Other eMail apps output this string
                        print("Placed promised file at \(fileURL)")
                    }
                }
            default: break
            }
        }
        
        return true
    }
}
