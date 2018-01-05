//
//  AppDelegate.swift
//  fngame
//
//  Created by DerekYang on 2018/1/3.
//  Copyright © 2018年 LBD. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        var flag_login = 0  //修改這個值 以改變 init view
        
        if let url = URL(string: "https://las-stream.tk/appweb/test.json") {
            let urlRequest = URLRequest(url: url)
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            
            // make the request
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) in
                if error != nil {
                    print(error)
                } else {
                    if let usableData = data,
                    let string = String(data: usableData, encoding: String.Encoding.utf8) {
//                        print(string) //JSONSerialization
                        
                        var json: [Any]?
                        do {
                            json = try JSONSerialization.jsonObject(with: usableData) as! [Any]
                            print(json)
                        } catch {
                            print(error)
                        }
                        
                    }
                }
            }.resume()
        }
        
        if (flag_login == 0) { //還沒登入
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Storyboard的名稱
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "StartVC") // view 的 ID
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        } else { //已經登入
            
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Storyboard的名稱
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "WebVC") // view 的 ID
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

