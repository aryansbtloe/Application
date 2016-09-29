//
//  WebServices.swift
//  Application
//
//  Created by Aryansbtloe on 1/10/16.
//  Copyright © 2016 Aryansbtloe. All rights reserved.
//

//MARK: - AppCommonFunctions : This singleton class implements some app specific functions which are frequently needed in application.

import Foundation
import UIKit
import Toaster
import Fabric
import Crashlytics
import CTFeedback
import IQKeyboardManagerSwift

//MARK: - Completion block
typealias ACFCompletionBlock = (_ returnedData :AnyObject?) ->()
typealias ACFModificationBlock = (_ viewControllerObject :AnyObject?) ->()
typealias ACFPreviewActionsDelegate = (_ viewControllerObject :AnyObject?) ->AnyObject

class AppCommonFunctions: NSObject {
    var completionBlock: ACFCompletionBlock?
    var navigationController: UINavigationController?
    var tabBarController : UITabBarController?
    var showPushNotificationsOnPopup = false
    var launchOptions:[AnyHashable: Any]?
    
    static let sharedInstance : AppCommonFunctions = {
        let instance = AppCommonFunctions()
        return instance
    }()
    
    fileprivate override init() {
        
    }
    
    func prepareForStartUp(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?){
        self.launchOptions = launchOptions
        setupDatabase()
        
        performOnMainThreadWithOptimisation({[weak self] (returnedData) -> () in guard let `self` = self else { return }
            self.setupIQKeyboardManagerEnable()
            })
        setupOtherSettings()
        showRequiredScreen()
        performOnMainThreadWithOptimisation({[weak self] (returnedData) -> () in guard let `self` = self else { return }
            self.setupCrashlytics()
            })
        performOnMainThreadWithOptimisation({[weak self] (returnedData) -> () in guard let `self` = self else { return }
            self.performNecessaryUpdateToServer()
            },delay:18)
        performOnMainThreadWithOptimisation({[weak self] (returnedData) -> () in guard let `self` = self else { return }
            self.performNecessaryUpdateFromTheServer()
            },delay:48)
    }
    
    func setupDatabase() {
        DatabaseManager.sharedInstance.setupCoreDataDatabase()
    }
    
    func performNecessaryUpdateToServer(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(AppCommonFunctions.performNecessaryUpdateToServerPrivate), object: nil)
        self.perform(#selector(AppCommonFunctions.performNecessaryUpdateToServerPrivate), with: nil, afterDelay: 10)
    }
    
    func performNecessaryUpdateFromTheServer(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(AppCommonFunctions.performNecessaryUpdateFromTheServerPrivate), object: nil)
        self.perform(#selector(AppCommonFunctions.performNecessaryUpdateFromTheServerPrivate), with: nil, afterDelay: 10)
    }
    
    func performNecessaryUpdateToServerPrivate(){
        if(isInternetConnectivityAvailable(true)==false){return}
    }
    
    
    func performNecessaryUpdateFromTheServerPrivate(){
        if(isInternetConnectivityAvailable(true)==false){return}
    }
    
    func setupKeyboardNextButtonHandler(){
        NotificationCenter.default.addObserver(self, selector: Selector(("viewLoadedNotification")), name: NSNotification.Name(rawValue: "viewLoaded"), object: nil)
    }
    
    func setupIQKeyboardManagerEnable(){
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().shouldPlayInputClicks = true
    }
    
    func setupIQKeyboardManagerDisable(){
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = false
        IQKeyboardManager.sharedManager().shouldPlayInputClicks = false
    }
    
    
    func setupOtherSettings(){
        disableAutoCorrectionsAndTextSuggestionGlobally()
        UITabBar.appearance().selectedImageTintColor = APP_THEME_COLOR
        navigationController = APPDELEGATE.window?.rootViewController as? UINavigationController
        navigationController?.view.backgroundColor = UIColor.white
        windowObject()?.backgroundColor = UIColor.white
    }
    
    func showRequiredScreen(){
        
    }
    
    func showHomeScreen(){
    }
    
    func setupCrashlytics(){
        Fabric.with([Crashlytics.self])
        updateUserInfoOnCrashlytics()
    }
    
    func updateUserInfoOnCrashlytics(){
        Crashlytics.sharedInstance().setUserName("")
        Crashlytics.sharedInstance().setUserIdentifier("")
    }
    
    func handleNotification(_ notification:NSDictionary?){
        if isNotNull(notification) {
            if let _ = notification as NSDictionary? {
                print("\n\nORIGINAL NOTIFICATION RECEIVED \n\(notification)\n\n")
                if showPushNotificationsOnPopup{
                    showAlert("PUSH NOTIFICATION", message:notification!.description)
                }
            }
        }
    }
    
    func handleNotificationWhenTappedToView(_ notification:NSDictionary?){
    }
    
    func getViewController(_ identifier:NSString?)->(UIViewController){
        return storyBoardObject().instantiateViewController(withIdentifier: identifier as! String)
    }
    
    func presentVC(_ identifier:NSString? , viewController:UIViewController? , animated:Bool , modifyObject:ACFModificationBlock?){
        let vc = storyBoardObject().instantiateViewController(withIdentifier: identifier as! String)
        if let _ = modifyObject{
            modifyObject!(vc)
        }
        viewController!.present(UINavigationController(rootViewController: vc), animated: animated, completion: nil)
    }
    
    func pushVC(_ identifier:NSString?,navigationController:UINavigationController?,isRootViewController:Bool,animated:Bool,modifyObject:ACFModificationBlock?){
        let vc = storyBoardObject().instantiateViewController(withIdentifier: identifier as! String)
        if let _ = modifyObject{
            modifyObject!(vc)
        }
        if isRootViewController{
            navigationController!.setViewControllers([vc], animated: animated)
        }else{
            navigationController!.pushViewController(vc, animated: animated)
        }
    }
    
    func updateAppearanceOfTextFieldType1(_ textField:MKTextField?){
        if textField!.isFirstResponder {
            textField!.tintColor = APP_THEME_COLOR
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = APP_THEME_COLOR
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = true
            textField!.attributedPlaceholder = NSAttributedString(string:textField!.placeholder!,
                                                                  attributes:[NSForegroundColorAttributeName: APP_THEME_COLOR])
        }else {
            textField!.tintColor = UIColor.lightGray
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = UIColor.lightGray
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = true
            textField!.attributedPlaceholder = NSAttributedString(string:textField!.placeholder!,
                                                                  attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        }
    }
    
    func updateAppearanceOfTextFieldType2(_ textField:MKTextField?){
        if textField!.isFirstResponder {
            textField!.tintColor = APP_THEME_COLOR
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = APP_THEME_COLOR
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = false
        }else {
            textField!.tintColor = UIColor.lightGray
            textField!.bottomBorderEnabled = true
            textField!.bottomBorderColor = UIColor.lightGray
            textField!.placeholder = textField!.placeholder
            textField!.floatingPlaceholderEnabled = false
        }
    }
    
    func disableAutoCorrectionsAndTextSuggestionGlobally () {
        NotificationCenter.default.addObserver(self, selector: #selector(AppCommonFunctions.notificationWhenTextViewDidBeginEditing(_:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppCommonFunctions.notificationWhenTextFieldDidBeginEditing(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
    }
    
    func notificationWhenTextFieldDidBeginEditing (_ notification:Notification) {
        let textField = notification.object as? UITextField
        textField?.autocorrectionType = UITextAutocorrectionType.no
    }
    
    func notificationWhenTextViewDidBeginEditing (_ notification:Notification) {
        let textView = notification.object as? UITextView
        textView?.autocorrectionType = UITextAutocorrectionType.no
    }
}
