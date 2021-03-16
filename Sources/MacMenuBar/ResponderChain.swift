//
//  File.swift
//  
//
//  Created by Chip Jarred on 2/23/21.
//

import Cocoa

// -------------------------------------
/**
 Wrapper for an arbitrary `NSObject` to provide the `NSResponder` interface.
 
 Annoyingly, `AppKit` uses a responder chain that includes objects that don't
 inherit from `NSResponder`, like window delegates, the app delegate and, for
 document-based apps, documents and the document controller.
 
 This class allows us to wrap the non-`NSResponder` object in an `NSResponder`
 decorator, so we can uniformly query those objects if they respond to certain
 `selector`s, and ask them to preform those selectors, so we can mimik the
 responder chain's behavior.
 
 We don't actually redirect the full `NSResponder` interface, just
 `responds(to:)` and the various `perform(_:...)` methods.
 */
internal class DelegateWrapper: NSResponder
{
    let delegate: NSObject
    
    // -------------------------------------
    init(_ delegate: NSObject)
    {
        self.delegate = delegate
        super.init()
    }
    
    // -------------------------------------
    required init?(coder: NSCoder) { fatalError("Encodable not supported") }
    
    // -------------------------------------
    public override func perform(
        _ aSelector: Selector!) -> Unmanaged<AnyObject>!
    {
        delegate.perform(aSelector)
    }

    // -------------------------------------
    public override func perform(
        _ aSelector: Selector!,
        with object: Any!) -> Unmanaged<AnyObject>!
    {
        delegate.perform(aSelector, with: object)
    }

    // -------------------------------------
    public override func perform(
        _ aSelector: Selector!,
        with object1: Any!,
        with object2: Any!) -> Unmanaged<AnyObject>!
    {
        delegate.perform(aSelector, with: object1, with: object2)
    }
    
    // -------------------------------------
    public override func responds(to aSelector: Selector!) -> Bool {
        delegate.responds(to: aSelector)
    }
}

// MARK:-
// -------------------------------------
/**
 Object representing the current responder chain.
 
 The `Iterator` for this `struct` iterates though the responder chain in the
 same order Apple describes in [Event Architecture: The Responder Chain]
 
 [Event Architecture: The Responder Chain]: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/EventArchitecture/EventArchitecture.html#//apple_ref/doc/uid/10000060i-CH3-SW2
 */
internal struct ResponderChain
{
    private var firstResponders: [NSResponder]
    
    // -------------------------------------
    public init(forContextualMenu: Bool = false)
    {
        precondition(!forContextualMenu, "Implement different chain for contextual menus: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MenuList/Articles/EnablingMenuItems.html#//apple_ref/doc/uid/20000261")
        var responders = [NSResponder]()
        responders.reserveCapacity(8)
        
        if let keyWindow = NSApp.keyWindow {
            Self.addResponders(for: keyWindow, to: &responders)
        }
        if let mainWindow = NSApp.mainWindow,
           mainWindow !== NSApp.keyWindow
        {
            Self.addResponders(for: mainWindow, to: &responders)
        }
        
        responders.append(NSApp)
        
        if let appDelegate = NSApp.delegate {
            responders.append(DelegateWrapper(appDelegate as! NSObject))
        }
        
        if let documentController = Self.findDocumentController() {
            responders.append(DelegateWrapper(documentController))
        }
        
        firstResponders = responders
    }
    
    // -------------------------------------
    /**
     Add the responders relevant to the given window's responder chain to the
     specified array.
     
     The responders added are:
        1. The window's `firstResponder`, from which the iterator will crawl up
            the view heirarchy on its own without our having to do that here.
        2. The window itself
        3. The window's view controller, if it has one.
        4. The window's delegate, if it has noe.
        5. The window's document, if it has one.
     
     - Parameters:
        - window: The `NSWindow` whose responders are to be added.
        - responders: An array of `NSResponder` objects to which `window`'s
            responders will be added.
     */
    private static func addResponders(
        for window: NSWindow?,
        to responders: inout [NSResponder])
    {
        guard let window = window else { return }
        
        if let responder = window.firstResponder {
            responders.append(responder)
        }
        
        responders.append(window)
        
        let document: NSDocument?
        if let controller = window.windowController
        {
            responders.append(controller)
            document = controller.document as? NSDocument
        }
        else { document = nil }
        
        if let delegate = window.delegate {
            responders.append(DelegateWrapper(delegate as! NSObject))
        }
        
        if let doc = document, doc !== window.delegate {
            responders.append(DelegateWrapper(doc))
        }
        
    }
    
    // -------------------------------------
    /**
     Find the app's `NSDocumentController`, if it exists.
     
     We can't just use `NSDocumentController.shared`, because it will *create* one
     if it doesn't exist, and we don't want that for two reasons:
        1. If this isn't a document-based app, we don't want to create a
            document controller at all.
        2. If this is a document-based app, accessing
            `NSDocumentController.shared`  before the correct controller has
            been established would prevent the correct one from ever being
            created.
          
     We just want to know if there is already an `NSDocumentController` so we
     can add it to our synthesized responder chain for document-based apps.
     
     Apple doesn't seem to provide a clean API for detecting if document based
     architecture is being used without starting to set the app up for that.
     
     Our hack-around is to  ask `NSApp` to find a target for a `selector` that
     `NSDocumentController` responds, and assume that target is the
     `NSDocumentController`...  and hope that some other object doesn't claim
     to respond to the `selector` before the document controller has a chance
     to.
     
     A quick search through the Apple's documentation reveals that no other
     `AppKit` class responds to `NSDocumentController.documentClassNames`, so
     we use that.  It's still possible that a host application could implement
     that getter without actually being an `NSDocumentController`, but for it
     to prevent this method from working correctly, it would have to be
     implemented in an Objective-C class.  While possible, that's less and less
     likely for an app written in Swift.  So the chances of it not working
     correctly are very low, especially for a SwiftUI app, which is the main
     motivation for this library anyway.
     
     - Returns: The current `NSDocumentController`, or `nil` if there isn't one.
     */
    private static func findDocumentController() -> NSDocumentController?
    {
        let querySelector =
            #selector(getter: NSDocumentController.documentClassNames)
        
        return NSApp.target(forAction: querySelector) as? NSDocumentController
    }

    // -------------------------------------
    /**
     Return the first responder in the responder chain search for which
     `condition` is `true`.
     
     - Note: Don't confuse this method for a window's `firstResponder`.
     
     - Parameters:
        - condition: closure used to select the responder.  Return
        `true` to select the current responder; otherwise return `false`.
        - responder: current `NSResponder` to which `condition` is being applied.
     
     - Returns: The first `NSResponder` object for which `condition` returns
        `true`.  Returns `nil` if no condition returns `false` for all responders.
     */
    func firstResponder(
        where condition: (_ responder: NSResponder) -> Bool) -> NSResponder?
    {
        for responder in self {
            if condition(responder) { return responder }
        }
        
        return nil
    }
}

// MARK:- Sequence conformance
// -------------------------------------
extension ResponderChain: Sequence
{
    public typealias Element = NSResponder
    
    // -------------------------------------
    public struct Iterator: IteratorProtocol
    {
        public typealias Iterator = ResponderChain.Element
        var responders: [NSResponder]
        var curResponder: NSResponder? = nil
        
        init(_ responders: [NSResponder])
        {
            self.responders = responders
            self.curResponder = self.responders.removeFirst()
        }
        
        public mutating func next() -> Element?
        {
            if curResponder == nil
            {
                if responders.isEmpty { return nil }
                
                curResponder = responders.removeFirst()
            }
            
            let ret = curResponder
            curResponder = curResponder?.nextResponder
            return ret
        }
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(firstResponders)
    }
}
