//
//  ContactsFetch.swift
//  Demo
//
//  Created by Admin on 31/03/21.
//  Copyright © 2021 Appinventiv. All rights reserved.
//

import Foundation
import Contacts
import UIKit

let sharedAppDelegate = UIApplication.shared.delegate as! AppDelegate

class ContactFetch{
    
    static let shared = ContactFetch()
    private let store = CNContactStore()
    
    private init(){
        
    }
    
    func getCurrentContactListFromPhone(compilationClosure: @escaping (_ arrContectDict:NSMutableArray)->()){
        //Not Authorized Return
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authorizationStatus != .authorized{
            compilationClosure([])
        }else{
            let arrContactsDicts = NSMutableArray()
            var i:Int = 1
            for contact in getCurrentPhoneContact(){
                // Get All Phone number
                var phoneNumbers:String = ""
                for phoneNumber in contact.phoneNumbers{
                    let phoneStringValue = digitsForPhone(phoneNumber)
                    if !phoneStringValue.isEmpty && phoneStringValue.count > 6{
                        let code = phoneNumber.value.value(forKey: "countryCode") as? String ?? "+91"
                        let formattedValue = KSContactHelper.shared.getCountryPhonceCode(code.uppercased())
                        phoneNumbers =  phoneNumbers+formattedValue+" "+phoneStringValue+","
                    }
                }
                let name:String = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                let contactData:NSMutableDictionary = NSMutableDictionary()
                if phoneNumbers.count > 0{
                    phoneNumbers = String(phoneNumbers.dropLast())
                }
                contactData.setObject(i, forKey: "No." as NSCopying);
                contactData.setObject(name, forKey: "name" as NSCopying);
                contactData.setObject(phoneNumbers, forKey: "numbers" as NSCopying);
                arrContactsDicts.add(contactData)
                i = i+1
            }
            compilationClosure(arrContactsDicts)
        }
    }
    
    func getCurrentPhoneContact() -> [CNContact] {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactIdentifierKey, CNContactEmailAddressesKey,CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as! [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        var contactsData = [CNContact]()
        do {
            try store.enumerateContacts(with: request) { (contact: CNContact, _) in
                contactsData.append(contact)
            }
            return contactsData
        } catch let err {
            return []
        }
    }
    
    func digitsForPhone(_ phoneNumber:CNLabeledValue<CNPhoneNumber>) -> String{
        var strPhoneNumber = ((phoneNumber.value as CNPhoneNumber).value(forKey: "digits") as? String ?? "")
        if strPhoneNumber.first == "0"{
            strPhoneNumber = strPhoneNumber.substring(from: strPhoneNumber.index(strPhoneNumber.startIndex, offsetBy: 1))
        }
        return strPhoneNumber
    }
    
    
}


extension UIWindow {
    var currentViewController: UIViewController? {
        guard let rootViewController = self.rootViewController else { return nil}
        return topViewController(for: rootViewController)
    }
    
    private func topViewController(for rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        switch rootViewController {
        case is UINavigationController:
            let navigationController = rootViewController as! UINavigationController
            return topViewController(for: navigationController.viewControllers.last)
        case is UITabBarController:
            let tabBarController = rootViewController as! UITabBarController
            return topViewController(for: tabBarController.selectedViewController)
        default:
            guard let presentedViewController = rootViewController.presentedViewController else {
                return rootViewController
            }
            return topViewController(for: presentedViewController)
        }
    }
}
