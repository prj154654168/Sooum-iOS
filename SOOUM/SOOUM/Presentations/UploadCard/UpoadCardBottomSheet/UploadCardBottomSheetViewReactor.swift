//
//  UploadCardBottomSheetViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import ReactorKit

 class UploadCardBottomSheetViewReactor: Reactor {
     enum Action: Equatable {
         case refresh
         case coordinate(String, String)
     }
     
     enum Mutation {
         case detailCard(DetailCard)
         case updateCoordinate(String, String)
         case updateIsLoading(Bool)
     }
     
     struct State {
         var detailCard: DetailCard
         var coordinate: (String?, String?)
         var isLoading: Bool
     }
     
     var initialState: State = .init(
         detailCard: .init(),
         coordinate: (nil, nil),
         isLoading: false
     )
 }
