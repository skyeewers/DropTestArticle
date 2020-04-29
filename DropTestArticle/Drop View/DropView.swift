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

  private lazy var destinationURL: URL = {
    let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
      "Drops")
    try? FileManager.default.createDirectory(
      at: destinationURL, withIntermediateDirectories: true, attributes: nil)
    return destinationURL
  }()

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    registerForDraggedTypes([
      NSPasteboard.PasteboardType
        .fileNameType(forPathExtension: ".eml"), NSPasteboard.PasteboardType.filePromise,
    ])
  }

  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if true {
      return .copy
    }
  }

  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {

    let pasteboard: NSPasteboard = sender.draggingPasteboard

    guard
      let filePromises = pasteboard.readObjects(
        forClasses: [NSFilePromiseReceiver.self], options: nil) as? [NSFilePromiseReceiver]
    else {
      return false
    }

    print("Files dropped")

    let operationQueue = OperationQueue()
    print("Destination URL: \(destinationURL)")

    filePromises.forEach({ filePromiseReceiver in
      filePromiseReceiver.receivePromisedFiles(
        atDestination: destinationURL,
        options: [:],
        operationQueue: operationQueue,
        reader: { (url, error) in
          if let error = error {
            dump(error)
          } else {
            print("Received file at url \(url)")
          }
          print(filePromiseReceiver.fileNames, filePromiseReceiver.fileTypes)
        })
    })
    return true
  }
}
