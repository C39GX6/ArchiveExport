//
//  ViewController.swift
//  ArchiveExport
//
//  Created by 刘诗彬 on 14/10/29.
//  Copyright (c) 2014年 Stephen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSOpenSavePanelDelegate,NSWindowDelegate{

    @IBOutlet weak var archiveButton: NSPopUpButton!
    @IBOutlet weak var provisioningButton: NSPopUpButton!
    @IBOutlet weak var indicator: NSProgressIndicator!
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var statLabel: NSTextField!
    @IBOutlet weak var exportButton: NSButton!
    
    @IBOutlet weak var infoLabel: NSTextField!
    var exportTask : NSTask!
    var timer : NSTimer!
    var exportPath : String!
    
    var archives : [AEArchive]!
    var provisionings : [AEProvisioning]!
    
    var exporting = false

    
    @IBAction func export(sender: AnyObject) {
        if exportTask != nil && exportTask.running {
            return
        }
        
        let archive = selectedArchive()
        let provisioning = selectedProvisining()
        if archive == nil || provisioning == nil{
            return
        }
        let savePanel = NSSavePanel();
        savePanel.allowedFileTypes = ["ipa"]
        savePanel.allowsOtherFileTypes = false
        savePanel.directoryURL = NSURL(fileURLWithPath: NSHomeDirectory()+"/Desktop")
        savePanel.nameFieldStringValue = archive.name
        savePanel.delegate = self
        savePanel.beginSheetModalForWindow(self.view.window!, completionHandler:{(NSModalResponse) -> () in })
    }
    
    func exportTo(path:String){
        if exportTask != nil && exportTask.running {
            return
        }
        statLabel.stringValue = ""
        let archive = selectedArchive()
        let provisioning = selectedProvisining()
        if archive != nil && provisioning != nil{
            exportTask = NSTask();
            exportTask.launchPath = "/usr/bin/xcrun"
            exportPath = path
            exportTask.arguments = ["-sdk iphoneos","PackageApplication",archive.appPath!,"--embed",provisioning.identifier!,"-o",exportPath]
            exportTask.launch()
            setIsExporting(true)
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "checkResult", userInfo: nil, repeats: true)
        }
    }
    
    func checkResult(){
        if exportTask != nil{
            if exportTask.running{
                setIsExporting(true)
            } else {
                setIsExporting(false)
                if NSFileManager.defaultManager().fileExistsAtPath(exportPath){
                    statLabel.textColor = NSColor.greenColor()
                    statLabel.stringValue = "导出成功"
                } else {
                    statLabel.textColor = NSColor.redColor()
                    statLabel.stringValue = "导出失败"
                }
            }
        } else {
            setIsExporting(false)
        }
    }
    
    func setIsExporting(exporting: Bool){
        exportButton.enabled = !exporting
        if !exporting {
            exportTask = nil;
            timer = nil;
            indicator.stopAnimation(nil)
        } else {
            indicator.startAnimation(nil)
        }
    }
    
    @IBAction func valueChanged(sender: AnyObject) {
        updateArchiveInfo()
    }
    
    func selectedArchive()->AEArchive!{
        let selectedIndex = archiveButton.indexOfSelectedItem
        var archive : AEArchive!
        if selectedIndex >= 0{
            archive = archives[selectedIndex]
        }
        return archive
    }
    
    func selectedProvisining()->AEProvisioning!{
        let selectedIndex = provisioningButton.indexOfSelectedItem
        var provisioning : AEProvisioning!
        if selectedIndex >= 0 {
          provisioning = provisionings[selectedIndex]
        }
        return provisioning
    }
    
    func updateArchiveInfo(){
        let archive = self.selectedArchive()
        if archive == nil {
            infoLabel.stringValue = "没有发现包"
            return
        }
        iconView.image = archive.icon
        let info = "\(archive.name)\n" + "Identifier:\(archive.identifier)\n" +
            "Version:\(archive.version) Build:\(archive.buildVersion)\n" + "Create Date:\(archive.dateString)"
        infoLabel.alignment = .Left
        infoLabel.stringValue = info
        
        let provisioning = AEProvisioning(filePath: archive.appPath + "/embedded.mobileprovision");
        
        for (index,i) in provisionings.enumerate(){
            if i.identifier == provisioning.identifier{
                provisioningButton.selectItemAtIndex(index)
                break
            }
        }
    }
    
    func reloadArchives(){
        let archivePaths = self.archivePaths()
        archives = [AEArchive]()

        for path:String in archivePaths{
            archives.append(AEArchive(path: path));
        }
        archives = archives.sort{$0.createDate.compare($1.createDate) == .OrderedDescending}
        let selectedItem = archiveButton.selectedItem
        archiveButton.removeAllItems()
        var archiveNames = [String]()
        for archive:AEArchive in archives{
            let displayName = "\(archive.name)_\(archive.version) \(archive.dateString)"
            archiveNames.append(displayName);
        }
        archiveButton.addItemsWithTitles(archiveNames)
        for item:NSMenuItem in archiveButton.itemArray{
            if item.title == selectedItem?.title{
                archiveButton.selectItem(item)
                break
            }
        }
        
        provisionings = [AEProvisioning]()
        let provisioningPaths = self.provisioningPaths()
        for path:String in provisioningPaths{
            provisionings.append(AEProvisioning(filePath:path));
        }
        provisioningButton.removeAllItems()
        for (index,provisioning) in provisionings.enumerate(){
            if let displayName = provisioning.name{
                provisioningButton.addItemWithTitle("(\(index))"+displayName)
            } else {
                provisioningButton.addItemWithTitle("(\(index))unknow")
            }
        }
        
        self.updateArchiveInfo()
    }

    func archivePaths()->[String]{
        let fileManger = NSFileManager.defaultManager()
        var archives = [String]()
        let archivesHome = NSHomeDirectory() + "/Library/Developer/Xcode/Archives/";
        if let enumerator = fileManger.enumeratorAtPath(archivesHome){
            while let path: AnyObject = enumerator.nextObject(){
                let subpath = path as! String
                if subpath.hasSuffix(".xcarchive"){
                    archives.append(archivesHome+subpath)
                    enumerator.skipDescendants();
                }
            }
        }
        return archives
    }

    func provisioningPaths()->[String]{
        let fileManger = NSFileManager.defaultManager()
        var provisionings = [String]()
        let provisioningsHome = NSHomeDirectory() + "/Library/MobileDevice/Provisioning Profiles/";
        if let enumerator = fileManger.enumeratorAtPath(provisioningsHome){
            while let path: AnyObject = enumerator.nextObject(){
                let subpath = path as! String
                if subpath.hasSuffix(".mobileprovision"){
                    provisionings.append(provisioningsHome+subpath)
                    enumerator.skipDescendants();
                }
            }
        }
        return provisionings
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadArchives()
        self.view.window?.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"applicationDidBecomeActiveNotification:", name: NSApplicationDidBecomeActiveNotification, object:nil)
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func panel(sender: AnyObject, userEnteredFilename filename: String, confirmed okFlag: Bool) -> String?
    {
        if okFlag {
            let path = sender.URL?!.path
            self.exportTo(path!)
            return path
        }
        return nil;
    }
    
    func applicationDidBecomeActiveNotification(notification: NSNotification) {
        self.reloadArchives()
    }
}

