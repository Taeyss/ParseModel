//
//  ParseModel.swift
//  HttpSwift
//
//  Created by liang wang on 16/8/17.
//  Copyright © 2016年 liang wang. All rights reserved.
//

import Foundation

class ParseModel {
    
    /*
     *需要进行动态解析的类，必须符合ParseModelProtocol协议，必须继承自NSObject。同时因为setValue(_: forKey:)方法，在所有NSObject的子类中都默认实现，所以不需要再写
     *传入的className需要转换成 命名空间.className
     */
    class func parseDictionary(dictionary: [String: AnyObject], className: String) -> Any? {
        //
        guard let nameSpace = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] else {
            return nil
        }
        guard let anyCl : AnyClass? = NSClassFromString(nameSpace as! String + "." + className) else {
            return nil
        }
        guard let cls = (anyCl as! ParseModelProtocol.Type?) else {
            return nil
        }
        let retObejct = cls.init()
        
        ///获取属性集合
        var propertyNum : UInt32 = 0
        let properties = class_copyPropertyList(anyCl, &propertyNum)
        for index in 0..<Int(propertyNum) {
            let property = properties[index]
            let propertyName = String(UTF8String: property_getName(property))
            let propertyAttr = String(UTF8String: property_getAttributes(property))
            print("propertyName: \(propertyName) \n propertyAttr: \(propertyAttr)")
            let realPropertyName = propertyName?.componentsSeparatedByString("_Class_").first
            guard var propertyValue = dictionary[realPropertyName!] else {
                continue
            }
            let propertyValueType = self.getRetType(propertyAttr!)
            ///区分value的类型
            switch propertyValueType {
            case .ModelDataTypeString:
                print("ModelDataTypeString")
            case .ModelDataTypeObject:
                var tempClassName = propertyAttr!.componentsSeparatedByString("8").last
                tempClassName = tempClassName?.componentsSeparatedByString("\"").first
                propertyValue = self.parseDictionary(propertyValue as! [String : AnyObject], className: tempClassName!) as! AnyObject
            case .ModelDataTypeArray:
                ///处理_Class_
                let propertyNameAry = propertyName?.componentsSeparatedByString("_Class_")
                let tempSubClassName = propertyNameAry!.last
                var tempArray = Array<AnyObject>()
                var tempValue : [AnyObject] = propertyValue as! Array<AnyObject>
                for index in 0..<tempValue.count {
                    //
                    var value = tempValue[index]
                    if propertyNameAry?.count  > 1 {
                        value = self.parseDictionary(value as! [String : AnyObject], className: tempSubClassName!) as! AnyObject
                    }
                    tempArray.append(value)
                }
                propertyValue = tempArray
            default:
                print("")
            }
            retObejct.setValue(propertyValue, forKey: propertyName!)
        }
        
        free(properties)

        return retObejct
        
    }
    
    /*
     *将model实体转换为字典
     */
    class func parseModel(model: AnyObject) -> [String: AnyObject] {
        
        var tempDic = [String: AnyObject]()
        
        let anyCl : AnyObject.Type = model.dynamicType
        
        ///获取属性集合
        var propertyNum : UInt32 = 0
        let properties = class_copyPropertyList(anyCl, &propertyNum)
        for index in 0..<Int(propertyNum) {
            //
            let property = properties[index]
            let propertyName = String(UTF8String: property_getName(property))
            let propertyAttr = String(UTF8String: property_getAttributes(property))
            print("propertyName: \(propertyName) \n propertyAttr: \(propertyAttr)")
            
            let realPropertyName : String? = propertyName?.componentsSeparatedByString("_Class_").first
            guard var propertyValue = model.valueForKey(propertyName!) else {
                continue
            }
            let propertyValueType = self.getRetType(propertyAttr!)
            ///区分value的类型
            switch propertyValueType {
            case .ModelDataTypeString:
                print("ModelDataTypeString")
            case .ModelDataTypeObject:
                var tempClassName = propertyAttr!.componentsSeparatedByString("8").last
                tempClassName = tempClassName?.componentsSeparatedByString("\"").first
                let dic = self.parseModel(propertyValue)
                propertyValue = dic
            case .ModelDataTypeArray:
                ///处理_Class_
                let propertyNameAry = propertyName?.componentsSeparatedByString("_Class_")
                    var tempArray = Array<AnyObject>()
                    var tempValue : [AnyObject] = propertyValue as! Array<AnyObject>
                    for index in 0..<tempValue.count {
                        //
                        var value = tempValue[index]
                        if propertyNameAry?.count  > 1 {
                            value = self.parseModel(value)
                        }
                        tempArray.append(value)
                    }
                    propertyValue = tempArray
            default:
                print("default")
            }
            tempDic[realPropertyName!] = propertyValue
        }
        free(properties)

        return tempDic
}
    class func getRetType(dataTypeStr: String) -> ModelDataType {
        //
        var retType = ModelDataType.ModelDataTypeInt
        if dataTypeStr.hasPrefix("T@") {
            retType = .ModelDataTypeObject
        }
        if (dataTypeStr.rangeOfString("NSString") != nil) {
            //
            retType = .ModelDataTypeString
        }
        if (dataTypeStr.rangeOfString("NSArray") != nil) {
            //
            retType = .ModelDataTypeArray
        }
        if (dataTypeStr.rangeOfString("NSDictionary") != nil) {
            //
            retType = .ModelDataTypeDictionary
        }
        return retType
    }
}

enum ModelDataType {
    case ModelDataTypeObject, ModelDataTypeString, ModelDataTypeArray, ModelDataTypeDictionary, ModelDataTypeDouble, ModelDataTypeInt, ModelDataTypeFloat, ModelDataTypeBool
}

protocol ParseModelProtocol {
    init()
    func setValue(value: AnyObject?, forKey key: String)
}

