//
//  Drag and drop.swift
//  Comic Cleaner
//
//  Created by Micah Hummert on 10/9/16.
//  Copyright © 2016 Hummert IT. All rights reserved.
//

import Cocoa

protocol DropViewDelegate {
    func processComicURLs(_ urls: [URL], center: NSPoint)
    func processComic(_ comic: NSImage, center: NSPoint)
    func processAction(_ action: String, center: NSPoint)
}

class DropViewBackground: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.setFill()
        NSRectFill(bounds)
    }
}

class DropView: NSView {
    
    //1.
    let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey: ["public.directory", "public.zip-archive", "public.cbz-archive", "com.macitbetter.cbz-archive", "cx.c3.cbz-archive", "com.milke.cbz-archive", "com.bitcartel.comicbooklover.cbz", "org.7-zip.7-zip-archive", "public.cb7-archive", "com.macitbetter.cb7-archive", "cx.c3.cb7-archive", "com.rarlab.rar-archive", "public.cbr-archive", "com.macitbetter.cbr-archive", "cx.c3.cbr-archive", "com.bitcartel.comicbooklover.cbr", "com.milke.cbr-archive"]]
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        var canAccept = false
        
        //2.
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        //3.
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        return canAccept
        
    }
    
    //1.
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    //2.
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    enum Appearance {
        static let lineWidth: CGFloat = 10.0
    }
    
    var delegate: DropViewDelegate?
    
    override func awakeFromNib() {
        setup()
    }
    
    var acceptableTypes: Set<String> { return [NSURLPboardType] }
    
    func setup() {
        register(forDraggedTypes: Array(acceptableTypes))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            // dropImage.alphaValue = 1
        }
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        //1.
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        //2.
        let point = convert(draggingInfo.draggingLocation(), from: nil)
        //3.
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            delegate?.processComicURLs(urls, center: point)
            return true
        }
        return false
        
    }
    
    //we override hitTest so that this view which sits at the top of the view hierachy
    //appears transparent to mouse clicks
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
}
