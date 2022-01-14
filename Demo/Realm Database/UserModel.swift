//
//  UserModel.swift
//  Demo
//
//  Created by Appinventiv on 8/25/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import Foundation
import RealmSwift

class User:Object{
    
    @objc dynamic var userName:String = ""
    @objc dynamic var id:String = ""
    @objc dynamic var passport:Passport?
    let toDo = List<ToDo>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(_ name:String,id:String){
        self.init()
        self.userName = name
        self.id = id
    }
    
}


class Passport:Object{
    
    @objc dynamic var passportNumber:String = ""
    @objc dynamic var date:String = ""
    
    let ofUser = LinkingObjects(fromType: User.self, property: "passport")
    
    override static func primaryKey() -> String? {
        return "passportNumber"
    }
    
    convenience init(_ number:String,_ date:String){
        self.init()
        self.passportNumber = number
        self.date = date
    }
}

class ToDo:Object{
    
    @objc dynamic var name:String = ""
    let ofUser = LinkingObjects(fromType: User.self, property: "toDo")
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    convenience init(_ name:String){
        self.init()
        self.name = name
    }
}
