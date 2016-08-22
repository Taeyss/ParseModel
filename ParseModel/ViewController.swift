//
//  ViewController.swift
//  ParseModel
//
//  Created by liang wang on 16/8/22.
//  Copyright © 2016年 liang wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         *测试
         */
        let dic = ["name": "wangl",
                   "sex": "fale",
                   "address": "zhengzhou",
                   "info": ["k1": "v1","k2": "v2"],
                   "age": 9999,
                   "ok": -111,
                   "car": "ccc",
                   "computer": ["company": "company1", "name": "name1", "price": 111.0],
                   "computerArray": [["company": "company1", "name": "name1", "price": 111.0],["company": "company2", "name": "name2", "price": 222.0]]]
        let model : SwiftModel = ParseModel.parseDictionary(dic, className: "SwiftModel") as! SwiftModel
        print("\(model.name,model.sex,model.address,model.computer!.company!,model.info.first,model.computerArray_Class_Computer?.last?.company)")
        
        let xdic = ParseModel.parseModel(model)
        ///比较转换前和转换后的打印数据比较
        print("\(xdic)")
        print("\(dic)")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

