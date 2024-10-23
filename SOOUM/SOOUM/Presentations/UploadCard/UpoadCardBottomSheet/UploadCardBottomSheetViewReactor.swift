//
//  UploadCardBottomSheetViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import ReactorKit

 class UploadCardBottomSheetViewReactor: Reactor {
     
     struct ImageWithName {
         var name: String
         var image: UIImage
     }
     
     enum Action: Equatable {
         /// 이미지 변경 눌렀을때 호출
         case fetchNewDefaultImage
         /// 이미지 업로드용 url, 이름 fetch후 이미지 업로드 까지 이미지 선택 완료시 호출
         case seleteMyImage(UIImage)
     }
     
     enum Mutation {
         /// 기본 이미지 fetch 결과
         case defaultImage(ImageWithName)
         /// 내 이미지 이름 fetch, 이미지 put 까지 완료 하고 이미지 이름 반환
         case myImageName(String)
     }
     
     struct State {
         var defaultImages: [ImageWithName]
     }
     
     var initialState: State = .init(
        defaultImages: []
     )
 }
