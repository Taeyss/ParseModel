//
//  SwiftModel.swift
//  HttpSwift
//
//  Created by liang wang on 16/8/17.
//  Copyright © 2016年 liang wang. All rights reserved.
//

import Foundation

class SwiftModel : NSObject, ParseModelProtocol {
    //
    var name = "name"
    var sex = "sex"
    var address = "address"
    var area = [123]
    var age : UInt32 = 122
    var aaa : UInt8 = 1
    var info = ["": ""]
    var email : Float = 11.0
    var dou : Double = 11.22
    var ok : Bool = false
//    var cc : Character = "c"    ///不支持暂时
    var computer : Computer?
    var computerArray_Class_Computer : Array<Computer>?
    
    func sayHello() -> Void {
        print("F\(#function),L\(#line)")
    }
    
    required override init() {
        super.init()
    }
}

class Computer: NSObject, ParseModelProtocol {
    required override init() {
        super.init()
    }
    
    var company : String?
    var name : String?
    
}