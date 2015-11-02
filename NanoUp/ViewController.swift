//
//  ViewController.swift
//  NanoUp
//
//  Created by Kara on 11/2/15.
//  Copyright © 2015 Ricky Ayoub. All rights reserved.
//


import Cocoa

extension String {
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}

class ViewController: NSViewController
{
    @IBOutlet weak var statusLabel: NSTextField!
    var enabled: Bool = false
    var timer: NSTimer?
    @IBOutlet weak var updateButton: NSButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.stringForKey(config.name) == nil
        {
            performSegueWithIdentifier("prefs", sender: self)
        }

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject?
        {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func getConfigs() -> (String, String, Float)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        var myName:   String = ""
        var mySecret: String = ""
        var myUpdate: String = ""
        
        if let name = defaults.stringForKey(config.name)
        {
            myName = name
        }
        
        if let secret = defaults.stringForKey(config.secretKey)
        {
            mySecret = secret
        }
        
        if let update = defaults.stringForKey(config.updateInterval)
        {
            myUpdate = update
        }
        
        if myName == "" || mySecret == "" || myUpdate == ""
        {
            toggleService(self)
            performSegueWithIdentifier("prefs", sender: self)
            return ("", "", 0)
        }
        
        return (myName, mySecret, Float(myUpdate)!)
    }

    func updateWc(name: String, key: String)
    {
        let applescriptPath = NSBundle.mainBundle().pathForResource("word_count", ofType: "applescript")

        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = [applescriptPath!, name, key]
        
        task.launch()
    }
    
    func startWc() -> Float
    {
        let config = getConfigs()
        let name = config.0
        let key = config.1
        let interval = config.2
        
        if interval <= 0 { return 0}
        
        updateWc(name, key: key)
        return interval
    }

    @IBAction func toggleService(sender: AnyObject)
    {
        enabled = !enabled
        
        if enabled
        {
            let interval = startWc()
            
            if (interval == 0) { return }
            
            timer = NSTimer.scheduledTimerWithTimeInterval(Double(interval), target: self, selector: Selector("startWc"), userInfo: nil, repeats: true)
            
            statusLabel.stringValue = "Status: Running!"
            updateButton.title = "Stop Updater"
            
        }
        else
        {
//            updateWc()
            if timer != nil
            {
                timer!.invalidate()
            }
            
            statusLabel.stringValue = "Status: Not Running"
            updateButton.title = "Start Updater"
        }
    }

}

