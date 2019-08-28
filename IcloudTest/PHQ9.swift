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
        var scoreArrays = Array<[Int]>()
        
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<PHQ9>(entityName: "PHQ9")
        request.predicate = NSPredicate(format: "userName == %@", user)
        do {
            let data = try context.fetch(request)
            print(data.count)
            for item in data {
                if let scores = item.scoreArray {
                    scoreArrays.append(scores)

                }
            }
        } catch {
            print(error)
            
        }
        print(scoreArrays)
        return scoreArrays
    }
    
    class func saveData(withUser user: String, data: [Int]) {
        var userExists = false
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<UserNames>(entityName: "UserNames")
        request.predicate = NSPredicate(format: "username == %@", user)
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
