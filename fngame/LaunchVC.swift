//
//  LaunchVC.swift
//  fngame
//
//  Created by DerekYang on 2018/1/8.
//  Copyright © 2018年 LBD. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {

    var urls = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //        var flag_login = 0  //修改這個值 以改變 init view
        
        if let url = URL(string: "https://las-stream.tk/appweb/app.json") {
            let urlRequest = URLRequest(url: url)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            // make the request
            let task = session.dataTask(with: urlRequest) {
                [weak self]
                (data, response, error) in
                
                if let strongSelf = self {
                    if error == nil {
                        if let usableData = data {
                            do {
                                if let array = try JSONSerialization.jsonObject(with: usableData) as? [Any] {
                                    //                                print(array)
                                    for item in array {
                                        if let json = item as? [String : Any],
                                        let name = json["ios_name"] as? String,
                                        let urls = json["domain"] as? [String],
                                        let review = json["review"] as? Bool {
                                            print(name)
                                            if(name == Bundle.main.bundleIdentifier) {
                                                strongSelf.urls = urls
                                                
                                                for url in urls {
                                                    print(url)
                                                }
                                                DispatchQueue.main.async {
                                                    if(review) {
                                                        strongSelf.performSegue(withIdentifier: "LaunchVC2StartVC", sender: nil)
                                                    } else {
                                                        strongSelf.performSegue(withIdentifier: "LaunchVC2WebVC", sender: nil)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                   
                                }
                            } catch {
                                print(error)
                                DispatchQueue.main.async {
                                    strongSelf.performSegue(withIdentifier: "LaunchVC2StartVC", sender: nil)
                                }
                            }
                            
                        } else {
                            DispatchQueue.main.async {
                                strongSelf.performSegue(withIdentifier: "LaunchVC2StartVC", sender: nil)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            strongSelf.performSegue(withIdentifier: "LaunchVC2StartVC", sender: nil)
                        }
                    }
                }
            }
            task.resume()
        }
        
        
        
        //        if (flag_login == 0) { //還沒登入
        //
        //            self.window = UIWindow(frame: UIScreen.main.bounds)
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Storyboard的名稱
        //
        //            let initialViewController = storyboard.instantiateViewController(withIdentifier: "StartVC") // view 的 ID
        //
        //            self.window?.rootViewController = initialViewController
        //            self.window?.makeKeyAndVisible()
        //
        //        } else { //已經登入
        //
        //            self.window = UIWindow(frame: UIScreen.main.bounds)
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Storyboard的名稱
        //            let initialViewController = storyboard.instantiateViewController(withIdentifier: "WebVC") // view 的 ID
        //
        //            self.window?.rootViewController = initialViewController
        //            self.window?.makeKeyAndVisible()
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "LaunchVC2WebVC" {
            if let destVC = segue.destination as? WebVC {
                destVC.urls = self.urls
            }
        }
        super.prepare(for: segue, sender: sender)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
