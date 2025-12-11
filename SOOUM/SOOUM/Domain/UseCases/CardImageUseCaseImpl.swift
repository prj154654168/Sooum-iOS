//
//  CardImageUseCaseImpl.swift
//  SOOUM
//
//  Created by 오현식 on 12/3/25.
//

import RxSwift

final class CardImageUseCaseImpl: CardImageUseCase {
    
    private let repository: CardRepository
    
    init(repository: CardRepository) {
        self.repository = repository
    }
    
    func defaultImages() -> Observable<DefaultImages> {
        
        return self.repository.defaultImages().map { $0.defaultImages }
    }
    
    func presignedURL() -> Observable<ImageUrlInfo> {
        
        return self.repository.presignedURL().map(\.imageUrlInfo)
    }
    
    func uploadToS3(_ data: Data, with url: URL) -> Observable<Bool> {
        
        return self.repository.uploadImage(data, with: url).map { (try? $0.get()) == 200 }
    }
}
