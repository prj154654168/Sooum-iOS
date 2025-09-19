//
//  BaseAssembler.swift
//  SOOUM
//
//  Created by 오현식 on 9/17/25.
//

import Foundation

/// 여러 의존성 등록 로직을 한 곳에 모아 관리하는 책임을 가집니다.
protocol BaseAssemblerable: AnyObject {
    /// 추가 의존성을 `rootContainer`에 등록합니다.
    ///  - Parameter container: 의존성을 등록 혹은 반환합니다.
    ///
    ///  ```
    ///  DataSource: container.register(AnyDataSource.self) { _ in
    ///     AnyDataSourceImpl()
    ///  }
    ///  Repository: container.register(AnyRespository.self) { resolver in
    ///     AnyRespositoryImpl(resolver.resolve(AnyDataSource.self))
    ///  }
    ///  UseCase: container.register(AnyUseCase.self) { resolver in
    ///     AnyUseCaseImpl(resolver.resolve(AnyRespository.self))
    ///  }
    ///  Reactor: container.register(AnyReactor.self) { resolver in
    ///     AnyReactor(resolver.resolve(AnyUseCase.self))
    ///  }
    ///  ```
    func assemble(container: BaseDIContainerable)
}
