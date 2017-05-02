//
//  ObserverManager.swift
//  ObserverManager
//
//  Created by Tim Bodeit on 08/12/14.
//
//  Modified to Swift 3.0 by Daniel Freiling on 01/05/17.
//

import Foundation

/**
 A class that can be used to sign up for Key-Value Observing by
 passing a Swift closure.
 
 Every object, that uses KVO should have its own NotificationManager.
 All observers are automatically deregistered when the object is deallocated.
 */
public class ObserverManager : NSObject {
    
    // MARK: Public API
    
    /**
     Registers a new observer for a given object and keypath.
     
     - parameter object:  The object to observe
     - parameter keyPath: The keyPath to observe
     - parameter block:   The block that is called when the value changed. Gets called with the new value.
     */
    public func registerObserverForObject(object: NSObject, keyPath: String, block: @escaping (_ value: NSObject) -> ()) {
        var closuresForKeyPaths = Dictionary<String, Array<(NSObject) -> ()>>()
        if let cfkp = closuresForKeypathsForObservedObjects[object] {
            closuresForKeyPaths = cfkp
        }
        var closures = Array<(NSObject) -> ()>()
        if let c = closuresForKeyPaths[keyPath] {
            closures = c
        }
        closures.append(block)
        closuresForKeyPaths[keyPath] = closures
        closuresForKeypathsForObservedObjects[object] = closuresForKeyPaths
        
        object.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
    }
    
    /**
     Removes all observers that observe the given keypath on the given object.
     */
    public func deregisterObserversForObject(object: NSObject, andKeyPath keyPath: String) {
        guard var closuresForKeyPaths = closuresForKeypathsForObservedObjects[object] else {
            return // No observers registered for given object and keyPath
        }
        guard let _ = closuresForKeyPaths[keyPath] else {
            return // No observers registered for given object and keyPath
        }
        
        object.removeObserver(self, forKeyPath: keyPath)
        
        closuresForKeyPaths[keyPath] = nil
        closuresForKeypathsForObservedObjects[object] = closuresForKeyPaths
    }
    
    /**
     Removes all observers that observe any keypath on the given object.
     */
    public func deregisterObserversForObject(object: NSObject) {
        guard let closuresForKeypaths = closuresForKeypathsForObservedObjects[object] else {
            return // No observers registered for the given object
        }
        
        for (keypath, _) in closuresForKeypaths {
            object.removeObserver(self, forKeyPath: keypath)
        }
        
        closuresForKeypathsForObservedObjects[object] = nil
    }
    
    /**
     Removes all observers that observe any keypath on any object.
     */
    public func deregisterAllObservers() {
        for (object, closuresForKeyPaths) in closuresForKeypathsForObservedObjects {
            for (keypath, _) in closuresForKeyPaths {
                object.removeObserver(self, forKeyPath: keypath)
            }
        }
        
        closuresForKeypathsForObservedObjects.removeAll(keepingCapacity: false)
    }
    
    // MARK: Private Logic
    
    // Using old declaration Dictionary<a,b> instead of [a:b]
    // rdar://19175346 (on openradar)
    private var closuresForKeypathsForObservedObjects = Dictionary<NSObject, Dictionary<String, Array<(NSObject) -> ()>>>()
    
    override open func observeValue(forKeyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        NSLog("Got observeValue callback for \(forKeyPath ?? "<none>")")
        
        guard let keyPath = forKeyPath else { return }
        guard let object = object as? NSObject else { return }
        
        if let closures = closuresForKeypathsForObservedObjects[object]?[keyPath] {
            for closure in closures {
                closure(object)
            }
        }
    }
    
    deinit {
        deregisterAllObservers()
    }
}
