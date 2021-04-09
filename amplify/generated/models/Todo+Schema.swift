// swiftlint:disable all
import Amplify
import Foundation

extension Todo {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case objName
    case email
    case joinedWorkplace
    case joinCode
    case workplaceName
    case uploadData
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let todo = Todo.keys
    
    model.pluralName = "Todos"
    
    model.fields(
      .id(),
      .field(todo.objName, is: .required, ofType: .string),
      .field(todo.email, is: .optional, ofType: .string),
      .field(todo.joinedWorkplace, is: .optional, ofType: .bool),
      .field(todo.joinCode, is: .optional, ofType: .int),
      .field(todo.workplaceName, is: .optional, ofType: .string),
      .field(todo.uploadData, is: .optional, ofType: .string)
    )
    }
}