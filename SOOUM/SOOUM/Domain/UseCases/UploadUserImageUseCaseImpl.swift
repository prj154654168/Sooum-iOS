//
//  UploadUserImageUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class UploadUserImageUseCaseImpl: UploadUserImageUseCase {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func presignedURL() -> Observable<ImageUrlInfo> {
        
        return self.repository.presignedURL().map(\.imageUrlInfo)
    }
    
    func uploadToS3(_ data: Data, with url: URL) -> Observable<Bool> {
        
        return self.repository.uploadImage(data, with: url).map { (try? $0.get()) == 200 }
    }
    
    func registerImageName(imageName: String) -> Observable<Bool> {
        
        return self.repository.updateImage(imageName: imageName).map { $0 == 200 }
    }
}
