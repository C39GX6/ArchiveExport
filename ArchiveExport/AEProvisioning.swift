//
//  AEProvisioning.swift
//  ArchiveExport
//
//  Created by 刘诗彬 on 14/10/29.
//  Copyright (c) 2014年 Stephen. All rights reserved.
//

import Cocoa

class AEProvisioning: NSObject {
    var name : String?
    var identifier : String?
    
    init(filePath:String){
        let originData = NSData(contentsOfFile: filePath)
        var content = NSString(data: originData!, encoding: NSASCIIStringEncoding)
        
        let startRange = content?.rangeOfString("<plist")
        let endRange = content?.rangeOfString("</plist>")
        if startRange?.location != NSNotFound && endRange?.location != NSNotFound{
            content = content?.substringWithRange(NSMakeRange(startRange!.location, NSMaxRange(endRange!)))
        }
        let data = content?.dataUsingEncoding(NSUTF8StringEncoding)
        var provisioningInfo : [String:AnyObject]?
        
        do {
            provisioningInfo = try NSPropertyListSerialization.propertyListWithData(data!, options: .Immutable, format: nil) as? [String:AnyObject]
        } catch {
            return
        }
        
        if (provisioningInfo != nil) {
            name = provisioningInfo?["Name"] as? String
            identifier = provisioningInfo?["UUID"] as? String
        }
    }
}
