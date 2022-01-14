//
//  RxSwiftFunction.swift
//  Demo
//
//  Created by Appinventiv on 8/9/20.
//  Copyright © 2020 Appinventiv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

class Test{
    
    
    
    let textField = UITextField()
    
    
    // Observe Text Field Value
    func observerTExtField(){
        textField.rx.text.subscribe { (value) in
            print("ddd", value)
        }
    }
    
    //Observe the string And Add some string
    
    func addSomeString(){
        let observe1 = textField.rx.text.asObservable()
        let value =  observe1.map { (value) -> String in
            return (value ?? "")+"kunal"
        }
        
        value.bind(onNext: {text in
            print(text)
        })
    }
    
    
    func combineMultipleSubject(){
        
        let publish1 = PublishSubject<Int>()
        let publish2 = PublishSubject<Int>()
        Observable.of(publish1,publish2).merge().subscribe(onNext:{
            print($0)
        }
        )
        publish1.onNext(20)
        publish1.onNext(40)
        publish1.onNext(60)
        publish2.onNext(1)
        publish1.onNext(80)
        publish2.onNext(2)
        publish1.onNext(100)
        
        
    }
    
    
    func startWithSubject(){
        Observable.of(2,3).startWith(1,10).subscribe(onNext:{
            print($0)
        })
    }
    
    
//        func check(){
//           let loginValidation = accountInfoTextField
//            .rx.text
//            .map({!($0?.isEmpty ?? false)})
//            .share(replay: 1)
//
//             let userNameValidation = passwordTextField
//                .rx.text
//                .map({!($0?.isEmpty ?? false)})
//                .share(replay: 1)
//
//             let enableButton = Observable.combineLatest(loginValidation, userNameValidation) { (login, name) in
//                return login && name
//             }
//
//            enableButton.bind(onNext: {value in
//                print(value)
//            }).disposed(by: rx.disposeBag)
//        }

    
}
