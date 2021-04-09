// swiftlint:disable all
import Amplify
import Foundation

public struct Todo: Model {
  public let id: String
  public var objName: String
  public var email: String?
  public var joinedWorkplace: Bool?
  public var joinCode: Int?
  public var workplaceName: String?
  public var uploadData: String?
  
  public init(id: String = UUID().uuidString,
      objName: String,
      email: String? = nil,
      joinedWorkplace: Bool? = nil,
      joinCode: Int? = nil,
      workplaceName: String? = nil,
      uploadData: String? = nil) {
      self.id = id
      self.objName = objName
      self.email = email
      self.joinedWorkplace = joinedWorkplace
      self.joinCode = joinCode
      self.workplaceName = workplaceName
      self.uploadData = uploadData
  }
}