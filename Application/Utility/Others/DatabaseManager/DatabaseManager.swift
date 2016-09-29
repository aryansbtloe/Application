//
//  DatabaseManager.swift
//  Application
//
//  Created by Aryansbtloe on 1/10/16.
//  Copyright © 2016 Aryansbtloe. All rights reserved.
//

//MARK: - DatabaseManager : This class handles communication of application with its database (Core Data).

import Foundation
import UIKit
import MagicalRecord
import CoreData
import EZSwiftExtensions

//MARK: - Completion block
typealias DMCompletionBlock = (_ returnedData :AnyObject?) ->()

class DatabaseManager: NSObject{
    var completionBlock: DMCompletionBlock?
    var managedObjectContext : NSManagedObjectContext?
    /// Description
    static let sharedInstance : DatabaseManager = {
        let instance = DatabaseManager()
        return instance
    }()
    
    func setupCoreDataDatabase() {
        let isDataBaseValid = checkAndValidateDatabase()
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: self.dbStore())
        self.managedObjectContext = NSManagedObjectContext.mr_default()
        if isDataBaseValid == false {
            resetDatabase()
        }
    }
    
    func checkAndValidateDatabase()->Bool{
        let savedBuildInformation = UserDefaults.standard.object(forKey: APP_UNIQUE_BUILD_IDENTIFIER) as? String
        if isNotNull(savedBuildInformation as AnyObject?){
            if savedBuildInformation! == ez.appVersionAndBuild{
                // all is well , dont worry
            }else{
                // reset every thing , please
                deleteCompleteDatabaseFile()
                UserDefaults.standard.set(ez.appVersionAndBuild, forKey: APP_UNIQUE_BUILD_IDENTIFIER)
                return false
            }
        }else{
            deleteCompleteDatabaseFile()
            UserDefaults.standard.set(ez.appVersionAndBuild, forKey: APP_UNIQUE_BUILD_IDENTIFIER)
            return false
        }
        return true
    }
    
    func deleteCompleteDatabaseFile() {
        let dbStore = self.dbStore()
        let url = NSPersistentStore.mr_url(forStoreName: dbStore)
        let walURL = url!.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let shmURL = url!.deletingPathExtension().appendingPathExtension("sqlite-shm")
        var removeError: NSError?
        MagicalRecord.cleanUp()
        let deleteSuccess: Bool
        do {
            try FileManager.default.removeItem(at: url!)
            try FileManager.default.removeItem(at: walURL)
            try FileManager.default.removeItem(at: shmURL)
            deleteSuccess = true
        } catch let error as NSError {
            removeError = error
            deleteSuccess = false
        }
        if deleteSuccess {
            print("database resetted successfully")
        } else {
            print("An error has occured while deleting \(dbStore)")
            print("Error description: \(removeError?.description)")
        }
    }
    
    func dbStore() -> String {
        return "\(self.bundleID()).sqlite"
    }
    
    func bundleID() -> String {
        return Bundle.main.bundleIdentifier!
    }
    
    /**
     * Common Database Operations
     */
    
    func deleteObject(_ object:NSManagedObject){
        managedObjectContext?.delete(object)
        saveChanges()
    }

    func resetDatabase(){
        CacheManager.sharedInstance.resetDatabase()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        saveChanges()
        UserDefaults.standard.set(ez.appVersionAndBuild, forKey: APP_UNIQUE_BUILD_IDENTIFIER)
        setDeviceToken("PLACEHOLDER")
    }
    
    func saveChanges(){
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(DatabaseManager.saveChangesPrivate), object: nil)
        self.perform(#selector(DatabaseManager.saveChangesPrivate), with: nil, afterDelay:0.3)
    }
    
    func saveChangesPrivate(){
        performOnMainThreadWithOptimisation({[weak self] (returnedData) -> () in guard let `self` = self else { return }
            self.managedObjectContext?.mr_saveToPersistentStoreAndWait()
        })
    }
    
    func saveChangesImmediately(){
        self.managedObjectContext?.mr_saveToPersistentStoreAndWait()
    }
}

