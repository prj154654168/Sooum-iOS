//
//  UploadCardBottomSheetViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import Kingfisher
import ReactorKit

struct ImageURLWithName {
    var name: String
    var urlString: String
}

struct ImageWithName {
    var name: String
    var image: UIImage
}

class UploadCardBottomSheetViewReactor: Reactor {
    
    enum Action: Equatable {
        /// 처음, 이미지 변경 눌렀을때 호출
        case fetchNewDefaultImage
        /// 이미지 업로드용 url&이름 fetch후 이미지 업로드 까지 이미지 선택 완료시 호출
        case seleteMyImage(UIImage)
    }
    
    enum Mutation {
        /// 기본 이미지 fetch 결과
        case defaultImages([ImageWithName])
        /// 내 이미지 이름 fetch, 이미지 put 까지 완료 하고 이미지 이름 반환
        case myImageName(String)
    }
    
    struct State {
        /// 선택한 이미지 이름
        var myImageName: String?
        var defaultImages: [ImageWithName]
    }
    
    var initialState: State = .init(
       myImageName: nil,
       defaultImages: []
    )
    
    private let networkManager = NetworkManager.shared
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchNewDefaultImage:
            return fetchDefaultImages()
        case let .seleteMyImage(myImage):
            // 내 이미지 업로드 로직 구현 필요
            return Observable.empty()
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
            .map(\.embedded.imgURLInfoList)
            .flatMap { imageInfoList -> Observable<Mutation> in
                let imageURLWithNames: [ImageURLWithName] = imageInfoList.map {
                    ImageURLWithName(name: $0.imgName, urlString: $0.url.href)
                }
                return Observable.from(imageURLWithNames)
                    .flatMap { imageURLWithName -> Observable<ImageWithName?> in
                        self.downloadImage(imageURLWithName: imageURLWithName)
                    } // 각 ImageURLWithName를 옵저버블<ImageURLWithName>로 바꾼 후
                    .compactMap { $0 } // nil 값 제거
                    .toArray()
                    .asObservable()
                    .map { imagesWithNames in
                        return Mutation.defaultImages(imagesWithNames)
                    }
            }
    }
    
    func downloadImage(imageURLWithName: ImageURLWithName) -> Observable<ImageWithName?> {
        guard let url = URL(string: imageURLWithName.urlString) else {
            return Observable.just(nil)
        }

        return Observable<ImageWithName?>.create { observer in
            // Kingfisher를 사용한 이미지 다운로드
            let task = KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    let imageWithName = ImageWithName(name: imageURLWithName.name, image: value.image)
                    observer.onNext(imageWithName) // 성공 시 이미지 방출
                case .failure:
                    observer.onNext(nil) // 실패 시 nil 방출
                }
                observer.onCompleted() // 작업 완료
            }
            
            // 반환된 작업을 사용해 Kingfisher의 취소 작업을 처리
            return Disposables.create {
                task?.cancel()
            }
        }
    }
}
