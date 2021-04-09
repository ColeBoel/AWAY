//
//  ViewController.swift
//  AWAY
//
//  Created by Joshua Boelman on 1/6/21.
//
//
import UIKit
import Darwin
import AVKit
import AVFoundation
import CoreLocation
import Amplify
import AmplifyPlugins
import Combine

class ViewControllerLogin: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }


    @IBAction func SignUp(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "signUp") as! ViewControllerLogin
        present(vc,animated: true)
    }
    
    
    @IBOutlet weak var _emailSignUp: UITextField!
    
    @IBOutlet weak var _passwordSignUp: UITextField!
    
    func signUp(username: String, password: String, email: String) {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)

        Amplify.Auth.signUp(username: username, password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                } else {
                    print("SignUp Complete")
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
            }
        }
    }
    
    @IBAction func SignUpConfirm(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "confirmation") as! ViewControllerLogin
        present(vc,animated: true)
        
        let username = _emailSignUp.text
        let password = _passwordSignUp.text
        let email = _emailSignUp.text
            
        if (username == "" || password == "" || email == ""){
                return
        } else {
            print("Email : ", _emailSignUp.text as Any )
            print("Password: ", _passwordSignUp.text as Any)
            signUp(username: username!, password: password! , email: email!)
                    }
                }
    
  
    
    @IBOutlet weak var _emailSignIn: UITextField!
    @IBOutlet weak var _passwordSignIn: UITextField!
    
    
    @IBAction func signIn(_ sender: Any) {
        let username = _emailSignIn.text
        let password = _passwordSignIn.text
        signIn(username: username!, password: password!)
        
        Amplify.DataStore.query(Todo.self) { result in
               switch(result) {
               case .success(let todos):
                   for todo in todos {
                    if(todo.objName != "UserData" && todo.objName != "TestToDo"){
                        print(todo.objName)
                        print("MAKING A NEW TODO")
                        
                        let item = Todo(objName: "UserData", email : _emailSignIn.text!, joinedWorkplace: false, joinCode: nil, workplaceName: _emailSignIn.text! ,uploadData: nil)

                        Amplify.DataStore.save(item) { result in
                                   switch(result) {
                                   case .success(let savedItem):
                                       print("Saved item: \(savedItem.objName) - \(savedItem.email)")
                                   case .failure(let error):
                                       print("Could not save item to datastore: \(error)")
                                   }
                                }
                        break

                    
                   }
                    else if(todo.objName == "UserData") {
                        print("Todo already created")
                        break

                    }
                    else {
                        listTodos()
                    }
                   }
               case .failure(let error):
                   print("Could not query DataStore: \(error)")
               }
           }
       
    }

    
    @IBOutlet weak var JoinCode: UILabel!
    @IBOutlet weak var cName: UILabel!
    
    @IBOutlet weak var companyName: UITextField!

    @IBAction func createWorkplace(_ sender: Any) {
        var company : String?
        company = companyName.text
        let joinC = arc4random_uniform(900000) + 100000;
        self.JoinCode.text = "Join Code: \(joinC)"
        self.cName.text = "Company Name: \(company!)"
        uploadData(dataString: company!, dataKey: "UserData/\(company!) - \(joinC)/")
        
        
        
    }
    func uploadData(dataString : String, dataKey: String) {
//        let dataString = "Example file contents"
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
   
    
    @IBOutlet weak var joinCodeEntered: UITextField!
    
    
    @IBAction func joinWorkplace(_ sender: Any) {
        let jC = joinCodeEntered.text
        if(joinCodeEntered == nil){
            print("Please enter join jode")
        } else {
        Amplify.Storage.list { event in
            switch event {
            case let .success(listResult):
                print("Completed")
                listResult.items.forEach { item in
                    if(item.key.contains("\(jC!)")){
                        print("Key: \(item.key)")
                        
                            Amplify.DataStore.query(Todo.self) { result in
                               switch(result) {
                               case .success(let todos):
                                   for todo in todos {
                                    if(todo.objName == "UserData"){
                                       if let email = todo.email {
                                        let dScript = item.key + email
                                        print(dScript)
                                        let joinC = Int(jC!)
                                        
                                       
                                        Amplify.DataStore.query(Todo.self,
                                                                 where: Todo.keys.objName.eq("UserData")) { result in
                                             switch(result) {
                                             case .success(let todos):
                                                 guard todos.count == 3, var updatedTodo = todos.first else {
                                                     print("Did not find exactly one todo, bailing")
                                                     return
                                                 }
                                                updatedTodo.objName = "UserData"
                                                updatedTodo.email = email
                                                updatedTodo.joinedWorkplace = true
                                                updatedTodo.joinCode = joinC;
                                                updatedTodo.workplaceName = item.key
                                                updatedTodo.uploadData = nil
                
                                                Amplify.DataStore.save(updatedTodo) { result in
                                                     switch(result) {
                                                     case .success(let savedTodo):
                                                         print("Updated item: \(savedTodo.objName)")
                                                     case .failure(let error):
                                                         print("Could not update data in Datastore: \(error)")
                                                     }
                                                 }
                                             
                                             case .failure(let error):
                                                 print("Could not query DataStore: \(error)")
                                             }
                                         } } }
                                   }
                               case .failure(let error):
                                   print("Could not query DataStore: \(error)")
                               }
                           }
                        
                    } else {
                        return
                    }
                    
                }
                
            case let .failure(storageError):
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
            }
           
        }
        }
    }
//        let jC = joinCodeEntered.text
//        if(joinCodeEntered == nil){
//            print("Please enter join jode")
//        } else {
//        Amplify.Storage.list { event in
//            switch event {
//            case let .success(listResult):
//                print("Completed")
//                listResult.items.forEach { item in
//                    if(item.key.contains("\(jC!)")){
//                        print("Key: \(item.key)")
//
//                        Amplify.DataStore.query(Todo.self,
//                                                where: Todo.keys.name.eq("signInData")) { result in
//                            switch(result) {
//                            case .success(let todos):
//                                guard todos.count == 1, var updatedTodo = todos.first else {
//                                    print("COULD NOT FIND THAT SHIT")
//                                    return
//                                }
//                                updatedTodo.name = "signInData"
//
//                                let dScript = item.key + self.description
//
//                                updatedTodo.description = dScript
//
//                                Amplify.DataStore.save(updatedTodo) { result in
//                                    switch(result) {
//                                    case .success(let savedTodo):
//                                        print("Updated item: \(savedTodo.name)")
//                                    case .failure(let error):
//                                        print("Could not update data in Datastore: \(error)")
//                                    }
//                                }
//                            case .failure(let error):
//                                print("Could not query DataStore: \(error)")
//                            }
//                        }
//
//                 } else {
//                     print("Please enter 6 digit join code.")
//                 }
//             }
//         case let .failure(storageError):
//             print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
//         }
//        }
//     }
// }
//                        Amplify.DataStore.query(Todo.self) { result in
//                               switch(result) {
//                               case .success(let todos):
//                                   for todo in todos {
//                                    if(todo.name == "signInData"){
//                                       if let description = todo.description {
//                                        let dScript = item.key + description
//                                        print(dScript)
//
//
//                                        let item = Todo(name: "signInData",
//                                                        description: dScript)
//
//                                        Amplify.DataStore.save(item) { result in
//                                                   switch(result) {
//                                                   case .success(let savedItem):
//                                                       print("Saved item: \(savedItem.name)")
//                                                   case .failure(let error):
//                                                       print("Could not save item to datastore: \(error)")
//                                                   }
//                                                }
//                                       }
//                                   }
//                                   }
//                               case .failure(let error):
//                                   print("Could not query DataStore: \(error)")
//                               }
                        
                        
    

                        
               
    
    @IBOutlet weak var useremailleave: UITextField!
    @IBAction func leaveWorkplaace(_ sender: Any) {
        
        
        Amplify.DataStore.query(Todo.self,
                                where: Todo.keys.objName.eq("UserData")) { result in
            switch(result) {
            case .success(let todos):
                guard todos.count == 1, var updatedTodo = todos.first else {
                    print("COULD NOT FIND THAT SHIT")
                    return
                }
                updatedTodo.objName = "UserData"
                updatedTodo.email = useremailleave.text!
                
                Amplify.DataStore.save(updatedTodo) { result in
                    switch(result) {
                    case .success(let savedTodo):
                        print("Updated item: \(savedTodo.objName)")
                    case .failure(let error):
                        print("Could not update data in Datastore: \(error)")
                    }
                }
            case .failure(let error):
                print("Could not query DataStore: \(error)")
            }
        }
        
        
        
        
//        let item = Todo(name: "SignInData",
//                        description: useremailleave.text!)
//
//
//
//        Amplify.DataStore.save(item) { result in
//                   switch(result) {
//                   case .success(let savedItem):
//                       print("Saved item: \(savedItem.name)")
//                   case .failure(let error):
//                       print("Could not save item to datastore: \(error)")
//                   }
//                }
        
    }
    
    
    
    
    
    
    
    func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
            case .failure(let error):
                print("Sign in failed \(error)")
            }
        }
    }
    
    @IBOutlet weak var emailconfirm: UITextField!
    @IBOutlet weak var _confirmCode: UITextField!
    @IBAction func ConfirmSignUpCode(_ sender: Any) {
        

        confirmSignUp(for: emailconfirm.text!, with: _confirmCode.text!)
        
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
            switch result {
            case .success:
                print("Confirm signUp succeeded")
            case .failure(let error):
                print("An error occurred while confirming sign up \(error)")
            }
        }
    }
    
    

   

    


}

