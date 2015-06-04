//
//  AppDelegate.swift
//  ArchiveExport
//
//  Created by 刘诗彬 on 14/10/29.
//  Copyright (c) 2014年 Stephen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,NSWindowDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSApplication.sharedApplication().windows.first?.makeKeyAndOrderFront(nil);
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag{
            sender.windows.first?.makeKeyAndOrderFront(sender);
        }
        return true
    }
}

