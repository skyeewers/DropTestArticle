#  Apple Mail Drag and Drop Issue Sample

This branch demonstrates a workaround for the issue with Apple Mail in receiving email messages via drag and drop in macOS.  

Instead of relying on the `NSFilePromiseReceiver` having a callback triggered once the files have been written to the requested location,
we use the open source [Witness swift library](https://github.com/njdehoog/Witness) to tie into the file system events API of macOS.
With this setup, we monitor the directory where Apple Mail is supposed to write the files in the file promise to end detect the completion of 
the drag and drop operation that way.  

For more information on the issue, read 
[README.md on the master branch](https://github.com/svenewers/DropTestArticle/blob/master/README.md) 
and for a "walk-through guide" on this workaround, [read my blogpost](https://svenewers.com) on the matter. 
