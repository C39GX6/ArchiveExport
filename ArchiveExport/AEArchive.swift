//
//  AEArchive.swift
//  ArchiveExport
//
//  Created by 刘诗彬 on 14/10/29.
//  Copyright (c) 2014年 Stephen. All rights reserved.
//

import Cocoa

class AEArchive: NSObject {
    var createDate : NSDate!
    var version : String!
    var buildVersion : String!
    var identifier : String!
    var name : String!
    var icon : NSImage!
    var appPath : String!
 
    var dateString : String{
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle;
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle;
        if createDate==nil{
            createDate = NSDate();
        }
        return formatter.stringFromDate(createDate);
    }
    
    init(path:String) {
        let infoPath = path + "/info.plist"
        let info = NSDictionary(contentsOfFile: infoPath)
        createDate = info?.objectForKey("CreationDate") as! NSDate
        name = info?.objectForKey("Name") as! String
        
        let applicationProperties = info?.objectForKey("ApplicationProperties") as! NSDictionary!
        
        if applicationProperties != nil{
            version = applicationProperties.objectForKey("CFBundleShortVersionString") as! String
            buildVersion = applicationProperties.objectForKey("CFBundleVersion") as! String
            identifier = applicationProperties.objectForKey("CFBundleIdentifier") as! String
            
            let appBundleName = applicationProperties.objectForKey("ApplicationPath") as! String
            appPath = path + "/Products/" + appBundleName
            
            let iconPaths = applicationProperties.objectForKey("IconPaths") as! NSArray!
            
            if iconPaths != nil{
                let iconName = iconPaths.objectAtIndex(0) as! String
                let iconPath = path + "/Products/" + iconName;
                icon = NSImage(contentsOfFile: iconPath)
            }
        }
    }
}
