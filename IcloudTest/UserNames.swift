//
//  UserNames.swift
//  IcloudTest
//
//  Created by Yu Zhang on 8/26/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import Foundation
import CoreData

class UserNames: NSManagedObject {
    class func fetchAll() -> [String]{
        var usernames = [String]()
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<UserNames>(entityName: "UserNames")

        do {
            let data = try context.fetch(request)
            for item in data {
                guard let username = item.username else { continue }
                usernames.append(username)
            }
        } catch {
            fatalError("Fetch fails \(error) ")
        }
        return usernames
    }
}
