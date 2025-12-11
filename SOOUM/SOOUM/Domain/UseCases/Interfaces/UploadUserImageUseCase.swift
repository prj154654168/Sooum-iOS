//
//  UploadUserImageUseCase.swift
//  SOOUM
//
//  Created by 오현식 on 12/2/25.
//

import RxSwift

protocol UploadUserImageUseCase: AnyObject {
    
    func presignedURL() -> Observable<ImageUrlInfo>
    func uploadToS3(_ data: Data, with url: URL) -> Observable<Bool>
    func registerImageName(imageName: String) -> Observable<Bool>
}
