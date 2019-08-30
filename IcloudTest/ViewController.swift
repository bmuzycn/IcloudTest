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
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var text: UITextView!
    
    @IBOutlet weak var userNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        indicator.hidesWhenStopped = true
    }

    @IBAction func generate(_ sender: UIButton) {
        scoreArray = [Int]()
        for num in 0...9 {
            let value = Int.random(in: 0...3)
            scoreArray.append(value)
            text.text.append("\(num + 1): " + String(value) + "\n")
        }
        let uuid = UUID().uuidString
        PHQ9.saveData(withUser: userNameField.text ?? "", data: scoreArray, uuid: uuid)
        guard let userName = userNameField.text else {return}
            
        CloudHelper.saveData(data: Data(username: userName, scoreArray: scoreArray, uuid: uuid)){[unowned self] sucess in
            if sucess == false {
                let alert = CloudHelper.showAlert(message: "iCloud error")
                self.present(alert, animated: true)
            }
        }

    }
    
    @IBAction func fetchButton(_ sender: UIButton) {
        text.text = ""
        
        if let user = userNameField.text {
            let data = PHQ9.fetchData(withUser: user) as! [Data]
            for item in data {
                for score in item.scoreArray ?? [] {
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
    
    @IBAction func sync(_ sender: UIButton) {
        indicator.isHidden = false
        indicator.startAnimating()
        CloudHelper.syncData { (success) in
            if success {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                }

            }
        }
    }
    
    @IBAction func deleteAll(_ sender: UIButton) {
        indicator.startAnimating()

        CloudHelper.deletAll{
            print("delete all")
            DispatchQueue.main.async {
                self.indicator.stopAnimating()

            }

        }

    }
}

