//
//  ViewController.swift
//  NanoUp
//
//  Created by Kara on 11/2/15.
//  Copyright © 2015 Ricky Ayoub. All rights reserved.
//


import Cocoa
import ScriptingBridge

extension String {
    func sha1() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA1_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA1(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}

@objc protocol PagesApplication {
    optional var documents: SBElementArray {get}
}

@objc protocol PagesDocument {
    optional var bodyText: PagesText {get}
}

@objc protocol PagesText {
    optional var words: SBElementArray {get}
}

extension SBApplication : PagesApplication {}


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
        let pages: PagesApplication = SBApplication(bundleIdentifier: "com.apple.iWork.Pages")!
        let doc = pages.documents!.firstObject
        let text: PagesText = doc!.bodyText!
        let words: SBElementArray = text.words!
        let wc:String = String(words.count)
        
        let requestURL = NSURL(string:"http://nanowrimo.org/api/wordcount")!
        
        let fullCode = (key+name+wc).sha1()
        
        let submitMe = "_method=PUT&hash="+fullCode+"&name="+name+"&wordcount="+wc
        print(submitMe)
        
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = "POST"
        request.HTTPBody =  submitMe.dataUsingEncoding(NSUTF8StringEncoding)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                print(response)
                
        }


        
    }
    
    func completed(a:NSData?, b:NSURLResponse?, c:NSError?) -> Void
    {
        print(b)
    }


    
    func startWc() -> Float
    {
        let config = getConfigs()
        let name = config.0
        let key = config.1
        let interval = config.2
        
        if interval <= 0 { return 0 }
        
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
            updateButton.title = "Stop"
            
        }
        else
        {
//            updateWc()
            if timer != nil
            {
                timer!.invalidate()
            }
            
            statusLabel.stringValue = "Status: Not Running"
            updateButton.title = "Sync Now"
        }
    }

}

