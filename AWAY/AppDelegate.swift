//
//  AppDelegate.swift
//  CheckLockState
//
//  Created by Joshua Boelman
//  Copyright © CloutLabs.com. All rights reserved.
//

import UIKit
import Amplify
import AmplifyPlugins
import AWSCore
import AWSPluginsCore
import AWSCognitoIdentityProvider
import AWSAuthCore
import GoogleSignIn


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
   
    
    
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureAmplify()
        listTodos()
        

//        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USWest2,
//           identityPoolId:"us-west-2:adb757ec-2f93-4e40-bd88-0f06506b542a")
//
//        let configuration = AWSServiceConfiguration(region:.USWest2, credentialsProvider:credentialsProvider)
//
//        AWSServiceManager.default().defaultServiceConfiguration = configuration

    
//        Amplify.Auth.signIn(username: "joshcboelman@gmail.com", password: "Administrator",options: AuthSignInRequest.Options?)
//        GIDSignIn.sharedInstance()?.clientID = "804758833775-n6lrsceqpsvonsie870h4d096je74a9m.apps.googleusercontent.com";
//        GIDSignIn.sharedInstance()?.delegate = self
//        listTodos()
        
        
        return true
    }
}





func listTodos() {
    let todo = Todo.keys
    let predicate = todo.objName == "UserData"
    Amplify.API.query(request: .list(Todo.self, where: predicate)) { event in
        switch event {
        case .success(let result):
            switch result {
            case .success(let todo):
                print("Successfully retrieved list of todos: \(todo)")

            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        case .failure(let error):
            print("Got failed event with error \(error)")
        }
    }
}


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
        func configureAmplify() {
            let models = AmplifyModels()
            let apiPlugin = AWSAPIPlugin(modelRegistration: models)
            let dataStorePlugin = AWSDataStorePlugin(modelRegistration: models)
            do {
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
                try Amplify.add(plugin: apiPlugin)
                try Amplify.add(plugin: dataStorePlugin)
                try Amplify.add(plugin: AWSS3StoragePlugin())

                try Amplify.configure()
                print("Initialized Amplify");
            } catch {
                print("Could not initialize Amplify: \(error)")
            }
            
            Amplify.Logging.logLevel = .info

            

        }



