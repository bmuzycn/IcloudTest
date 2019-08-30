//
//  PHQ9.swift
//  IcloudTest
//
//  Created by Yu Zhang on 8/26/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import Foundation
import CoreData

class PHQ9: NSManagedObject {

    class func fetchData(withUser user: String) -> Any? {
        var dataArrays = Array<Data>()
        
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<PHQ9>(entityName: "PHQ9")
        request.predicate = NSPredicate(format: "userName == %@", user)
        if user == "All" {
            request.predicate = NSPredicate(value: true)
        }
        do {
            let data = try context.fetch(request)
            for item in data {
                let newData = Data(username: item.userName, scoreArray: item.scoreArray, uuid: item.uuid)
                dataArrays.append(newData)
            }
        } catch {
            print(error)
            
        }
        return dataArrays
    }
    
    class func saveData(withUser user: String?, data: [Int]?, uuid: String?) {
        var userExists = false
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<UserNames>(entityName: "UserNames")
        request.predicate = NSPredicate(format: "username == %@", user ?? "")
        var userNames: UserNames?
        do {
            let data = try context.fetch(request)
            if data.count > 0 {
                userNames = data.first
                userExists = true
            }

        } catch {
            print(error)
        }

        
        let newData = PHQ9(context: context)
        newData.scoreArray = data
        newData.userName = user
        newData.uuid = uuid
        if userExists == false {
            userNames = UserNames(context: context)
            userNames!.username = user
        }
        newData.userNames = userNames
        do {
            try context.save()
        } catch {
            fatalError("Fail to save the context. \(error)")
        }
    }
}
