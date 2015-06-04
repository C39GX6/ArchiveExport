//
//  AEProvisioning.swift
//  ArchiveExport
//
//  Created by 刘诗彬 on 14/10/29.
//  Copyright (c) 2014年 Stephen. All rights reserved.
//

import Cocoa

class AEProvisioning: NSObject {
    var name : String!
    var identifier : String!
    
    init(filePath:String){
        var originData = NSData(contentsOfFile: filePath)
        var content = NSString(data: originData!, encoding: NSASCIIStringEncoding)
        
        let startRange = content?.rangeOfString("<plist")
        let endRange = content?.rangeOfString("</plist>")
        if startRange!.location != NSNotFound  && endRange?.location != NSNotFound{
            content = content?.substringWithRange(NSMakeRange(startRange!.location, NSMaxRange(endRange!)))
        }
        let data = content?.dataUsingEncoding(NSUTF8StringEncoding)
        var error: NSError?
        let provisioningInfo = NSPropertyListSerialization.propertyListWithData(data!,options: 0,format: nil,error: &error) as! NSDictionary!
        if provisioningInfo != nil{
            name = provisioningInfo.objectForKey("Name") as! String
            identifier = provisioningInfo.objectForKey("UUID") as! String
        }
    }
}
