//
//  ProfileImageSettingViewReactor.swift
//  SOOUM
//
//  Created by JDeoks on 11/12/24.
//


import UIKit

import Alamofire
import ReactorKit
import RxCocoa
import RxSwift

class ProfileImageSettingViewReactor: Reactor {
    
    enum Action {
        case imageChanged(image: UIImage)
    }
    
    enum Mutation {
        case uploadImageResult(Result<Void, Error>)
    }
    
    struct State {
        var shouldNavigate = false
    }
    
    var nickname: String
    var imageName: String?
    
    var initialState = State()
    
    init(nickname: String, imageName: String? = nil, initialState: State = State()) {
        self.nickname = nickname
        self.imageName = imageName
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .imageChanged(let image):
            return registerProfileImage(image)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .uploadImageResult(let result):
            switch result {
            case .success:
                newState.shouldNavigate = true
            case .failure:
                newState.shouldNavigate = false
            }
        }
        return newState
    }
    
    /// 프로필 이미지 등록 루트 함수
    private func registerProfileImage(_ image: UIImage) -> Observable<Mutation> {
        print("\(type(of: self)) - \(#function)")

        return fetchPresignedURL()
            .flatMap { urlWithName -> Observable<Result<Void, Error>> in
                guard let url = URL(string: urlWithName.urlStr) else {
                    print("\(type(of: self)) - \(#function) url 없음")
                    return Observable.just(.failure(NSError(domain: "presignedURL 없음", code: 0, userInfo: nil)))
                }
                return self.uploadImage(image, to: url)
            }
            .map { result in
                Mutation.uploadImageResult(result)
            }
    }
    
    /// 프리사인 URL을 fetch
    private func fetchPresignedURL() -> Observable<(urlStr: String, imageName: String)> {
        print("\(type(of: self)) - \(#function)")

        let request: JoinRequest = .profileImagePresignedURL
        
        return NetworkManager.shared.request(PresignedStorageResponse.self, request: request)
            .map { response in
                self.imageName = response.imgName
                return (urlStr: response.url.href, imageName: response.imgName)
            }
    }
    
    /// 프리사인 URL로 이미지 업로드
    private func uploadImage(_ image: UIImage, to url: URL) -> Observable<Result<Void, Error>> {
        print("\(type(of: self)) - \(#function)")

        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return Observable.just(.failure(NSError(domain: "ImageConversionError", code: 0, userInfo: nil)))
        }
        
        return Observable.create { observer in
            AF.upload(imageData, to: url, method: .put)
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:
                        observer.onNext(.success(()))
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onNext(.failure(error))
                        observer.onCompleted()
                    }
                }
            return Disposables.create()
        }
    }
}
