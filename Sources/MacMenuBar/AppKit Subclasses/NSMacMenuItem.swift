// Copyright 2021 Chip Jarred
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

// -------------------------------------
@objc public class NSMacMenuItem:
    NSMenuItem, NSMenuItemValidation, NSUserInterfaceValidations
{
    public typealias ActionTriggerClosure = (NSMenuItem) -> Void
    
    @usableFromInline internal var _action: Action?
    @usableFromInline internal var toggleStateWhenSelected: Bool = false
    @usableFromInline internal var actionTarget: NSObject? = nil
    private var isContextualMenu = false

    public var nsMenuItem: NSMenuItem { return self }
    
    @usableFromInline
    internal var preActionClosure: ActionTriggerClosure? = nil
    
    @usableFromInline
    internal var postActionClosure: ActionTriggerClosure? = nil
    
    @usableFromInline
    internal var stateUpdater: (() -> MacMenuItemState)?

    // -------------------------------------
    public override var title: String
    {
        get { super.title }
        set { super.title = substituteVariables(in: localize(newValue)) }
    }
    
    // -------------------------------------
    public var canBeEnabled: Bool
    {
        get { return _action?.canBeEnabled ?? true }
        set { _action?.canBeEnabled = newValue }
    }
    
    // -------------------------------------
    public override var isEnabled: Bool
    {
        get { return _action?.isEnabled ?? super.isEnabled }
        set { super.isEnabled = newValue }
    }

    // -------------------------------------
    @usableFromInline
    internal var enabledValidator: (() -> Bool)?
    {
        get { _action?.enabledValidator }
        set { _action?.enabledValidator = newValue }
    }
    
    // -------------------------------------
    @usableFromInline
    internal var titleUpdater: (() -> String)? = nil
    
    private let menuItemActionSelector = #selector(_doMenuItemAction(_:))

    // -------------------------------------
    public required init(title: String, action: Action? = nil)
    {
        super.init(
            title: substituteVariables(in: localize(title)),
            action: menuItemActionSelector,
            keyEquivalent: ""
        )
        self._action = action
        action?.keyEquivalent?.set(in: self)
        target = self
    }
    

    // -------------------------------------
    convenience init() { self.init(title: "") }
    
    // -------------------------------------
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        
        /*
         We don't have a way to serialize or deserialize ClosureActions, and
         really the only reason we'd have to serialize it would be so that this
         NSMenuItem can be stored in xib files, which is mainly for the
         Storyboard editor to do... the whole point of this package is to use
         SwiftUI while getting rid of the last vestige of Storyboards for the
         menu bar.
        */
        fatalError("\(type(of: self)) cannot be decoded")
    }
    
    // -------------------------------------
    public override func encode(with coder: NSCoder)
    {
        /*
         We don't have a way to serialize or deserialize the ClosureActions, and
         really the only reason we'd have to serialize it would be so that this
         NSMenuItem can be stored in xib files, which is mainly for the
         Storyboard editor to do... the whole point of this package is to use
         SwiftUI while getting rid of the last vestige of Storyboards for the
         menu bar.
        */
        fatalError("\(type(of: self)) cannot be encoded")

    }
    
    // -------------------------------------
    @objc func _doMenuItemAction(_ sender: Any)
    {
        if let action = _action, let target = target(for: action)
        {
            if let preAction = preActionClosure {
                preAction(self)
            }
            
            if action.performAction(on: target, for: sender)
            {
                if toggleStateWhenSelected {
                    state = state == .off ? .on : .off
                }
            }
            
            if let postAction = postActionClosure {
                postAction(self)
            }
        }
    }
    
    // -------------------------------------
    private func target(for action: Action) -> NSObject?
    {
        guard let selector = (action as? SelectorAction)?.selector else {
            return self
        }
        
        return action.isEnabled ? target(for: selector) : nil
    }
    
    // -------------------------------------
    private func target(for selector: Selector) -> NSObject?
    {
        if let target = actionTarget {
            return target.responds(to: selector) ? target : nil
        }
        
        return ResponderChain(forContextualMenu: isContextualMenu)
            .firstResponder { $0.responds(to: selector) }
    }
    
    // MARK:- NSMenuItemValidation & NSUserInterfaceValidations conformance
    // -------------------------------------
    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool
    {
        assert(menuItem === self)
        #warning("DEBUG")
        let validation = validateMenuItemSelf()
        if menuItem.title == "Cut" {
            print("\(#function) returning \(validation)")
        }
        return validation
    }
    
    // -------------------------------------
    public func validateUserInterfaceItem(
        _ item: NSValidatedUserInterfaceItem) -> Bool
    {
        assert(item === self)
        #warning("DEBUG")
        let validation = validateMenuItemSelf()
        if (item as? NSMacMenuItem)?.title == "Cut" {
            print("\(#function) returning \(validation)")
        }
        return validation

    }
    
    // -------------------------------------
    #warning("Delete after testing new version")
    public func validateMenuItemSelf_Saved() -> Bool
    {
        if self.submenu != nil { return true }
        
        guard let action = _action, action.canBeEnabled else { return false }
        
        if let validator = action.enabledValidator {
            return validator()
        }
        
        guard let selectorAction = action as? SelectorAction else {
            return true
        }
        
        if let target = target(for: selectorAction) {
            return validateMenuItem(for: target)
        }
        
        return false
    }
    
    // -------------------------------------
    public func validateMenuItemSelf() -> Bool
    {
        if self.submenu != nil { return true }
        
        guard let action = _action, action.canBeEnabled else { return false }
        
        if let selectorAction = action as? SelectorAction
        {
            #warning("DEBUG")
            if selectorAction.selector == #selector(NSText.cut(_:)) {
                print("BREAK ON ME")
            }
            if selectorAction.isEnabled,
               let target = target(for: selectorAction)
            {
                return validateMenuItem(for: target)
            }
            
            return false
        }
        else { return action.enabledValidator?() ?? true }
        
    }

    private let validateMenuItemSelector =
        #selector(NSMenuItemValidation.validateMenuItem(_:))
    private let validateUIItemSelector =
        #selector(NSUserInterfaceValidations.validateUserInterfaceItem(_:))
    
    // -------------------------------------
    private func validateMenuItem(for target: NSObject) -> Bool
    {
        var useSelectors: Bool { true }

        if useSelectors
        {
            return validate(target, with: validateMenuItemSelector)
                ?? validate(target, with: validateUIItemSelector)
                ?? true
        }
        else
        {
            return (target as? NSMenuItemValidation)?.validateMenuItem(self)
                ?? (target as? NSUserInterfaceValidations)?
                    .validateUserInterfaceItem(self)
                ?? true
        }
    }
    
    // -------------------------------------
    private func validate(_ target: NSObject, with selector: Selector) -> Bool?
    {
        guard target.responds(to: selector) else { return nil }
        
        let result = target.perform(selector, with: self)?
            .takeUnretainedValue()
        
        return unsafeBitCast(result, to: Int.self) != 0
    }
    
    // MARK:- Selector method overrides
    // -------------------------------------
    /*
     We need to pretend to respond to the selectors of SelectorActions, so we
     override some NSObject selector methods.
     */
    // -------------------------------------
    private func actionSelector(
        if aSelector: Selector,
        matches action: Action?) -> Selector?
    {
        guard let actionSelector = (action as? SelectorAction)?.selector else {
            return nil
        }
        
        return aSelector == actionSelector ? actionSelector : nil
    }

    // -------------------------------------
    public override func responds(to aSelector: Selector!) -> Bool
    {
        #warning("DEBUG")
        if aSelector == #selector(NSText.cut(_:)) {
            print("\(#function) for cut")
        }
        guard aSelector == menuItemActionSelector, (_action?.isEnabled ?? false)
        else { return super.responds(to: aSelector) }
        
        if let actionSelector = actionSelector(if: aSelector, matches: _action)
        {
            return target?.responds(to: actionSelector) ?? false
        }
    
        return super.responds(to: aSelector)
    }
    
    // -------------------------------------
    public override func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>!
    {
        guard aSelector == menuItemActionSelector, (_action?.isEnabled ?? false)
        else { return super.perform(aSelector) }
        
        if let actionSelector = actionSelector(if: aSelector, matches: _action)
        {
            return target?.perform(actionSelector)
        }
    
        return super.perform(aSelector)
    }
    
    // -------------------------------------
    public override func perform(
        _ aSelector: Selector!,
        with object: Any!) -> Unmanaged<AnyObject>!
    {
        guard aSelector == menuItemActionSelector, (_action?.isEnabled ?? false)
        else { return super.perform(aSelector, with: object) }
        
        if let actionSelector = actionSelector(if: aSelector, matches: _action)
        {
            return target?.perform(actionSelector, with: object)
        }
    
        return super.perform(aSelector, with: object)
    }
}
