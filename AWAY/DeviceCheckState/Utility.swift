//
//  Utility.swift
//  CheckLockState
//
//
//

import UIKit

class Utility {
    
    class func checkDeviceLockState(completion: @escaping (DeviceLockState) -> Void) {
       DispatchQueue.main.async {
            if UIApplication.shared.isProtectedDataAvailable {
                completion(.unlocked)
            } else {
                completion(.locked)
            }
        }
    }
}
