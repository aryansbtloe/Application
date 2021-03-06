//
//  CommonMethods.swift
//  Application
//
//  Created by Aryansbtloe on 1/10/16.
//  Copyright (c) 2016 Aryansbtloe. All rights reserved.
//

import Foundation
import UIKit
import CWStatusBarNotification
import Toaster
import JFMinimalNotifications
import ReachabilitySwift

enum PopupMessageType{
    case success
    case information
    case error
}

public func documentsDirectory() -> String {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0]
    return documentsPath
}

public func opensEmail(_ emailId : NSString) {
    UIApplication.shared.openURL(URL(string: "mailto:\(emailId)")!)
}

public func openUrl(_ url:String){
    if let urlToOpen = URL(string: url) {
        UIApplication.shared.openURL(urlToOpen)
    }
}

public func isInternetConnectivityAvailable (_ showUserWarningMessage : Bool) -> Bool {
    var isReachable : Bool = true
    let networkStatus = Reachability(hostname:URL(string:BASE_URL)!.host!)?.currentReachabilityStatus
    isReachable = (networkStatus != Reachability.NetworkStatus.notReachable)
    if isReachable == false && showUserWarningMessage {
        showNotification(MESSAGE_TEXT___FOR_NETWORK_NOT_REACHABILITY, showOnNavigation: false, showAsError: true)
    }
    return isReachable
}

public func copyData(_ sourceDictionary:NSDictionary?,sourceKey:NSString?,destinationDictionary:NSDictionary?,destinationKey:NSString?,methodName:NSString?,asString:Bool = false) {
    if sourceDictionary != nil && sourceKey != nil && destinationDictionary != nil && destinationKey != nil && sourceDictionary!.object(forKey: sourceKey! as String) != nil {
        if asString {
            destinationDictionary?.setValue("\(sourceDictionary!.object(forKey: (sourceKey! as? String)!)!)", forKey: (destinationKey as? String)!)
        }else{
            destinationDictionary?.setValue(sourceDictionary?.object(forKey: (sourceKey! as? String)!), forKey: (destinationKey as? String)!)
        }
    }else{
        #if DEBUG
            reportMissingParameter(sourceKey!, methodName: methodName!)
        #endif
    }
}

public func copyData(_ data:AnyObject?,destinationDictionary:NSDictionary?,destinationKey:NSString?,methodName:NSString?) {
    if data != nil && destinationDictionary != nil && destinationKey != nil{
        destinationDictionary?.setValue(data!, forKey: (destinationKey as! String))
    }else{
        #if DEBUG
            reportMissingParameter(destinationKey!, methodName: methodName!)
        #endif
    }
}

public func printErrorMessage (_ error : NSError? , methodName : NSString?) -> () {
    print("\nERROR MESSAGE :--- \(error?.localizedDescription) ---IN METHOD : \(methodName)\n")
}

public func reportMissingParameter (_ missingParameter : NSString , methodName : NSString) -> () {
    print("\nMISSING PARAMETER :--- \(missingParameter) ---IN METHOD : \(methodName)\n")
}

public func showNotification (_ text : String , showOnNavigation : Bool , showAsError : Bool , duration: TimeInterval = 2) -> () {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        let notificationView = CWStatusBarNotification()
        notificationView.notificationAnimationInStyle = CWNotificationAnimationStyle.top;
        notificationView.notificationAnimationOutStyle = CWNotificationAnimationStyle.top;
        notificationView.notificationStyle = showOnNavigation ?
            CWNotificationStyle.navigationBarNotification : CWNotificationStyle.statusBarNotification;
        notificationView.notificationLabelTextColor = UIColor.white
        if showAsError{
            notificationView.notificationLabelBackgroundColor = APP_THEME_RED_COLOR
        }else{
            notificationView.notificationLabelBackgroundColor = APP_THEME_COLOR
        }
        notificationView.display(withMessage: text as String, forDuration: duration)
    }
}

public func parsedJson (_ data : Data?,methodName: NSString) -> (AnyObject?) {
    let parsedData : Any?
    do {
        parsedData =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
    } catch {
        parsedData = nil
    }
    return parsedData as (AnyObject?)
}

public func parsedJsonFrom (_ data : Data?,methodName: NSString) -> (AnyObject?) {
    let parsedData : Any?
    do {
        parsedData =  try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
    } catch {
        parsedData = nil;
    }
    if ENABLE_LOGGING_WEB_SERVICE_RESPONSE {
        #if DEBUG
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async {
                let dataAsString : NSString? = NSString(data: data!,encoding: String.Encoding.utf8.rawValue);
                if parsedData != nil {
                    print("\n\nRECEIVED DATA AFTER PARSING IS \n\n\(methodName)\n\n\(parsedData!)\n\n\n")
                }else{
                    if dataAsString != nil {
                        print("\n\nRECEIVED DATA BEFORE PARSING IS \n\n\(methodName)\n\n\(dataAsString!)\n\n\n")
                    }else{
                        print("\n\nRECEIVED DATA BEFORE PARSING IS \n\n\(methodName)\n\n\(dataAsString)\n\n\n")
                    }
                    print("\n\nRECEIVED DATA AFTER PARSING IS \n\n\(methodName)\n\n\(parsedData)\n\n\n")
                }
            }
        #endif
    }
    return parsedData as (AnyObject?)
}

var activityIndicatorView : UIView?
var AryansbtloeLogoView : UIImageView?
var titleView : UILabel?
var progressView : UIProgressView?
weak var progressForShowingOnActivityIndicator : Progress?

public func showActivityIndicator (_ text : NSString) -> () {
    func showActivityIndicatorPrivate(){
        if isNull(activityIndicatorView){
            activityIndicatorView = UIView(frame:UIScreen.main.bounds)
            activityIndicatorView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            var frame = CGRect(x: DEVICE_WIDTH/2-20, y: DEVICE_HEIGHT/2-20,width: 40,height: 40)
            
            AryansbtloeLogoView = UIImageView(image: UIImage(named: "AryansbtloeLogoWheel"))
            AryansbtloeLogoView?.contentMode = UIViewContentMode.scaleAspectFill
            AryansbtloeLogoView?.frame = frame
            
            frame = CGRect(x: DEVICE_WIDTH/2-50, y: DEVICE_HEIGHT/2+30,width: 100,height: 10)
            
            progressView = UIProgressView(frame: frame)
            progressView?.trackTintColor = UIColor.white
            progressView?.progressTintColor = APP_THEME_COLOR
            
            frame = CGRect(x: 20, y: DEVICE_HEIGHT/2+30,width: DEVICE_WIDTH-40,height: 20)
            
            titleView = UILabel(frame:frame)
            titleView?.font = UIFont.init(name: FONT_BOLD , size: 15)
            titleView?.textAlignment = NSTextAlignment.center
            titleView?.textColor = UIColor.white
            titleView?.backgroundColor = UIColor.clear
            
            activityIndicatorView!.addSubview(AryansbtloeLogoView!)
            activityIndicatorView!.addSubview(progressView!)
            activityIndicatorView!.addSubview(titleView!)
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(M_PI * 2.0)
            rotateAnimation.repeatCount = 10240
            rotateAnimation.duration = 0.8
            AryansbtloeLogoView?.layer.add(rotateAnimation, forKey: nil)
        }
        activityIndicatorView?.removeFromSuperview()
        windowObject()?.addSubview(activityIndicatorView!)
        progressView?.setProgress(0, animated: false)
        titleView?.text = text.capitalized as String
        activityIndicatorView?.isHidden = false
        updateActivityIndicator()
    }
    if Thread.isMainThread{
        showActivityIndicatorPrivate()
    }else{
        performOnMainThreadWithOptimisation({(returnedData) -> () in
            showActivityIndicatorPrivate()
            },delay:0)
    }
}

public func updateActivityIndicator () {
    if activityIndicatorView?.isHidden == false {
        activityIndicatorView?.removeFromSuperview()
        windowObject()?.addSubview(activityIndicatorView!)
        if progressForShowingOnActivityIndicator != nil {
            progressView?.setProgress(Float((progressForShowingOnActivityIndicator?.fractionCompleted)!), animated: true)
            performOnMainThreadWithOptimisation({(returnedData) -> () in
                updateActivityIndicator()
                },delay:0.2)
        }else{
            performOnMainThreadWithOptimisation({(returnedData) -> () in
                updateActivityIndicator()
                },delay:0.4)
            progressView?.setProgress((progressView?.progress)!+0.01, animated: true)
        }
    }
}

public func hideActivityIndicator () {
    func hideActivityIndicatorPrivate(){
        progressView?.setProgress(1.0, animated: false)
        activityIndicatorView?.isHidden = true
        titleView?.text = ""
    }
    if Thread.isMainThread{
        hideActivityIndicatorPrivate()
    }else{
        performOnMainThreadWithOptimisation({(returnedData) -> () in
            hideActivityIndicatorPrivate()
            },delay:0)
    }
}

public func hideActivityIndicatorAfter (_ delay:Double) {
    performOnMainThreadWithOptimisation ({ (returnedData) in
        hideActivityIndicator()
    },delay:delay)
}

func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}


func isNull(_ object:AnyObject?)->(Bool){
    if object != nil{
        if object! is NSNull {
            return true
        }else if object! is NSString {
            if object as! String == "<null>" || object as! String == "" || object as! String == "null" {
                return true
            }
        }
        return false
    }
    return true
}

func isNotNull(_ object:AnyObject?)->(Bool){
    return !isNull(object)
}

func printFonts() {
    let fontFamilyNames = UIFont.familyNames
    for familyName in fontFamilyNames {
        print("------------------------------")
        print("Font Family Name = [\(familyName)]")
        let names = UIFont.fontNames(forFamilyName: familyName )
        print("Font Names = [\(names)]")
    }
}

func setAppearanceForNavigationBarType1(_ navigationController : UINavigationController?){
    if isNotNull(navigationController){
        navigationController!.navigationBar.barTintColor = UIColor.white
    }
}

func setAppearanceForNavigationBarType2(_ navigationController : UINavigationController?){
    if isNotNull(navigationController){
        navigationController!.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController!.navigationBar.barTintColor = UIColor.white
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.view.backgroundColor = UIColor.white
        for parent in navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if(childView is UIImageView) {
                    childView.isHidden = true
                }
            }
        }
    }
}

func setAppearanceForViewController(_ viewController : UIViewController? ,layoutFirst:Bool = true,enableNoneEdge:Bool = true){
    if isNotNull(viewController){
        if layoutFirst {
            viewController!.view.layoutIfNeeded()
        }
        if enableNoneEdge {
            viewController!.edgesForExtendedLayout = UIRectEdge()
        }
    }
}

func setAppearanceForMKTextField(_ textField : MKTextField){
    textField.rippleLocation = .left
    textField.floatingPlaceholderEnabled = true
    textField.layer.borderColor = UIColor.clear.cgColor
    textField.rippleLayerColor = UIColor.clear
    textField.floatingLabelTextColor = APP_THEME_COLOR
    textField.bottomBorderColor = UIColor.gray
}

func setAppearanceForMKTextField2(_ textField : MKTextField){
    textField.rippleLocation = .left
    textField.floatingPlaceholderEnabled = false
    textField.layer.borderColor = UIColor.clear.cgColor
    textField.rippleLayerColor = UIColor.clear
    textField.floatingLabelTextColor = APP_THEME_COLOR
    textField.bottomBorderColor = UIColor.gray
}

func setBorder(_ view:UIView ,color:UIColor, width:CGFloat, cornerRadius:CGFloat,masksToBounds:Bool = true){
    view.superview?.layoutIfNeeded()
    view.layoutIfNeeded()
    view.layer.cornerRadius = cornerRadius
    view.layer.borderColor = color.cgColor
    view.layer.borderWidth = width
    view.layer.masksToBounds = masksToBounds
}

func addBottomBorder(_ view:UIView ,color:UIColor, height:CGFloat){
    view.superview?.layoutIfNeeded()
    view.layoutIfNeeded()
    view.viewWithTag(1024)?.removeFromSuperview()
    let border = UIView()
    border.tag = 1024
    border.frame = CGRect(x: CGFloat(0), y: view.frame.size.height - height, width: view.frame.size.width, height: height)
    border.backgroundColor = color
    view.addSubview(border)
}

func setAppearanceForTableView(_ tableView : UITableView?){
    tableView!.separatorInset = UIEdgeInsets.zero
    tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
    tableView!.backgroundColor = UIColor.clear
}

func registerNib(_ nibName:NSString,tableView:UITableView?){
    tableView?.register(UINib(nibName: nibName as String, bundle: nil), forCellReuseIdentifier: nibName as String)
}

func registerNib(_ nibName:NSString,collectionView:UICollectionView?){
    collectionView?.register(UINib(nibName: nibName as String, bundle: nil), forCellWithReuseIdentifier: nibName as String)
}

func setupNavigationBarTitleType1(_ title:NSString?,viewController:UIViewController?){
    var fontSize = 18 as CGFloat
    if title!.length > 17 {
        fontSize = 16
    }
    viewController!.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,NSFontAttributeName:UIFont.init(name: FONT_REGULAR, size: fontSize)!]
    viewController?.title = title as? String
}

func setupNavigationBarTitleType2(_ title:NSString?,viewController:UIViewController?){
    var fontSize = 18 as CGFloat
    if title!.length > 17 {
        fontSize = 16
    }
    viewController!.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: APP_THEME_COLOR,NSFontAttributeName:UIFont.init(name: FONT_REGULAR, size: fontSize)!]
    viewController?.title = title as? String
}


func setupNavigationBarBackground(_ imageName:NSString?,navigationController:UINavigationController?){
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: imageName as! String), for: UIBarMetrics.default)
    navigationController?.setNavigationBarHidden(false,animated:false)
}

let buttonWidth = 53.0 as CGFloat

func addNavigationBarButton(_ viewController:UIViewController?,image:UIImage?,title:NSString?,isLeft:Bool,observer:UIViewController?){
    let button: UIButton = UIButton()
    button.setImage(image, for: UIControlState())
    button.setTitle(title as? String, for: UIControlState())
    button.setTitleColor(APP_THEME_COLOR, for: UIControlState())
    button.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
    button.titleLabel?.font = UIFont.init(name: FONT_BOLD, size: 14)
    button.frame = CGRect(x: 0, y: 0, width: Int(buttonWidth), height: 31)
    if isLeft{
        button.addTarget(observer, action: Selector("onClickOfLeftBarButton:"), for: UIControlEvents.touchUpInside)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        viewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }else{
        button.addTarget(observer, action: Selector("onClickOfRightBarButton:"), for: UIControlEvents.touchUpInside)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        viewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    viewController!.navigationController?.setNavigationBarHidden(false,animated:false)
}


func addNavigationBarButton(_ viewController:UIViewController?,image:UIImage?,title:NSString?,isLeft:Bool){
    let button: UIButton = UIButton()
    button.setImage(image, for: UIControlState())
    button.setTitle(title as? String, for: UIControlState())
    button.setTitleColor(APP_THEME_COLOR, for: UIControlState())
    button.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
    button.titleLabel?.font = UIFont.init(name: FONT_BOLD, size: 14)
    button.frame = CGRect(x: 0, y: 0, width: Int(buttonWidth), height: 31)
    if isLeft{
        button.addTarget(viewController, action: Selector("onClickOfLeftBarButton:"), for: UIControlEvents.touchUpInside)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        viewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }else{
        button.addTarget(viewController, action: Selector("onClickOfRightBarButton:"), for: UIControlEvents.touchUpInside)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        viewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    viewController!.navigationController?.setNavigationBarHidden(false,animated:false)
}

func addNavigationBarButton(_ viewController:UIViewController?,title:NSString?,titleColor:UIColor, fontSize:CGFloat,isLeft:Bool){
    let button: UIButton = UIButton()
    button.setTitle(title as? String, for: UIControlState())
    button.setTitleColor(titleColor, for: UIControlState())
    button.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
    button.titleLabel?.font = UIFont.init(name: FONT_BOLD, size: fontSize)
    button.frame = CGRect(x: 0, y: 0, width: Int(buttonWidth), height: 31)
    if isLeft{
        button.addTarget(viewController, action: Selector("onClickOfLeftBarButton:"), for: UIControlEvents.touchUpInside)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        viewController!.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }else{
        button.addTarget(viewController, action: Selector("onClickOfRightBarButton:"), for: UIControlEvents.touchUpInside)
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        viewController!.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    viewController!.navigationController?.setNavigationBarHidden(false,animated:false)
}

public func showToast(_ message : String){
    Toast(text:message).show()
}

public func validateNotContaningPhoneNumbers(_ anyobject : AnyObject? , identifier : NSString?)->Bool{
    let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
    let detector = try? NSDataDetector(types: types.rawValue)
    var detected = false
    detector?.enumerateMatches(in: (anyobject as? String)!, options: [], range: NSMakeRange(0, (anyobject as! NSString).length)) { (result, flags, _) in
        detected = true
    }
    if detected {
        showToast("Please remove phone numbers from \(identifier!)")
        return false
    }
    return true
}

public func validateNotContaningEmailIds(_ anyobject : AnyObject? , identifier : NSString?)->Bool{
    let range = (anyobject as? String)!.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]+", options:.regularExpression)
    if range != nil {
        showToast("Please remove email ids from \(identifier!)")
        return false
    }
    return true
}

public func validateIfNull(_ anyobject : AnyObject? , identifier : NSString?)-> Bool
{
    if isNull(anyobject) {
        showToast("Please enter \(identifier!)")
        return false
    }
    return true
}

public func generateUserNameFromName(_ name : NSString?)-> NSString {
    let userName = NSMutableString()
    let words = name?.components(separatedBy: " ")
    for word in words! {
        userName.appendFormat("%@.", word.lowercased())
    }
    if userName.length > 0 {
        return userName.substring(to: userName.length-1) as NSString
    }
    return userName
}

public func validateName(_ name : NSString? , identifier : NSString?)-> Bool
{
    if name == nil || name!.length == 0 || (name!.trimmingCharacters(in: CharacterSet.whitespaces) as NSString ).length == 0 {
        showToast("Please enter \(identifier!)")
        return false
    }
    let nameRegex = "[a-zA-Z0-9 .]+$"
    let nameTest : NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
    if nameTest.evaluate(with: name) {
        return true
    }else {
        showToast("Please enter valid \(identifier!)")
        return false
    }
}

public func validateEmail(_ email : NSString? , identifier : NSString?)-> Bool
{
    if email == nil || email!.length == 0 {
        showToast("Please enter \(identifier!)")
        return false
    }
    let emailRegex = "^[_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,30})$"
    let emailTest : NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    if emailTest.evaluate(with: email!.lowercased) {
        return true
    }else {
        showToast("Please enter valid \(identifier!)")
        return false
    }
}

public func validateSpecificEmail(_ email : NSString? , identifier : NSString?)-> Bool
{
    if email == nil || email!.length == 0 {
        showToast("Please enter \(identifier!)")
        return false
    }
    let emailRegex = "^[_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+(\\.[a-z0-9-]+)*(\\.[a-z]{2,30})$"
    let emailTest : NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    if emailTest.evaluate(with: email) {
        if email!.lowercased.contains("@gmail") ||
            email!.lowercased.contains("@google") ||
            email!.lowercased.contains("@outlook") ||
            email!.lowercased.contains("@yahoo") ||
            email!.lowercased.contains("@hotmail")
        {
            showToast("Please enter \(identifier!)")
            return false
        }
        return true
    }else {
        showToast("Please enter valid \(identifier!)")
        return false
    }
}

public func validatePassword(_ password : NSString? , identifier : NSString?)-> Bool
{
    if password == nil || password!.length == 0 {
        showToast("Please enter \(identifier!)")
        return false
    }
    if password!.length < 3 {
        showToast("\(identifier!) is too short , it must have atleast 3 characters.")
        return false
    }
    let enableStrictValidation = false
    if enableStrictValidation {
        if password!.contains(" ") {
            showToast("\(identifier!) cannot have spaces.")
            return false
        }
        
        let passwordRegex1 = ".*[a-zA-Z]+.*"
        let passwordTest1 : NSPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex1)
        if passwordTest1.evaluate(with: password) {
        }else {
            showToast("\(identifier!) must contain at least one letter.")
            return false
        }
        
        let passwordRegex2 = ".*[0-9]+.*"
        let passwordTest2 : NSPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex2)
        if passwordTest2.evaluate(with: password) {
        }else {
            showToast("\(identifier!) must contain at least one number.")
            return false
        }
        return true
    }
    return true
}

public func validatePhone(_ phone : NSString? , identifier : NSString? , showError:Bool = true)-> Bool
{
    if phone == nil || phone!.length == 0 {
        if showError {
            showToast("Please enter \(identifier!)")
        }
        return false
    }
    if phone!.length != 10 {
        if showError {
            showToast("Please enter valid 10 digit \(identifier!)")
        }
        return false
    }
    let phoneRegex = "[0-9]+$"
    let phoneTest : NSPredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    if phoneTest.evaluate(with: phone) {
        return true
    }else {
        if showError {
            showToast("Please enter valid \(identifier!)")
        }
        return false
    }
}

public func validateNumber(_ number : NSString? , identifier : NSString?)-> Bool
{
    if number == nil || number!.length == 0 {
        showToast("Please enter \(identifier!)")
        return false
    }
    let regex = "[0-9]+."
    let test : NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
    if test.evaluate(with: number) {
        return true
    }else {
        showToast("Please enter valid \(identifier!)")
        return false
    }
}

public func encodeStringToBase64(_ normal: Data)->NSString
{
    let base64Encoded = normal.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    return base64Encoded as NSString
}

public func addBorderToButton(_ Color :UIColor , button:UIButton , borderWidth :CGFloat){
    button.layer.borderColor = Color.cgColor
    button.layer.borderWidth = borderWidth
}

public func resignKeyboard(){
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
}

public func storyBoardObject()->(UIStoryboard){
    return UIStoryboard(name: "Main", bundle: nil)
}

func viewController(_ identifier:NSString)->(UIViewController){
    return storyBoardObject().instantiateViewController(withIdentifier: identifier as String)
}

func dateformatterDateTime(_ date: Date) -> NSString{
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy "
    return dateFormatter.string(from: date) as NSString
}

func dateformatterDateTimeServer(_ date: Date) -> NSString{
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date) as NSString
}

func windowObject ()->UIWindow?{
    return UIApplication.shared.keyWindow
}

func appDelegate ()->AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate
}

func date(_ string:NSString)->Date {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    var date: Date = dateFormatter.date(from: string as String) as Date!
    let currentTimeZone:Foundation.TimeZone  = Foundation.TimeZone.autoupdatingCurrent;
    let utcTimeZone:Foundation.TimeZone  = Foundation.TimeZone(abbreviation: "UTC")!;
    let currentGMTOffset:NSInteger  = currentTimeZone.secondsFromGMT(for: date)
    let gmtOffset:NSInteger  = utcTimeZone.secondsFromGMT(for: date)
    let gmtInterval:TimeInterval = Double(currentGMTOffset - gmtOffset);
    date = Date(timeInterval: gmtInterval, since: date)
    return date
}


func dateYYYYMMDD(_ string:NSString)->Date {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    var date: Date = dateFormatter.date(from: string as String) as Date!
    let currentTimeZone:Foundation.TimeZone  = Foundation.TimeZone.autoupdatingCurrent;
    let utcTimeZone:Foundation.TimeZone  = Foundation.TimeZone(abbreviation: "UTC")!;
    let currentGMTOffset:NSInteger  = currentTimeZone.secondsFromGMT(for: date)
    let gmtOffset:NSInteger  = utcTimeZone.secondsFromGMT(for: date)
    let gmtInterval:TimeInterval = Double(currentGMTOffset - gmtOffset)
    date = Date(timeInterval: gmtInterval, since: date)
    return dateFormatter.date(from: string as String) as Date!
}


func getHeightFor(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    label.sizeToFit()
    return label.frame.height
}

func getHeightFor(_ text:String?, font:UIFont? , width:CGFloat, minimumHeight:CGFloat, maximumHeight:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    label.sizeToFit()
    if label.frame.height < minimumHeight{
        return minimumHeight
    }
    else if label.frame.height > maximumHeight{
        return maximumHeight
    }else{
        return label.frame.height
    }
}

func randomString (_ len : Int) -> NSString {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    for i in 0 ..< len {
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    return randomString
}

func truncateAndAppendString(_ content:String, limit: Int, appendString:String)->String{
    var content = content
    let range = content.startIndex..<content.characters.index(content.startIndex, offsetBy: limit)
    content = content[range]
    content = "\(content) \(appendString)"
    return content
}

func showPendingFunctionallityMessage(){
    showNotification(MESSAGE_TEXT___FOR_FUNCTIONALLITY_PENDING_MESSAGE, showOnNavigation: false, showAsError: false)
}

func showAlert(_ title : String,message:String,onlyForDebugging:Bool=false){
    var showMessage = true
    if onlyForDebugging {
        #if DEBUG
        #else
            showMessage = false
        #endif
    }
    if showMessage {
        showPopupAlertMessage(title, message: message)
    }
}

func showPopupAlertMessage(_ title : String,message:String){
    windowObject()?.rootViewController?.present(UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert), animated: true, completion: nil)
}

func showNotification(message:String,onlyForDebugging:Bool=false){
    var showMessage = true
    if onlyForDebugging{
        #if DEBUG
        #else
            showMessage = false
        #endif
    }
    if showMessage {
        showNotification(message, showOnNavigation: true, showAsError: false)
    }
}

func convertStringIntoDate(_ dateString: String!, with formatString: String) -> Date{
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = formatString
    var date: Date = dateFormatter.date(from: dateString) as Date!
    let currentTimeZone:Foundation.TimeZone  = Foundation.TimeZone.autoupdatingCurrent;
    let utcTimeZone:Foundation.TimeZone  = Foundation.TimeZone(abbreviation: "UTC")!;
    let currentGMTOffset:NSInteger  = currentTimeZone.secondsFromGMT(for: date)
    let gmtOffset:NSInteger  = utcTimeZone.secondsFromGMT(for: date)
    let gmtInterval:TimeInterval = Double(currentGMTOffset - gmtOffset);
    date = Date(timeInterval: gmtInterval, since: date)
    return date
}

func orientationChange(){
    let value:NSNumber = NSNumber(value: UIInterfaceOrientation.portrait.rawValue as Int)
    UIDevice.current.setValue(value, forKeyPath: "orientation")
    UIViewController.attemptRotationToDeviceOrientation()
}

func extractYoutubeID(_ youtubeURL: String) -> String{
    let regex = "(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)"
    let regexPattern = try! NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive)
    let match: NSTextCheckingResult? = regexPattern.firstMatch(in: youtubeURL, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, youtubeURL.length))
    let videoID = (youtubeURL as NSString).substring(with: match!.range).replacingOccurrences(of: "v=", with: "")
    return videoID
}

func isDocumentDownloaded(_ fileName: String) -> Bool {
    let fileMgr: FileManager = FileManager.default
    let documentsDirectory: String = NSHomeDirectory() + "/Documents/"
    let currentFile: String = documentsDirectory + fileName
    let fileExists: Bool = fileMgr.fileExists(atPath: currentFile)
    return fileExists
}

func getExistingDocumentPathOnDocumentDirectory(_ fileName: String) -> String {
    let documentsDirectory: String = NSHomeDirectory() + "//Documents/"
    let currentFile: String = documentsDirectory + fileName
    return currentFile
}

func resizeImage(_ imageObj: UIImage, sizeChange: CGSize) -> UIImage {
    let hasAlpha = false
    let scale: CGFloat = 0.0
    UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
    imageObj.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    return scaledImage!
}

func getFilesOnDevice() ->  [AnyObject]{
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentDirectory = paths[0]
    let manager = FileManager.default
    var items: NSArray = NSArray()
    if let allItems = try? manager.contentsOfDirectory(atPath: documentDirectory) {
        items = allItems as NSArray
    }
    return items as [AnyObject]
}

func cropImage(_ oldImg:UIImage,targetSize:CGSize)->UIImage{
    var oldImg = oldImg
    oldImg = fixrotation(oldImg)
    let orgImgHeight:Int = Int(oldImg.size.height);
    let orgImgWidth:Int = Int(oldImg.size.width);
    
    let inRatio:Double = Double(orgImgHeight/orgImgWidth)
    let outRatio:Double = Double(targetSize.height/targetSize.width);
    
    var x1:Int = 0;
    var y1:Int = 0;
    var x2:Int = orgImgWidth;
    var y2:Int = orgImgHeight;
    
    if(inRatio > outRatio)
    {
        let temp:Double = outRatio * Double(x2);
        let hNew:Int = Int(temp);
        let hCut:Int = y2 - hNew;
        y1 = hCut/4;
        y2 = y1 + hNew;
    }
    else
    {
        let temp:Double = Double(y2) / outRatio;
        let wNew:Int = Int(temp);
        let wCut:Int = x2 - wNew;
        x1 = wCut / 2;
        x2 = x1 + wNew;
    }
    var newImage:UIImage? = nil;
    let p1:CGPoint = CGPoint(x: CGFloat(x1), y: CGFloat(y1));
    var p2:CGPoint = CGPoint(x: CGFloat(x1), y: CGFloat(y2));
    
    let newHigth:Double =  getDistance(p1,two: p2)
    p2 = CGPoint(x: CGFloat(x2),y: CGFloat(y1));
    let newWidth:Double = getDistance(p1, two: p2)
    
    let cropRect:CGRect = CGRect(x: CGFloat(x1), y: CGFloat(y1), width: CGFloat(newWidth), height: CGFloat(newHigth))
    let imageRef:CGImage = oldImg.cgImage!.cropping(to: cropRect)!;
    newImage = UIImage(cgImage: imageRef)
    return newImage!;
}

func getDistance(_ one:CGPoint,two:CGPoint)->Double{
    let value1:Double = (Double(two.x) - Double(one.x)) * (Double(two.x) - Double(one.x))
    let value2:Double = (Double(two.y) - Double(one.y)) * (Double(two.y) - Double(one.y))
    return sqrt(value1 + value2);
}

func deviceTokenUsingData(_ tokenData:Data)-> String{
    let tokenChars = (tokenData as NSData).bytes.bindMemory(to: CChar.self, capacity: tokenData.count)
    var tokenString = ""
    for i in 0 ..< tokenData.count {
        tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    return tokenString
}

func deviceToken()->String?{
    return UserDefaults.standard.object(forKey: "deviceToken") as? String
}

func getDeviceOperationSystem()->String?{
    return DEVICE_TYPE
}

func setDeviceToken(_ token:String?){
    UserDefaults.standard.set(token, forKey: "deviceToken")
}


func fixrotation(_ image:UIImage)->UIImage{
    if (image.imageOrientation == UIImageOrientation.up){
        return image;
    }
    var transform:CGAffineTransform = CGAffineTransform.identity;
    switch image.imageOrientation{
    case UIImageOrientation.down:
        transform = transform.translatedBy(x: image.size.width, y: image.size.height);
        transform = transform.rotated(by: CGFloat(M_PI))
        break;
    case UIImageOrientation.downMirrored:
        transform = transform.translatedBy(x: image.size.width, y: image.size.height);
        transform = transform.rotated(by: CGFloat(M_PI))
        break;
    case UIImageOrientation.left:
        transform = transform.translatedBy(x: image.size.width, y: 0);
        transform = transform.rotated(by: CGFloat(M_PI_2));
        break;
    case UIImageOrientation.leftMirrored:
        transform = transform.translatedBy(x: image.size.width, y: 0);
        transform = transform.rotated(by: CGFloat(M_PI_2));
        break;
    case UIImageOrientation.right:
        transform = transform.translatedBy(x: 0, y: image.size.height);
        transform = transform.rotated(by: CGFloat(-M_PI_2));
        break;
    case UIImageOrientation.rightMirrored:
        transform = transform.translatedBy(x: 0, y: image.size.height);
        transform = transform.rotated(by: CGFloat(-M_PI_2));
        break;
    default:
        break;
    }
    
    switch (image.imageOrientation){
    case UIImageOrientation.upMirrored:
        transform = transform.translatedBy(x: image.size.width, y: 0);
        transform = transform.scaledBy(x: -1, y: 1);
        break;
    case UIImageOrientation.downMirrored:
        transform = transform.translatedBy(x: image.size.width, y: 0);
        transform = transform.scaledBy(x: -1, y: 1);
        break;
        
    case UIImageOrientation.leftMirrored:
        transform = transform.translatedBy(x: image.size.height, y: 0);
        transform = transform.scaledBy(x: -1, y: 1);
        break;
    case UIImageOrientation.rightMirrored:
        transform = transform.translatedBy(x: image.size.height, y: 0);
        transform = transform.scaledBy(x: -1, y: 1);
        break;
    default:
        break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    let  ctx:CGContext = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!
    ctx.concatenate(transform);
    switch (image.imageOrientation){
    case UIImageOrientation.left:
        ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.height,height: image.size.width));
    case UIImageOrientation.leftMirrored:
        ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.height,height: image.size.width));
    case UIImageOrientation.right:
        ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.height,height: image.size.width));
    case UIImageOrientation.rightMirrored:
        ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.height,height: image.size.width));
        break;
        
    default:
        ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.width,height: image.size.height));
        break;
    }
    let cgimg:CGImage = ctx.makeImage()!;
    let img:UIImage = UIImage(cgImage: cgimg)
    return img;
}

func performAnimatedClickEffectType1(_ view:UIView){
    UIView.animate(withDuration: 0.08, animations: { () -> Void in
        view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }, completion: { (status) -> Void in
        UIView.animate(withDuration: 0.08, animations: { () -> Void in
            view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: { (status) -> Void in
            UIView.animate(withDuration: 0.08, animations: { () -> Void in
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (status) -> Void in
            }) 
        }) 
    }) 
}

func performAnimationEffectType2(_ view:UIView,minS:CGFloat,maS:CGFloat,dur:Double){
    UIView.animate(withDuration: dur, animations: { () -> Void in
        view.transform = CGAffineTransform(scaleX: minS, y: minS)
    }, completion: { (status) -> Void in
        UIView.animate(withDuration: dur, animations: { () -> Void in
            view.transform = CGAffineTransform(scaleX: maS, y: maS)
        }, completion: { (status) -> Void in
            UIView.animate(withDuration: dur, animations: { () -> Void in
                view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (status) -> Void in
            }) 
        }) 
    }) 
}

func timePart(_ dateAsString:NSString)->String{
    return dateAsString.substring(with: NSRange(location: 11,length: 5))
}

func datePart(_ dateAsString:NSString)->String{
    return dateAsString.substring(with: NSRange(location: 0,length: 10))
}

func dictionary(_ from:AnyObject?)->NSDictionary{
    if from is NSArray {
        let fromArray = from as! NSArray
        let result = NSMutableDictionary()
        for content in fromArray {
            result.setObject("1", forKey:(content as! String as NSCopying))
        }
        return result
    }
    if from is NSDictionary {
        return from as! NSDictionary
    }
    return NSDictionary()
}

func generateRandomDouble(_ sN:Double,bN:Double)->Double {
    let diff = bN - sN
    return (((Double) (Double(arc4random()).truncatingRemainder(dividingBy: (Double(RAND_MAX) + 1))) / Double(RAND_MAX)) * diff) + sN;
}

func currentTimeStamp() -> Int64{
    return Int64(Date().timeIntervalSince1970)
}

func remaningTime(_ startDate:Date ,endDate:Date)->String {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.day,.hour,.minute,.second], from: startDate, to: endDate, options: [])
    if components.day! > 0 {
        return "\(components.day)d : \(components.hour)h : \(components.minute)m : \(components.second)s"
    }else{
        if components.hour! > 0 {
            return "\(components.hour)h : \(components.minute)m : \(components.second)s"
        }else{
            return "\(components.minute)m : \(components.second)s"
        }
    }
}

func elapsedTime(_ startDate:Date)->String {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.day,.hour,.minute,.second], from: startDate, to: Date(), options: [])
    if components.day! > 0 {
        return "\(components.day)d : \(components.hour)h : \(components.minute)m : \(components.second)s"
    }else{
        if components.hour! > 0 {
            return "\(components.hour)h : \(components.minute)m : \(components.second)s"
        }else{
            return "\(components.minute)m : \(components.second)s"
        }
    }
}

func showInformationBannerOnBottom(_ vc:UIViewController,style:JFMinimalNotificationStyle,duration:TimeInterval,title:String?,message:String,titleFont:UIFont=UIFont.init(name: FONT_SEMI_BOLD, size: 16)!,subTitleFont:UIFont=UIFont.init(name: FONT_REGULAR, size: 14)!){
    DispatchQueue.main.async {
        vc.view.viewWithTag(84386)?.removeFromSuperview()
        let notification = JFMinimalNotification(style: style, title: title, subTitle: message, dismissalDelay: duration)
        notification?.setTitleFont(titleFont)
        notification?.setSubTitleFont(subTitleFont)
        notification?.tag = 84386
        vc.view.addSubview(notification!)
        notification?.show()
    }
}

func performOnMainThreadWithOptimisation(_ completion:@escaping ACFCompletionBlock,delay:Double = 1.0){
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            completion(true as AnyObject?)
        }
    })
}

func performOnBackgroundThread(_ completion:@escaping ACFCompletionBlock){
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
        completion(true as AnyObject?)
    })
}

func setBottomGap(_ height:CGFloat,tableView:UITableView){
    tableView.layoutIfNeeded()
    let tableFooterView = UIView(frame: CGRect(x: 0,y: 0, width: tableView.bounds.size.width, height: height))
    tableView.tableHeaderView = tableFooterView
}

func isInForeground()->Bool{
    return UIApplication.shared.applicationState == .active
}

