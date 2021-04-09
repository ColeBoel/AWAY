//
//  ViewController.swift
//  AWAY
//
//  Created by Joshua Boelman
//  Copyright © Cloutlabs. All rights reserved.
//

import UIKit
import Darwin
import AVKit
import AVFoundation
import CoreLocation
import Amplify
import AmplifyPlugins
import Combine
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager: CLLocationManager?
    var t = 0
    var i = 0
    var timesU = [String]();
    var timesL = [String]();
    var timesO = [String]();
    var dateL = [Date]();
    var dateU = [Date]();
    var durations = [Double]();
    var todoSubscription: AnyCancellable?
    
    
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    var menuOpen = false;
    
    
    @IBAction func MenuTapped(_ sender: Any) {
        
        if menuOpen == false{
            leading.constant = 240
            trailing.constant = -240
            menuOpen = true
        }else {
            leading.constant = 0
            trailing.constant = 0
            menuOpen = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()})
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.performOnAppear()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        
        
        
        }
    
    
    @IBAction func signOut(_ sender: Any) {
        signOutGlobally()
        
    }
    
 
    
       
    func signOutGlobally() {
        Amplify.Auth.signOut(options: .init(globalSignOut: true)) { result in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
        
    }
  
    
    func fetchAttributes() {
        Amplify.Auth.fetchUserAttributes() { result in
            switch result {
            case .success(let attributes):
                print("User attributes - \(attributes)")
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
            }
        }
        }
        

        func performOnAppear() {
            subscribeTodos()
            listTodos()
            
//
//            let item = Todo(objName: "TestToDo")
//
//                   Amplify.DataStore.save(item) { result in
//                      switch(result) {
//                      case .success(let savedItem):
//                          print("Saved item: \(savedItem.objName)")
//                      case .failure(let error):
//                          print("Could not save item to datastore: \(error)")
//                      }
//                   }
               }
          
           
        
           
    
    
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }

    
   
    
    @IBAction func UploadtoS3Bucket(_ sender: Any) {
        let now = getFormattedDate(date: Date(), format: "MM-dd-yyyy")
        var userDataArray = ["    --Unlocked--                     --Locked--                  --Duration--  \n",]
        for(U,(L,D)) in zip(timesU,zip(timesL,durations)){
            userDataArray.append("\(U)     -     \(L)     -     \(D) \n")
     }
        
                Amplify.DataStore.query(Todo.self) { result in
                       switch(result) {
                       case .success(let todos):
                           for todo in todos {
                            if(todo.objName == "UserData" && todo.joinedWorkplace == true){
                                if let url = todo.workplaceName, let userKey = todo.email {
                                uploadData(dataString: userDataArray.joined(), dataKey:"\(url)\(userKey) - \(now)")
                                break
                               }
                           }
                            else if(todo.objName == "UserData" && todo.joinedWorkplace == false){
                                if let userKey = todo.email {
                                 uploadData(dataString: userDataArray.joined(), dataKey:"UserData/Unassigned/\(userKey) - \(now)")
                                    break
                              }
                           }
                            else {
                                print("Not Signed In")
                                
                            }
                            
                           }
                       case .failure(let error):
                           print("Could not query DataStore: \(error)")
                       }
                   }
        
    }
    
    
    
    @IBAction func showStats(_ sender: Any) {
        Amplify.DataStore.query(Todo.self) { result in
               switch(result) {
               case .success(let todos):
                   for todo in todos {
                    if(todo.objName == "sData"){
                        downloadData(inputKey: todo.workplaceName!)
                        break
                   }
                    else {
                       
                        
                    }
                   }
               case .failure(let error):
                   print("Could not query DataStore: \(error)")
               }
           }
       
    
       
    }
    
    
    func downloadData(inputKey : String){
        Amplify.Storage.downloadData(
            key: inputKey,
            progressListener: { progress in
                print("Progress: \(progress)")
            }, resultListener: { (event) in
                switch event {
                case let .success(data):
                    print("Completed: \(data)")
                        
                case let .failure(storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        })
    }
    
    
    func uploadData(dataString : String, dataKey: String) {
        let data = dataString.data(using: .utf8)!
        Amplify.Storage.uploadData(key: dataKey, data: data,
            progressListener: { progress in
                print("Progress: \(progress)")
            }, resultListener: { (event) in
                switch event {
                case .success(let data):
                    print("Completed: \(data)")
                case .failure(let storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
        })
    }
    
    
    func subscribeTodos() {
       self.todoSubscription
           = Amplify.DataStore.publisher(for: Todo.self)
               .sink(receiveCompletion: { completion in
                   print("Subscription has been completed: \(completion)")
               }, receiveValue: { mutationEvent in
                   print("Subscription got this value: \(mutationEvent)")

                   do {
                     let todo = try mutationEvent.decodeModel(as: Todo.self)

                     switch mutationEvent.mutationType {
                     case "create":
                       print("Created: \(todo)")
                     case "update":
                       print("Updated: \(todo)")
                     case "delete":
                       print("Deleted: \(todo)")
                     default:
                       break
                     }

                   } catch {
                     print("Model could not be decoded: \(error)")
                   }
               })
    }
     func fetchCurrentAuthSession(){
        _ = Amplify.Auth.fetchAuthSession { result in
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAttributes()
        fetchCurrentAuthSession()
        if(Amplify.Auth.getCurrentUser() == nil){
            let vc = storyboard?.instantiateViewController(identifier: "Login") as! ViewControllerLogin
            present(vc,animated: true)
            
        }

        
        manager = CLLocationManager()
        
        manager?.delegate = self
        if #available(iOS 14.0, *) {
            manager?.desiredAccuracy = kCLLocationAccuracyKilometer
        } else {
            manager?.desiredAccuracy = kCLLocationAccuracyKilometer
        }
        manager?.requestWhenInUseAuthorization()
        manager?.startUpdatingLocation()
        manager?.allowsBackgroundLocationUpdates = true
        

    }
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]){
        guard locations.first != nil else {
            return
        }

    }
    
    
    
    var backgroundTaskID: UIBackgroundTaskIdentifier!
    var clOut = true

    @IBAction func actionButtonTapped(_ sender: UIButton!) {
        sender.isSelected.toggle()

        if(clOut == true){
        print("clocked in")
        runBackgroundCheck()
        clOut = false
        } else {
            Clockout()
            clOut = true
        }
        
        
    }
    
    func Clockout() {
          
                Amplify.DataStore.stop { result in
                    switch result {
                    case .success:
                        print("DataStore stopped")
                    case .failure(let error):
                        print("Error stopping DataStore: \(error)")
                    }
                }
                print("Clocked out")
                print("           ")
                print("    --Unlocked--                     --Locked--                  --Duration--  ")
                
              
                for(U,(L,D)) in zip(timesU,zip(timesL,durations)){
                    print("\(U)     -     \(L)     -     \(D)")
             }
            
                
                
            }
    
    
    func runBackgroundCheck(){
        _ = Timer.scheduledTimer(timeInterval: 1.0,
                                                               target: self,
                                                               selector: #selector(checkState),
                                                               userInfo: nil,
                                                               repeats: true)
    }
  
    func showPhoneState(_ deviceLockState: DeviceLockState) {
        
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let dateTimeU = formatter.string(from: now)
        
        switch deviceLockState {
        case .locked:
            //print("locked")
            if (t == 1){
                print(now - 11.83, " ---  Locked.")
                let dateTimeL = formatter.string(from: now - 11.83)
                timesL.append(dateTimeL)
                dateL.append(now - 11.83)
                durations.append(dateL[i].timeIntervalSince(dateU[i]))
                i += 1;
            }
            t = 0
        case .unlocked:
            //print("Unlocked")
            if (t == 0){
                print(now, " ---  Unlocked." )
                timesU.append(dateTimeU)
                dateU.append(now)
            }
            t = 1
        }
        
    }
    
    

        
    
    
    var end = 0;
    
    
    @objc func checkState(){
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {[weak self] in
            Utility.checkDeviceLockState() {
                lockState in
                if let self = self {
                    self.showPhoneState(lockState)
                }
            }
        }
     
    }
    
    @objc func endBack(){
        
        UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
        backgroundTaskID = UIApplication.shared.beginBackgroundTask()
    }
    


}

