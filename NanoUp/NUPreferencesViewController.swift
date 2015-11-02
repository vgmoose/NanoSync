//
//  NUPreferencesView.swift
//  NanoUp
//
//  Created by Kara on 11/2/15.
//  Copyright © 2015 Ricky Ayoub. All rights reserved.
//

import Foundation
import AppKit

class NUPreferencesViewController : NSViewController, NSWindowDelegate
{
    @IBOutlet var   nameField: NSTextField!
    @IBOutlet var secretField: NSTextField!
    @IBOutlet var updateField: NSTextField!
    @IBOutlet var fetchButton:    NSButton!
    
    override func viewDidLoad()
    {
        load()
//        self.parentViewController.delegate = self
    }
    
    func save()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setValue(  nameField.stringValue, forKey: config.name          )
        defaults.setValue(secretField.stringValue, forKey: config.secretKey     )
        defaults.setValue(updateField.stringValue, forKey: config.updateInterval)
        
        defaults.synchronize()
    }
    
    @IBAction func doneEditing(sender: AnyObject)
    {
        save()
    }
    
    @IBAction func goToNanoSite(sender: AnyObject)
    {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://nanowrimo.org/api/wordcount")!)
    }
    
    func load()
    {
          nameField.stringValue = "anabelle"
        secretField.stringValue = "abc123"
        updateField.stringValue = "300"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey(config.name)
        {
            nameField.stringValue = name
        }
        
        if let secret = defaults.stringForKey(config.secretKey)
        {
            secretField.stringValue = secret
        }
        
        if let update = defaults.stringForKey(config.updateInterval)
        {
            updateField.stringValue = update
        }
    }
    
    func windowWillClose(notification: NSNotification)
    {
        save()
    }
    
}