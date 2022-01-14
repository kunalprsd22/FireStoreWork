//
//  ReadWriteCSVVC.swift
//  Demo
//
//  Created by Admin on 31/03/21.
//  Copyright © 2021 Appinventiv. All rights reserved.
//

import UIKit
import SwiftCSVExport
import Contacts

class ReadWriteCSVVC: UIViewController {
    
    private let store = CNContactStore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    

    
//    func readCSVPath(_ filePath: String) {
//
//        let request = NSURLRequest(url:  URL(fileURLWithPath: filePath) )
//        webview.loadRequest(request as URLRequest)
//
//        // Read File and convert as CSV class object
//        _ = CSVExport.readCSVObject(filePath);
//
//        // Use 'SwiftLoggly' pod framework to print the Dictionary
////        loggly(LogType.Info, text: readCSVObj.name)
////        loggly(LogType.Info, text: readCSVObj.delimiter)
//    }
    

    @IBAction func click(_ sender: Any) {
        //setupForAuthorization()
        
        let data  = CSVExport.export.read(filename: "userlist.csv")
       
        let writeCSVObj = CSV()
        writeCSVObj.name = "userlist"
        
        
    }
    
    
}



extension ReadWriteCSVVC{
    
    func createCSVFile(data:NSMutableArray){
        // Create a object for write CSV
        let header = ["No.","name","numbers"]
        let writeCSVObj = CSV()
        writeCSVObj.rows = data
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = header as NSArray
        writeCSVObj.name = "userlist"
        
        // Write File using CSV class object
        let output = CSVExport.export(writeCSVObj);
        if output.result.isSuccess {
            guard let filePath =  output.filePath else {
                print("Export Error: \(String(describing: output.message))")
                return
            }
            
            print("File Path: \(filePath)")
            //self.readCSVPath(filePath)
        } else {
            print("Export Error: \(String(describing: output.message))")
        }
    }
    
    
    func fetchContacts(){
        ContactFetch.shared.getCurrentContactListFromPhone {[weak self] (value) in
            self?.createCSVFile(data: value)
        }
    }
    
    
    
    private func setupForAuthorization(){
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .notDetermined:
            store.requestAccess(for: .contacts) { (success, error) in
                guard success else {
                    return
                }
                self.fetchContacts()
            }
        case .authorized:
            self.fetchContacts()
        case .denied:
            showContactSettingPopup()
        default:
            break
        }
    }
    
    func showContactSettingPopup(){
        let alertController = UIAlertController(title: "Alert", message: "Please provide the permission", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler:nil))
        alertController.addAction(UIAlertAction(title: "Setting", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(url)
            }
        }))
        sharedAppDelegate.window?.currentViewController?.present(alertController, animated: false)
    }
}
