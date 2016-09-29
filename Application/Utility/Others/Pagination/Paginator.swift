//
//  Paginator.swift
//  Application
//
//  Created by Aryansbtloe on 1/10/16.
//  Copyright © 2016 Aryansbtloe. All rights reserved.
//


import Foundation

enum PaginatorMode {
    case sample
}

class Paginator: AKSPaginator   {
    var paginationFor : PaginatorMode?
    var userInfo : NSDictionary?
    override func fetchPage(_ page:NSInteger){
        if paginationFor == PaginatorMode.sample {
//            self.requestStatus = RequestStatus.RequestStatusInProgress
//            let information = ["userId":self.userInfo!["userId"] as! String]
//            let webService = WebServices()
//            webService.responseErrorOption = .DontShowErrorResponseMessage
//            webService.getFeedbacks(information) { (responseData) -> () in
//                if let _ = responseData {
//                    if let feedbacks = responseData!.objectForKey("data") {
//                        super.setSuccess(feedbacks as! [AnyObject], totalResults:0)
//                    }else{
//                        super.setFailure()
//                    }
//                }else{
//                    super.setFailure()
//                }
//            }
        }
    }
}


