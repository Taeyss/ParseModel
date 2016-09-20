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
    class func parseDictionary(dictionary: [String: AnyObject], className: String) -> AnyObject? {
        //
        guard let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] else {
            return nil
        }
        guard let anyCl = NSClassFromString(nameSpace as! String + "." + className) else {
            return nil
        }
        guard let cls = (anyCl as? ParseModelProtocol.Type) else {
            return nil
        }
        let retObejct = cls.init()
        
        ///获取属性集合
        let mir : Mirror = Mirror(reflecting: retObejct)
        let properties = self.obejctInfoWithMirror(mirror: mir)

        for index in 0..<properties.count {
            let property = properties[index]
            let propertyName = property.propertyName
            let realPropertyName = propertyName.components(separatedBy: "_Class_").first
            guard var propertyValue = dictionary[realPropertyName!] else {
                continue
            }
            let type = property.propertyType
            let propertyValueType = self.getRetType(dataType: type)
            
            ///区分value的类型
            switch propertyValueType {
            case .ModelDataTypeObject:
                propertyValue = self.parseDictionary(dictionary: propertyValue as! [String : AnyObject], className: type)!
            case .ModelDataTypeArray:
                ///处理_Class_
                let propertyNameAry = propertyName.components(separatedBy: "_Class_")
                let tempSubClassName = propertyNameAry.last
                var tempArray = Array<AnyObject>()
                var tempValue : [AnyObject] = propertyValue as! Array<AnyObject>
                for index in 0..<tempValue.count {
                    //
                    var value = tempValue[index]
                    if propertyNameAry.count  > 1 {
                        value = self.parseDictionary(dictionary: value as! [String : AnyObject], className: tempSubClassName!)!
                    }
                    tempArray.append(value)
                }
                propertyValue = tempArray as AnyObject
            default:
                print("")
            }
            retObejct.setValue(propertyValue, forKey: propertyName)
        }
        return retObejct as AnyObject?
    }
    
    /*
     *将model实体转换为字典
     */
    class func parseModel(model: AnyObject) -> [String: AnyObject] {
        
        var tempDic = [String: AnyObject]()
        
        ///获取属性集合
        let mir : Mirror = Mirror(reflecting: model)
        let properties = self.obejctInfoWithMirror(mirror: mir)
        
        for index in 0..<properties.count {
            //
            let property = properties[index]
            let propertyName = property.propertyName
            
            let realPropertyName : String? = propertyName.components(separatedBy: "_Class_").first
            guard var propertyValue = model.value(forKey: propertyName) else {
                continue
            }
            let type = property.propertyType
            let propertyValueType = self.getRetType(dataType: type)
            ///区分value的类型
            switch propertyValueType {
            case .ModelDataTypeObject:
                let dic = self.parseModel(model: propertyValue as AnyObject)
                propertyValue = dic
            case .ModelDataTypeArray:
                ///处理_Class_
                let propertyNameAry = propertyName.components(separatedBy: "_Class_")
                    var tempArray = Array<AnyObject>()
                    var tempValue : [AnyObject] = propertyValue as! Array<AnyObject>
                    for index in 0..<tempValue.count {
                        //
                        var value = tempValue[index]
                        if propertyNameAry.count  > 1 {
                            value = self.parseModel(model: value) as AnyObject
                        }
                        tempArray.append(value)
                    }
                    propertyValue = tempArray
            default:
                print("")
            }
            tempDic[realPropertyName!] = propertyValue as AnyObject?
        }

        return tempDic
}
    /*
     *获取实体的属性值和类型
     *使用递归遍历父类的属性值和类型
     */
    class func obejctInfoWithMirror(mirror: Mirror) -> [(propertyName: String, propertyType: String)] {
        
        var objectInfoArray = Array<(propertyName: String, propertyType: String)>()
        if let superMirro = mirror.superclassMirror {
            let tempArray = self.obejctInfoWithMirror(mirror: superMirro)
            objectInfoArray += tempArray
        }
        for case let (label?, value) in mirror.children {
            var tempValueType = String(describing: Mirror(reflecting: value).subjectType)
            let optionTagStr = "Optional<"
            if tempValueType.hasPrefix(optionTagStr) {
                let startIndex = tempValueType.range(of: optionTagStr)?.upperBound
                let endIndex = tempValueType.index(before: tempValueType.endIndex)
                let range = startIndex!..<endIndex
                tempValueType = tempValueType.substring(with: range)
            }
            let temp : (propertyName: String, propertyType: String) = (label, tempValueType)
            objectInfoArray.append(temp)
        }
        return objectInfoArray
    }
    
    /*
     *解析value的类型
     */
    class func getRetType(dataType: String) -> ModelDataType {
        //
        if dataType == "String" {
            return .ModelDataTypeString
        }
        if dataType.hasPrefix("Dictionary") {
            return .ModelDataTypeDictionary
        }
        if dataType.hasPrefix("Array") {
            return .ModelDataTypeArray
        }
        if dataType.hasPrefix("Bool") {
            return .ModelDataTypeBool
        }
        if dataType.hasPrefix("Double") {
            return .ModelDataTypeDouble
        }
        if (dataType.range(of: "Int") != nil) {
            return .ModelDataTypeInt
        }
        if dataType.hasPrefix("Float") {
            return .ModelDataTypeFloat
        }
        //TODO: 增加其他基本类型判断
        return .ModelDataTypeObject
    }
}

enum ModelDataType {
    case ModelDataTypeString, ModelDataTypeDictionary, ModelDataTypeObject, ModelDataTypeArray, ModelDataTypeBool, ModelDataTypeInt, ModelDataTypeDouble, ModelDataTypeFloat
}

protocol ParseModelProtocol {
    init()
    func setValue(_ value: Any?, forKey key: String)
}

