//
//  RealmVC.swift
//  Demo
//
//  Created by Appinventiv on 8/25/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import RealmSwift

class RealmVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        //updateDB()
        //deleteUser()
        let realm = try! Realm()
        print(realm.configuration.fileURL)
    }
    
    
    func setData(){
        
        let realm = try! Realm()
        
        let passport = Passport("123","12 Dec")
        let toDo1 = ToDo("Testing1")
        let toDo2 = ToDo("Testing2")
        
        
        let user = User("Sony", id: "3")
        user.passport = passport
        user.toDo.append(objectsIn:[toDo1,toDo2])
        
        try! realm.write{
            user.toDo.append(objectsIn:[toDo1,toDo2])
        }
        
    }
    
    
    func updateDB(){
        let realm = try! Realm()
        
        let toDo =  realm.object(ofType: Passport.self, forPrimaryKey: "123")
        
        try! realm.write{
            toDo?.date = "13 Dec"
        }
    }
    
    func deleteUser(){
        let realm = try! Realm()
        
        if let toDo =  realm.object(ofType: Passport.self, forPrimaryKey: "123"){
        
        try! realm.write{
            realm.delete(toDo)
        }
        }
    }
    
    
}



