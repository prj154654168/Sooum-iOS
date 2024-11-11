//
//  ProfileImageSettingViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/12/24.
//

import ReactorKit
import RxCocoa
import RxSwift
import UIKit

 class ProfileImageSettingViewReactor: Reactor {
     
     enum Action {
         case imageChanged(image: UIImage)
         case registerUser
     }
     
     enum Mutation {
         case uploadImageResult(imageName: Result<String, Error>)
         case registerUserResult(Result<Void, Error>)
     }
     
     struct State {
         var shouldNavigate = false
     }
     
     var initialState = State()
     
     func mutate(action: Action) -> Observable<Mutation> {
         switch action {
         case .imageChanged(let image):
             <#code#>
         case .registerUser:
             <#code#>
         }
     }
     
     func reduce(state: State, mutation: Mutation) -> State {
         var newState = state
         switch mutation {
         case .uploadImageResult(let imageName):
             <#code#>
         case .registerUserResult(let result):
             <#code#>
         }
         return newState
     }
 }
