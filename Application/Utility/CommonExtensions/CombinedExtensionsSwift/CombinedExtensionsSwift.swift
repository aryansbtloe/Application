//
//  CombinedExtensions.swift
//  Application
//
//  Created by Aryansbtloe on 1/10/16.
//  Copyright © 2016 Aryansbtloe. All rights reserved.
//

import UIKit

// MARK: Extension : NSUserDefaults

public extension UserDefaults {
    class Proxy {
        fileprivate let defaults: UserDefaults
        fileprivate let key: String
        
        fileprivate init(_ defaults: UserDefaults, _ key: String) {
            self.defaults = defaults
            self.key = key
        }
        
        // MARK: Getters
        
        open var object: NSObject? {
            return defaults.object(forKey: key) as? NSObject
        }
        
        open var string: String? {
            return defaults.string(forKey: key)
        }
        
        open var array: NSArray? {
            return defaults.array(forKey: key) as NSArray?
        }
        
        open var dictionary: NSDictionary? {
            return defaults.dictionary(forKey: key) as NSDictionary?
        }
        
        open var data: NSData? {
            return defaults.data(forKey: key) as NSData?
        }
        
        open var date: NSDate? {
            return object as? NSDate
        }
        
        open var number: NSNumber? {
            return object as? NSNumber
        }
        
        open var int: Int? {
            return number?.intValue
        }
        
        open var double: Double? {
            return number?.doubleValue
        }
        
        open var bool: Bool? {
            return number?.boolValue
        }
    }
    
    /// Returns getter proxy for `key`
    
    public subscript(key: String) -> Proxy {
        return Proxy(self, key)
    }
    
    /// Sets value for `key`
    
    public subscript(key: String) -> Any? {
        get {
            return self.object(forKey: key)
        }
        set {
            if let v = newValue as? Int {
                set(v, forKey: key)
            } else if let v = newValue as? Double {
                set(v, forKey: key)
            } else if let v = newValue as? Bool {
                set(v, forKey: key)
            } else if let v = newValue as? NSObject {
                set(v, forKey: key)
            } else if newValue == nil {
                removeObject(forKey: key)
            } else {
                assertionFailure("Invalid value type")
            }
        }
    }
    
    /// Returns `true` if `key` exists
    
    public func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    /// Removes value for `key`
    
    public func remove(_ key: String) {
        removeObject(forKey: key)
    }
}

infix operator ?= {
associativity right
precedence 90
}

/// If key doesn't exist, sets its value to `expr`
/// Note: This isn't the same as `Defaults.registerDefaults`. This method saves the new value to disk, whereas `registerDefaults` only modifies the defaults in memory.
/// Note: If key already exists, the expression after ?= isn't evaluated

public func ?= (proxy: UserDefaults.Proxy, expr: @autoclosure () -> Any) {
    if !proxy.defaults.hasKey(proxy.key) {
        proxy.defaults[proxy.key] = expr()
    }
}

/// Adds `b` to the key (and saves it as an integer)
/// If key doesn't exist or isn't a number, sets value to `b`

public func += (proxy: UserDefaults.Proxy, b: Int) {
    let a = proxy.defaults[proxy.key].int ?? 0
    proxy.defaults[proxy.key] = a + b
}

public func += (proxy: UserDefaults.Proxy, b: Double) {
    let a = proxy.defaults[proxy.key].double ?? 0
    proxy.defaults[proxy.key] = a + b
}

/// Icrements key by one (and saves it as an integer)
/// If key doesn't exist or isn't a number, sets value to 1

public postfix func ++ (proxy: UserDefaults.Proxy) {
    proxy += 1
}

/// Global shortcut for NSUserDefaults.standard

public let Defaults = UserDefaults.standard


// MARK: Extension : UIApplication

public extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            if let top = moreNavigationController.topViewController , top.view.window != nil {
                return topViewController(top)
            } else if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

// MARK: Extension : UIView

extension UIView {
    func showActivityIndicatorAtPoint(_ point:CGPoint) {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = point
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true
        DispatchQueue.main.async {
            activityIndicatorView.center = point
            activityIndicatorView.isHidden = false;
        }
    }
    func showActivityIndicatorType(_ point:CGPoint,style:UIActivityIndicatorViewStyle) {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: style)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = point
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true;
        DispatchQueue.main.async {
            activityIndicatorView.center = point
            activityIndicatorView.isHidden = false;
        }
    }
    func showActivityIndicator() {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = self.center
        activityIndicatorView.center = self.center
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true;
        DispatchQueue.main.async {
            activityIndicatorView.center = self.center
            activityIndicatorView.isHidden = false;
        }
    }
    func showActivityIndicatorWhite() {
        hideActivityIndicator()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        activityIndicatorView.startAnimating()
        activityIndicatorView.center = self.center
        activityIndicatorView.tag = 102345
        activityIndicatorView.transform = CGAffineTransform(scaleX: 0.6,y: 0.6)
        self.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = true;
        DispatchQueue.main.async {
            activityIndicatorView.center = self.center
            activityIndicatorView.isHidden = false;
        }
    }
    func hideActivityIndicator() {
        self .viewWithTag(102345)?.removeFromSuperview()
    }
    
    func makeMeRound(){
        self.layer.cornerRadius = self.bounds.size.width/2
        self.layer.borderWidth = 0
        self.layer.masksToBounds = true
    }
}

// MARK: Extension : NSDictionary

extension NSDictionary {
    func removeNullValues()->NSMutableDictionary {
        do{
            let mutableCopySelf = self.mutableCopy() as! NSMutableDictionary
            let nullSet = mutableCopySelf.keysOfEntries(options: [.concurrent]) { (key, object, stop) -> Bool in
                return isNull(object as AnyObject?)
            }
            try mutableCopySelf.removeObjects(forKeys: Array(nullSet))
            return mutableCopySelf
        }catch{
            print("removeNullValues : \(error)")
            return self.mutableCopy() as! NSMutableDictionary
        }
    }
}

// MARK: Extension : String

public extension String {
    func indexOf(_ target: String) -> Int? {
        let range = (self as NSString).range(of: target)
        guard range.toRange() != nil else {
            return nil
        }
        return range.location
    }
    func lastIndexOf(_ target: String) -> Int? {
        let range = (self as NSString).range(of: target, options: NSString.CompareOptions.backwards)
        guard range.toRange() != nil else {
            return nil
        }
        return self.length - range.location - 1
        
    }
    func trimmedString()->String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    func chopPrefix(_ count: Int = 1) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: count))
    }
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(to: self.characters.index(self.endIndex, offsetBy: -count))
    }
    
    func enhancedString()->String {
        var string = self
        let pattern = "^\\s+|\\s+$|\\s+(?=\\s)"
        string = string.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return string.capitalized
    }
    
    func firstName()->String {
        let string = self
        let components = string.components(separatedBy: " ")
        if (components as NSArray).count > 0{
            return components[0]
        }
        return string
    }
    
    func asNSURL()->URL {
        return URL(string: self.addingPercentEscapes(using: String.Encoding.utf8)!)!
    }
    
    func aURLReady()->String {
        return self.addingPercentEscapes(using: String.Encoding.utf8)!
    }
    
    mutating func separateStringWithCaps(){
        var index = 1
        let mutableString = NSMutableString(string: self)
        while(index < mutableString.length){
            if CharacterSet.uppercaseLetters.contains(UnicodeScalar(mutableString.character(at: index))!){
                mutableString.insert(" ", at: index)
                index += 1
            }
            index += 1
        }
        self = String(mutableString)
    }
    
    func dateValue()->Date{
        var date : Date?
        if isNotNull(self as AnyObject?){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = dateFormatter.date(from: self)!
        }
        return date!
    }
    
    var length: Int { return (self as NSString).length }
    func heightWithConstrainedWidth(_ width: CGFloat,maxHeight: CGFloat, font: UIFont) -> CGRect {
        let constraintRect = CGSize(width: width, height: maxHeight)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox
    }
}


// MARK: Extension : UILabel

public extension UILabel{
    func requiredHeight() -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}


// MARK: Extension : Float

extension Float {
    func toInt() -> Int? {
        if self > Float(Int.min) && self < Float(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
