//
//  UploadCardBottomSheetViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 10/16/24.
//

import UIKit

import Alamofire
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
    
    enum RequestType {
        case card
        case comment
    }
    
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
    
    let provider: ManagerProviderType
    let requestType: RequestType
    
    init(provider: ManagerProviderType, type requestType: RequestType) {
        self.provider = provider
        self.requestType = requestType
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchNewDefaultImage:
            // return fetchDefaultImages()
            return .empty()
        case let .seleteMyImage(myImage):
            // return uploadMyImage(myImage: myImage)
            return .empty()
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
    
//    func fetchDefaultImages() -> Observable<Mutation> {
//        
//        let request: UploadRequest = .defaultImages
//        
//        return self.provider.networkManager.request(DefaultCardImageResponse.self, request: request)
//            .map(\.embedded.imgURLInfoList)
//            .flatMap { imageInfoList -> Observable<Mutation> in
//                let imageURLWithNames: [ImageURLWithName] = imageInfoList.map {
//                    ImageURLWithName(name: $0.imgName, urlString: $0.url.href)
//                }
//                return Observable.from(imageURLWithNames)
//                    .withUnretained(self)
//                    .flatMap { object, imageURLWithName -> Observable<ImageWithName?> in
//                        object.downloadImage(imageURLWithName: imageURLWithName)
//                    } // 각 ImageURLWithName를 옵저버블<ImageURLWithName>로 바꾼 후
//                    .compactMap { $0 } // nil 값 제거
//                    .toArray()
//                    .asObservable()
//                    .map { imagesWithNames in
//                        return Mutation.defaultImages(imagesWithNames)
//                    }
//            }
//    }
    
    private func downloadImage(imageURLWithName: ImageURLWithName) -> Observable<ImageWithName?> {
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
    
//    func uploadMyImage(myImage: UIImage) -> Observable<Mutation> {
//
//        let presignedURLRequest: UploadRequest = .presignedURL
//        
//        return self.provider.networkManager.request(PresignedStorageResponse.self, request: presignedURLRequest)
//            .flatMap { [weak self] presignedResponse -> Observable<Mutation> in
//                guard let self = self else { return Observable.just(Mutation.myImageName("")) }
//                
//                // 2. presigned URL을 통해 이미지를 업로드합니다.
//                guard let url = URL(string: presignedResponse.url.url) else {
//                    return Observable.just(Mutation.myImageName(""))
//                }
//                
//                return Observable.create { observer in
//                    self.uploadImageToURL(image: myImage, url: url) { result in
//                        switch result {
//                        case .success:
//                            observer.onNext(Mutation.myImageName(presignedResponse.imgName))
//                            observer.onCompleted()
//                        case .failure(let error):
//                            // 4. 실패 시 에러 방출
//                            observer.onError(error)
//                        }
//                    }
//                    
//                    return Disposables.create()
//                }
//            }
//    }
    
    func uploadImageToURL(image: UIImage, url: URL, completion: @escaping (Result<Void, Error>) -> Void) {

        // 이미지를 JPEG로 변환
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "ImageConversionError", code: 0, userInfo: nil)))
            return
        }
        
        AF.upload(imageData, to: url, method: .put)
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
