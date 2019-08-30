//
//  CloudHelper.swift
//  IcloudTest
//
//  Created by Yu Zhang on 8/28/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

struct Data: Hashable {
    var username: String?
    var scoreArray: [Int]?
    var uuid: String?
}

class CloudHelper {

    static var localIDs = [String]()
    static var cloudIDs = [String]()
    static let errorMessage = "iCloud connection failed. Before sync make sure your device is logged in iCloud account."
    static var recordIDsArray: [CKRecord.ID] = []

    
    
    class func saveData(data: Data, completion:@escaping (Bool)->Void) {
        let cloud = CKContainer.default().privateCloudDatabase
        let newData = CKRecord(recordType: "PHQ9")
        newData.setValue(data.scoreArray, forKey: "scoreArray")
        newData.setValue(data.username, forKey: "userName")
        newData.setValue(data.uuid, forKey: "uuid")
        cloud.save(newData) { (record, error) in
            
            if error == nil {
                print("Save to iCloud successfully!")
                completion(true)
            } else {
                completion(false)
                print(error!)
            }
        }

    }
    
    class func query(byname name: String) -> Any? {
        var result = [Data]()
        var predicate = NSPredicate()
        if name == "All" {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "userName == %@", name)
        }
        let query = CKQuery(recordType: "PHQ9", predicate: predicate)
        let cloud = CKContainer.default().privateCloudDatabase
        let semaphore = DispatchSemaphore(value: 0)

        cloud.perform(query, inZoneWith: nil) { (records, err) in
            if err != nil {
                print(err!)
            } else {
                print("query successfully")
                if let records = records {
                    for item in records {
                        let username = item.value(forKey: "userName") as? String
                        let scoreArray = item.value(forKey: "scoreArray") as? [Int]
                        let uuid = item.value(forKey: "uuid") as? String
                        let newData = Data(username: username, scoreArray: scoreArray, uuid: uuid)
                        let recordID = item.recordID
                        recordIDsArray.append(recordID)
                        result.append(newData)
                    }

                }
                semaphore.signal()
            }
        }
        let timeoutResult = semaphore.wait(timeout: .distantFuture)
        print(timeoutResult)
        return result


    }
    
    class func syncData(complete: @escaping (Bool)->Void) {
        let semaphore = DispatchSemaphore(value: 0)
        let cloud: CKDatabase = CKContainer.default().privateCloudDatabase
        let cloudData = query(byname: "All") as! [Data]
        let localData = PHQ9.fetchData(withUser: "All") as! [Data]
        var uploadData: Set = Set<Data>(localData)
        uploadData.subtract(cloudData)
        var recordsToSave = [CKRecord]()
        if uploadData.count > 0 {
            for data in uploadData {
                let newData = CKRecord(recordType: "PHQ9")
                newData.setValue(data.uuid, forKey: "uuid")
                newData.setValue(data.username, forKey: "userName")
                newData.setValue(data.scoreArray, forKey: "scoreArray")
                recordsToSave.append(newData)
            }
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
            operation.completionBlock = {
                complete(true)
            }
        cloud.add(operation)
        }
        
        var downloadData: Set = Set<Data>(cloudData)
        downloadData.subtract(localData)
        if downloadData.count > 0 {
            for data in downloadData {
                PHQ9.saveData(withUser: data.username, data: data.scoreArray, uuid: data.uuid)
            }
        }
        semaphore.signal()
        let timeoutResult = semaphore.wait(timeout: .distantFuture)
        print(timeoutResult)
    }
    
    class func showAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
    
    
    class func deletAll(completion: @escaping ()->Void ) {
        let cloud: CKDatabase = CKContainer.default().privateCloudDatabase
        let deleteData = query(byname: "All")
        defer {
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsArray)
            operation.completionBlock = {
                print("delete all")
                completion()
            }
            
            cloud.add(operation)
        }

    }
}
