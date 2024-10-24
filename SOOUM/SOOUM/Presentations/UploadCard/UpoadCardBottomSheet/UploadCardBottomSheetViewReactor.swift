//
//  UploadCardBottomSheetViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import ReactorKit

 class UploadCardBottomSheetViewReactor: Reactor {
     struct ImageURLWithName {
         var name: String
         var urlString: String
     }
     
     enum Action: Equatable {
         /// 처음, 이미지 변경 눌렀을때 호출
         case fetchNewDefaultImage
         /// 이미지 업로드용 url&이름 fetch후 이미지 업로드 까지 이미지 선택 완료시 호출
         case seleteMyImage(UIImage)
     }
     
     enum Mutation {
         /// 기본 이미지 fetch 결과
         case defaultImages([ImageURLWithName])
         /// 내 이미지 이름 fetch, 이미지 put 까지 완료 하고 이미지 이름 반환
         case myImageName(String)
     }
     
     struct State {
         /// 선택한 이미지 이름
         var myImageName: String?
         var defaultImages: [ImageURLWithName]
     }
     
     var initialState: State = .init(
        myImageName: nil,
        defaultImages: []
     )
     
     private let networkManager = NetworkManager.shared
     
     func mutate(action: Action) -> Observable<Mutation> {
         switch action {
         case .fetchNewDefaultImage: 
             return (fetchDefaultImages())
         case let .seleteMyImage(myImage):
             return (fetchDefaultImages())
         }
     }
     
     func reduce(state: State, mutation: Mutation) -> State {
         var state = state
         switch mutation {
         case let .defaultImages(images):
             state.defaultImages = images
             
         case let .myImageName(imageName):
             state.myImageName = imageName
         }
         return state
     }
     
     func fetchDefaultImages() -> Observable<Mutation> {
         print("\(type(of: self)) - \(#function)")

         let request: UploadRequest = .defaultImages
         
         return self.networkManager.request(DefaultCardImageResponse.self, request: request)
             .map(\.embedded.imgURLInfoList)  // embedded 내의 imgURLInfoList를 가져옵니다.
             .map { imageInfoList in
                 print("fetchDefaultImages", imageInfoList)
                 // imgURLInfoList를 ImageURLWithName 배열로 변환
                 let images = imageInfoList.map { ImageURLWithName(name: $0.imgName, urlString: $0.url.href) }
                 return Mutation.defaultImages(images)
             }
     }
 }
