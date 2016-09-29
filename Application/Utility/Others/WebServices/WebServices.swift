//
//  WebServices.swift
//  Application
//
//  Created by Aryansbtloe on 1/10/16.
//  Copyright © 2016 Aryansbtloe. All rights reserved.
//

//MARK: - WebServices : This class handles communication of application with its Server.

import Foundation
import AFNetworking

//LIVE
var BASE_URL = "https://api.Aryansbtloe.com/mob/"

//MARK: - Url's
struct ServerSupportURLS {
    static let SIGNUP = "onboard/signup/"
}

//MARK: - WebServiceConstants
struct WebServiceConstants {
    static let RESPONSE_CODE_KEY = "status"
    static let RESPONSE_CODE_SUCCESS_VALUE = "Optional(1)"
    static let RESPONSE_CODE_FAILURE_VALUE = "Optional(0)"
    static let RESPONSE_MESSAGE_KEY = "message"
}

//MARK: - Response Error Handling Options
enum ResponseErrorOption {
    case dontShowErrorResponseMessage
    case showErrorResponseWithUsingNotification
}

//MARK: - Completion block
typealias WSCompletionBlock = (_ responseData :NSDictionary?) ->()
typealias WSCompletionBlockForFile = (_ responseData :NSData?) ->()

//MARK: - Custom methods
extension WebServices {
    //MARK: - Authentication
    
    func signup(_ information: NSDictionary ,completionBlock: @escaping WSCompletionBlock) -> () {
        let parameters = NSMutableDictionary()
        copyData(information, sourceKey: "home", destinationDictionary: parameters, destinationKey: "home", methodName:#function)
        addCommonInformation(parameters)
        performPostRequest(parameters, urlString: String(BASE_URL+ServerSupportURLS.SIGNUP) as NSString, completionBlock: completionBlock,methodName:#function)
    }
}

//MARK: - Private
class WebServices: NSObject {
    
    var completionBlock: WSCompletionBlock?
    var responseErrorOption: ResponseErrorOption?
    var progressIndicatorText: String?
    var returnFailureResponseAlso = false
    var returnFailureUnParsedDataIfParsingFails = false
    var showSuccessResponseMessage = false
    
    /// Check for cache and return from cache if possible.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: bool (wether cache was used or not)
    func loadFromCacheIfPossible(_ body:NSDictionary? , urlString:NSString? ,completionBlock: WSCompletionBlock , maxAgeInSeconds:Float)->(Bool){
        return false
    }
    
    func updateSecurityPolicy(_ manager:AFHTTPSessionManager){
        let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.none)
        securityPolicy.validatesDomainName = false
        securityPolicy.allowInvalidCertificates = true
        manager.securityPolicy = securityPolicy
    }
    
    /// Perform  GET Request.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: parsed server response via completionBlock
    func performGetRequest(_ body:NSDictionary? , urlString:AnyObject? ,completionBlock: @escaping WSCompletionBlock,methodName:String)->(){
        DispatchQueue.global().async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            let url = URL(string: urlString as! String)
            
            print("\n\n\n                  HITTING URL\n\n \(url!.absoluteString)\n\n\n                  WITH GET REQUEST\n\n\(body)\n\n" )
            if self.progressIndicatorText != nil{
                showActivityIndicator(self.progressIndicatorText! as NSString);
            }
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer.timeoutInterval = REQUEST_TIME_OUT
            self.updateSecurityPolicy(manager)
            manager.get(urlString as! String, parameters: body, progress: { (progress) in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
                }, success: { (urlSessionDataTask, responseObject) in
                    self.verifyServerResponse(responseObject as AnyObject, error: nil, completionBlock: completionBlock,methodName: methodName as NSString?)
                }, failure: { (urlSessionDataTask, error) in
                    self.verifyServerResponse(nil, error: error as NSError, completionBlock: completionBlock,methodName: methodName as NSString?)
            })
        }
    }
    
    /// Perform Get Request For Downloading file data.
    ///
    /// - parameter url: url to download file
    /// - returns: fileData via completionBlock
    func performDownloadGetRequest(_ urlString:NSString? ,completionBlock: @escaping WSCompletionBlockForFile,methodName:String)->(){
        DispatchQueue.global().async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            if self.progressIndicatorText != nil{
                showActivityIndicator(self.progressIndicatorText! as NSString);
            }
            let url = URL(string: urlString as! String)
            print("\n\n\n                  HITTING URL TO DOWNLOAD FILE\n\n \((url!.absoluteString))\n\n\n" )
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.requestSerializer.timeoutInterval = REQUEST_TIME_OUT
            self.updateSecurityPolicy(manager)
            self.addCommonInformationInHeader(manager.requestSerializer)
            manager.get(urlString as! String, parameters: nil, progress: { (progress) -> Void in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
                }, success: { (urlSessionDataTask, responseObject) -> Void in
                    completionBlock(responseObject as! NSData?)
                    DispatchQueue.main.async {
                        if self.progressIndicatorText != nil{
                            hideActivityIndicator()
                        }
                    }
            }){(urlSessionDataTask, error) -> Void in
                self.showServerNotRespondingMessage()
                DispatchQueue.main.async {
                    if self.progressIndicatorText != nil{
                        hideActivityIndicator()
                    }
                }
            }
        }
    }

    /// Perform Json Encoded Post Request.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: parsed server response via completionBlock
    func performJsonPostRequest(_ body:NSDictionary? , urlString:NSString ,completionBlock: @escaping WSCompletionBlock,methodName:String)->(){
        DispatchQueue.global().async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            if self.progressIndicatorText != nil{
                showActivityIndicator(self.progressIndicatorText! as NSString);
            }
            let url = URL(string: urlString as String)
            print("\n\n\n                  HITTING URL\n\n \((url!.absoluteString))\n\n\n                  WITH POST JSON BODY\n\n\(body!)\n\n" )
            
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer = AFJSONRequestSerializer()
            manager.requestSerializer.timeoutInterval = REQUEST_TIME_OUT
            self.updateSecurityPolicy(manager)
            self.addCommonInformationInHeader(manager.requestSerializer)
            manager.post(urlString as String, parameters: body, progress: { (progress) in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
                }, success: { (urlSessionDataTask, responseObject) in
                    self.verifyServerResponse(responseObject as AnyObject, error: nil, completionBlock: completionBlock,methodName: methodName as NSString?)
                }, failure: { (urlSessionDataTask, error) in
                    self.verifyServerResponse(nil, error: error as NSError, completionBlock: completionBlock,methodName: methodName as NSString?)
            })
        }
    }
    /// Perform Post Request.
    ///
    /// - parameter body: parameters to set in Body of the request
    /// - returns: parsed server response via completionBlock
    func performPostRequest(_ body:NSDictionary? , urlString:NSString? ,completionBlock: @escaping WSCompletionBlock ,methodName:NSString?)->(){
        DispatchQueue.global().async {
            if isInternetConnectivityAvailable(true)==false {
                return;
            }
            if self.progressIndicatorText != nil{
                showActivityIndicator(self.progressIndicatorText! as NSString);
            }
            let url = URL(string: urlString as! String)
            print("\n\n\n                  HITTING URL\n\n \((url!.absoluteString))\n\n\n                  WITH POST BODY\n\n\(body!)\n\n" )
            let manager = AFHTTPSessionManager()
            manager.responseSerializer = AFHTTPResponseSerializer()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.requestSerializer.timeoutInterval = REQUEST_TIME_OUT
            self.updateSecurityPolicy(manager)
            self.addCommonInformationInHeader(manager.requestSerializer)
            manager.post(urlString as! String, parameters: body, progress: { (progress) in
                if self.progressIndicatorText != nil{
                    progressForShowingOnActivityIndicator = progress
                }
                }, success: { (urlSessionDataTask, responseObject) in
                    self.verifyServerResponse(responseObject as AnyObject, error: nil, completionBlock: completionBlock,methodName: methodName as NSString?)
                }, failure: { (urlSessionDataTask, error) in
                    self.verifyServerResponse(nil, error: error as NSError, completionBlock: completionBlock,methodName: methodName as NSString?)
            })
        }
    }
    
    /// Add commonly used parameters to all request.
    ///
    /// - parameter information: pass the dictionary object here that you created to hold parameters required. This function will add commonly used parameter into it.
    func addCommonInformation(_ information:NSMutableDictionary?)->(){
    }

    func addCommonInformationInHeader(_ requestSerialiser:AFHTTPRequestSerializer?)->(){
    }
    
    /// To display server not responding message via notification banner.
    func showServerNotRespondingMessage(){
        DispatchQueue.main.async {
            let showMessage = false
            if showMessage {
                showNotification(message: MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY , onlyForDebugging: false)
            }
        }
    }
    /// To check wether the server operation succeeded or not.
    /// - returns: bool
    func isSuccess(_ response:NSDictionary?)->(Bool){
        if response != nil{
            if "\(response?.object(forKey: WebServiceConstants.RESPONSE_CODE_KEY))".isEqual(WebServiceConstants.RESPONSE_CODE_SUCCESS_VALUE){
                return true
            }
        }
        return false
    }
    /// To check wether the server operation failed or not.
    /// - returns: bool
    func isFailure(_ response:NSDictionary?)->(Bool){
        if response != nil{
            if "\(response?.object(forKey: WebServiceConstants.RESPONSE_CODE_KEY))".isEqual(WebServiceConstants.RESPONSE_CODE_FAILURE_VALUE){
                return true
            }
        }
        return false
    }
    /// To verify the server response received and perform action on basis of that.
    /// - parameter response: data received from server in the form of NSData
    func verifyServerResponse(_ response:AnyObject?,error:NSError?,completionBlock: WSCompletionBlock?,methodName:NSString?)->(){
        if responseErrorOption == nil {
            responseErrorOption = ResponseErrorOption.showErrorResponseWithUsingNotification
        }
        if progressIndicatorText != nil{
            hideActivityIndicator();
        }
        if error != nil {
            if responseErrorOption != ResponseErrorOption.dontShowErrorResponseMessage {
                showServerNotRespondingMessage()
            }
            printErrorMessage(error, methodName: #function)
            DispatchQueue.main.async(execute: {
                completionBlock!(nil)
            })
        }
        else if response != nil {
            DispatchQueue.global().async {
                let responseDictionary = parsedJsonFrom(response as? Data,methodName: methodName!)
                if (isNotNull(responseDictionary) && responseDictionary is NSDictionary) {
                    if self.isSuccess(responseDictionary as! NSDictionary?){
                        if self.showSuccessResponseMessage {
                            var successMessage : String?
                            if (responseDictionary?.object(forKey: WebServiceConstants.RESPONSE_MESSAGE_KEY) != nil) {
                                if (responseDictionary?.object(forKey: WebServiceConstants.RESPONSE_MESSAGE_KEY) is NSDictionary) {
                                    successMessage = responseDictionary?.object(forKey: WebServiceConstants.RESPONSE_MESSAGE_KEY) as? String
                                }else{
                                    successMessage = "Successfull"
                                }
                            }else{
                                successMessage = "Successfull"
                            }
                            showNotification(successMessage!, showOnNavigation: false, showAsError: false)
                        }
                        DispatchQueue.main.async(execute: {
                            completionBlock!(responseDictionary as? NSDictionary)
                        })
                    }
                    else if self.isFailure(responseDictionary as! NSDictionary?){
                        var errorMessage : String?
                        if (responseDictionary?.object(forKey: WebServiceConstants.RESPONSE_MESSAGE_KEY) != nil) {
                            if (responseDictionary?.object(forKey: WebServiceConstants.RESPONSE_MESSAGE_KEY) is NSDictionary) {
                                errorMessage = responseDictionary?.object(forKey: WebServiceConstants.RESPONSE_MESSAGE_KEY) as! String
                            }else{
                                errorMessage = responseDictionary?.description
                            }
                        }
                        else {
                            errorMessage = MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY
                        }
                        if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                            showNotification(errorMessage!, showOnNavigation: false, showAsError: true)
                        }
                        if self.returnFailureResponseAlso {
                            DispatchQueue.main.async(execute: {
                                completionBlock!(responseDictionary as? NSDictionary);
                            })
                        }else{
                            DispatchQueue.main.async(execute: {
                                completionBlock!(nil)
                            })
                        }
                    }
                    else {
                        if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                            showNotification(MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY, showOnNavigation: false, showAsError: true)
                        }
                        if self.returnFailureResponseAlso {
                            DispatchQueue.main.async(execute: {
                                completionBlock!(responseDictionary as? NSDictionary)
                            })
                        }else{
                            DispatchQueue.main.async(execute: {
                                completionBlock!(nil)
                            })
                        }
                    }
                }
                else {
                    if self.responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                        showNotification(MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY, showOnNavigation: false, showAsError: true)
                    }
                    if self.returnFailureUnParsedDataIfParsingFails {
                        DispatchQueue.main.async(execute: {
                            completionBlock!(["failedParsingResponseReceived":NSString(data: response as! Data!,encoding: String.Encoding.utf8.rawValue)!])
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
                            completionBlock!(nil)
                        })
                    }
                }
            }
        }
        else {
            if responseErrorOption == ResponseErrorOption.showErrorResponseWithUsingNotification {
                showNotification(MESSAGE_TEXT___FOR_SERVER_NOT_REACHABILITY, showOnNavigation: false, showAsError: true)
            }
            DispatchQueue.main.async(execute: {
                completionBlock!(nil)
            })
        }
    }
}

