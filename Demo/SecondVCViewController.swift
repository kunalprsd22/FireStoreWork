//
//  SecondVCViewController.swift
//  Demo
//
//  Created by Appinventiv on 6/1/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SecondVCViewController: UIViewController {
    
    
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let observe1 = textField1.rx.text.asObservable()
        let observe2 = textField2.rx.text.asObservable()

        

//        //let observe1Stream = observe1.map { [weak self] (text) -> Bool in
//            if text?.count == 0{
//                return false
//            }else{
//                return true
//            }
//        }

        let observe2Stream = observe2.map { [weak self] (text) -> Bool in
            print("ddddd")
            
            if text?.count == 0{
                return false
            }else{
                return true
            }
        }
        
        let observe1Stream = textField1.rx.text.map { (value) -> Bool in
            if value?.count == 0{
                return false
            }else{
                return true
            }
        }
        

        

//        let enableButton = Observable.combineLatest(observe1Stream, observe2Stream) { (login, name) in
//            return login && name
//        }
//
//        enableButton.bind(onNext: {value in
//            print(value)
//        }).disposed(by: rx.disposeBag)
        
        
        
        
        
    }
    
    
    
    @IBAction func click(_ sender: Any) {
        
    }
    
    
    
    
}


