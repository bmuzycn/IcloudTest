//
//  ViewController.swift
//  IcloudTest
//
//  Created by Yu Zhang on 8/23/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    var scoreArray = [Int]()
    
    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var userNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }

    @IBAction func generate(_ sender: UIButton) {
        scoreArray = [Int]()
        for num in 0...9 {
            let value = Int.random(in: 0...3)
            scoreArray.append(value)
            text.text.append("\(num + 1): " + String(value) + "\n")
        }
        
        PHQ9.saveData(withUser: userNameField.text ?? "", data: scoreArray)
    }
    
    @IBAction func fetchButton(_ sender: UIButton) {
        text.text = ""
        
        if let user = userNameField.text {
            let data = PHQ9.fetchData(withUser: user) as! Array<[Int]>
            for item in data {
                for score in item {
                    text.text.append(String(score) + "\n")

                }
            }
        } else {
            text.text = "Empty data"
        }
    }
    
    @IBAction func fetchNames(_ sender: UIButton) {
        
        print(UserNames.fetchAll())
        
    }
    
    
}

