#  Apple Mail Drag and Drop Issue Sample

This repository contains a sample Xcode project demonstrating my issues with receiving email message files (`*.eml`) from Apple Mail  using a `NSFilePromiseReceiver`.  

The code in this repo is purposely written in a way that closely follows [Apple's own sample code](https://developer.apple.com/documentation/appkit/documents_data_and_pasteboard/supporting_drag_and_drop_through_file_promises) so that any possible implementation errors on my end are kept to an absolute minimum.  

## What is this project supposed to do?
The app in this project displays a view (`DropView` & `DropViewController`) that is configured to accept `.eml` email files via drag and drop file promises.  

When an appropriate file is dropped onto said view, the app should resolve the file promise(s) by having them written to a temporary directory. Once that's done, a simple message should be `print()`-ed to the console, displaying the temporary location the promised file has been written to.  

## What seems to be the issue?
When receiving drag and drop file promises from Apple's Mail.app, this does not seem to work as expected.  

The file promise is resolved and the files are written to the requested temporary location, however, when resolving the promise the application hangs for fairly exactly 60 seconds and then passes an error to the callback block of `NSFilePromiseReceiver.receivePromisedFiles` that reads as follows: 

`Error Domain=NSURLErrorDomain Code=-1001 "(null)"`

## How have I tried to troubleshoot it so far
I've attempted to use other apps that can use file promises to drag and drop email messages (e.g. Microsoft Outlook) with the code in this project and those attempts seem to work without issue. I'm only able to reproduce this issue with Apple Mail (running macOS Catalina, though I have not yet been able to test other versions of macOS).  

It appears as though some code that's generating the `NSURL` for the `NSFilePromiseReceiver.receivePromisedFiles` callback block is timing out, though I'm not yet sure why.  

I have verified that the requested files are _always_ placed in the desired location by the file promise providing app, even Apple Mail. It's just that with Apple Mail, the aforementioned  `NSURL` error makes using the files once placed in the requested location impossible because of the 60 second delay & the error, leaving the passed URL empty.
