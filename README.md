<div align="center">
  <img width="680" alt="sooum_title" src="https://github.com/user-attachments/assets/8c807798-2f9c-48d0-8327-436eb59ad082"/>
</div>

# About SOOUM
 - **숨**은 완전한 익명성을 보장하는 카드형 SNS 앱 서비스입니다. 사용자들이 자유롭게 생각을 공유할 수 있는 안전한 공간을 제공합니다.
 - 사용자의 개인정보 사용을 최소화하기 위해 하나의 기기당 하나의 계정을 발급하고, 계정을 위한 ID는 비대칭 키 암호화를 사용해 안전하게 사용합니다.
 - 사용자의 감정을 글과 함께 직접 찍은 사진 또는 숨에서 제공하는 기본 이미지로 표현할 수 있습니다.
 - 해시태그 검색을 통해 특정 키워드의 피드를 구경할 수 있습니다.
 - 다양한 사용자들을 팔로우하며 피드에 공감 혹은 답카드 작성으로 표현할 수 있습니다.

<div align="center">
  <a href="https://apps.apple.com/kr/app/%EC%88%A8-%EC%B9%B4%EB%93%9C%ED%98%95-%EC%9D%B5%EB%AA%85-sns/id6740403078">
    <img width="160" alt="Download on the App Store" src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/ko-kr?size=250x83"/>
  </a>
</div>

# Preview
<div align="center">
  <img width="5580" alt="Preview" src="https://github.com/user-attachments/assets/5b41aa70-8304-4e40-8bae-8ba674febbf6"/>
</div>

# Features
### 1. 네트워크 레이어

HTTP 네트워킹을 위한 Alamofire와 반응형 프로그래밍을 위한 RxSwift를 활용한 네트워킹 레이어를 포함하고 있습니다. 이 프로젝트에선 적절한 오류 처리, 요청 구성 및 환경별 엔드포인트를 갖춘 RESTful API 호출을 위한 깔끔한 프로토콜 지향 아키텍처를 제공합니다.

개발 환경과 운영 환경 간에 endpoint를 전처리문으로 전환합니다:
```
static var endpoint: String {
    #if DEVELOP
    return self.serverEndpoint(scheme: "http://")
    #elseif PRODUCTION
    return self.serverEndpoint(scheme: "https://")
    #endif
}
```

네트워크 요청 시 필요한 정보들을 프로토콜을 사용하여 확장 가능한 시스템을 만들었습니다:
```
protocol BaseRequest: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }
    var encoding: ParameterEncoding { get }

    ...
}
```

네트워크 요청에 대한 응답을 자동으로 디코딩하고 반응형 프로그래밍 패턴을 가능하게 하는 Observable 시퀀스를 반환합니다:
```
func request<T: Decodable>(_ object: T.Type, request: BaseRequest) -> Observable<T>
```

서버측과 함께 정의한 HTTP 상태 코드 매핑을 포함한 포괄적인 오류 처리:
```
enum DefinedError: Error, LocalizedError {
    case badRequest
    case unauthorized
    case payment
    case forbidden
    case teapot
    case locked
    case unknown(Int)

    ...
```
### 2. 테스트하기 쉬운 매니저

의존성 주입을 활용하여 매니저 객체들을 효율적으로 구성하고 테스트하기 쉬운 아키텍처를 구현했습니다. 이 접근 방식은 코드의 결합도를 낮추고, 단위 테스트를 용이하게 하며, 애플리케이션의 유지보수성을 크게 향상시킵니다.

여러 매니저들을 관리하는 **CompositeManager**를 통해 접근에 용이합니다:
```
class CompositeManager<C: ManagerConfiguration>: NSObject {
    weak var provider: ManagerTypeDelegate?
    var configure: C?
    
    init(provider: ManagerTypeDelegate, configure: C) {
        self.provider = provider
        self.configure = configure
    }
}
```
실제 매니저 인스턴스를 생성하고 구성하는 컨테이너와 lazy 키워드를 통해 실제 필요한 시점에만 인스턴스를 생성하도록 했습니다:
```
final class ManagerTypeContainer: ManagerTypeDelegate {
    lazy var authManager: AuthManagerDelegate = AuthManager(provider: self, configure: self.configuare.auth)
    lazy var pushManager: PushManagerDelegate = PushManager(provider: self, configure: self.configuare.push)
    lazy var networkManager: NetworkManagerDelegate = NetworkManager(provider: self, configure: self.configuare.network)
    lazy var locationManager: LocationManagerDelegate = LocationManager(provider: self, configure: self.configuare.location)

    ...

    let configuare: Configuration
    init() {
        self.configuare = .init()
    }
}
```
매니저 단위 테스트를 위해 목 객체를 사용해 매니저를 독립적으로 테스트할 수 있습니다:
```
final class MockManagerProviderContainer: ManagerProviderType {
    lazy var managerType: ManagerTypeDelegate = MockManagerProvider()
    
    var authManager: AuthManagerDelegate { self.managerType.authManager }
    var pushManager: PushManagerDelegate { self.managerType.pushManager }
    var networkManager: NetworkManagerDelegate { self.managerType.networkManager }
    var locationManager: LocationManagerDelegate { self.managerType.locationManager }
}
```

### 3. 단방향 데이터 흐름 아키텍처
단방향 데이터 흐름 아키텍처는 앞서 설명한 의존성 주입 기반 관리자 패턴과 결합하여 예측 가능하고 테스트하기 쉬운 코드베이스를 구축합니다.

ReactorKit의 가장 큰 특징은 데이터가 한 방향으로만 흐른다는 것입니다:
```
[사용자 인터랙션] → [Action] → [Mutation] → [State] → [View 업데이트] → [사용자 인터랙션] ...
```
이 흐름은 상태 변화를 예측 가능하게 만들고 디버깅을 용이하게 합니다.

ReactorKit은 View와 Reactor를 쉽게 바인딩할 수 있는 방법을 제공합니다:
```
class SomeViewController: UIViewController, View {
    var disposeBag = DisposeBag()

    let button = UIButton()

    func bind(reactor: SomeViewReactor) {
        button.rx.tap
            .map { _ in Reactor.Action.someAction }
            .bind(to: reactore.action)
            .disposed(by: disposeBag) 
    }
}
```
앞서 설명한 의존성 주입과 ReactorKit을 결합하여 강력한 아키텍처를 구현합니다:
```
class SomeViewReactor: Reactor {
    private let provider: ManagerProviderType
    
    init(provider: ManagerProviderType) {
        self.provider = provider
    }

    ...
    
    private func fetch() -> Observable<Mutation> {
        return self.provider.networkManager
            .request(SomeModel.self, request: .SomeRequest)
            .map { Mutation.setModel($0) }
            .catch { Observable.just(Mutation.setError($0)) }
    }
}
```

# 25.12.11 변경사항

### 4. 클린 아키텍처 도입
클린 아키텍처를 도입하기에 앞서 레파지토리 패턴을 도입해 데이터 접근 계층을 분리하고, 비즈니스 로직의 독립성을 보장합니다. 이 구조로 인해 테스트하기 쉬운 구조를 설계했습니다.

레파지토리 패턴의 핵심 구조는 구체적인 구현 방식에 의존하지 않도록 추상화하는 것입니다. 이 구조는 데이터 접근 변경하더라도 상위 계층의 코드 수정을 최소화하도록 보장합니다.

레파지토리의 프로토콜은 도메인 계층에 정의되어, 비즈니스 로직이 요구하는 데이터 접근 인터페이스를 정의합니다.
```
protocol AuthRepository {
    
    func signUp(nickname: String, profileImageName: String?) -> Observable<Bool>
    func login() -> Observable<Bool>
    func withdraw(reaseon: String) -> Observable<Int>

    ...
}
```

레파지토리의 구현체는 데이터 계증에서 구현하며, 하나 이상의 데이터 소스를 조합하여 데이터를 제공합니다.
```
class AuthRepositoryImpl: AuthRepository {
    
    private let remoteDataSource: AuthRemoteDataSource
    private let localDataSource: AuthLocalDataSource
    
    init(remoteDataSource: AuthRemoteDataSource, localDataSource: AuthLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func signUp(nickname: String, profileImageName: String?) -> Observable<Bool> {
        
        self.remoteDataSource.signUp(nickname: nickname, profileImageName: profileImageName)
    }
    
    func login() -> Observable<Bool> {
        
        self.remoteDataSource.login()
    }
    
    func withdraw(reaseon: String) -> Observable<Int> {
        
        self.remoteDataSource.withdraw(reaseon: reaseon)
    }

    ...
}
```

UseCase는 앱의 특정 기능을 캡슐화 합니다. ReactorKit에서 Reactor는 UseCase만 호출하며, 복잡한 비즈니스 로직을 UseCase에 위임하여 책임을 가볍게 만듭니다.
```
protocol FetchTagUseCase: AnyObject {
    
    ...

    func isFavorites(with tagInfo: FavoriteTagInfo) -> Observable<Bool>
    func ranked() -> Observable<[TagInfo]>
}

final class FetchTagUseCaseImpl: FetchTagUseCase {
    
    private let repository: TagRepository
    
    init(repository: TagRepository) {
        self.repository = repository
    }

    ...
    
    func isFavorites(with tagInfo: FavoriteTagInfo) -> Observable<Bool> {
        
        return self.favorites().map { $0.contains(tagInfo) }
    }
    
    // 인기 태그는 최소 1개 이상일 때 표시
    // 인기 태그는 최대 10개까지 표시
    func ranked() -> Observable<[TagInfo]> {
        
        return self.repository.ranked()
            .map(\.tagInfos)
            .map { $0.filter { $0.usageCnt > 0 } }
            // 중복 제거
            // .map { Array(Set($0)) }
            // 태그 갯수로 정렬
            // .map { $0.sorted(by: { $0.usageCnt > $1.usageCnt }) }
            .map { Array($0.prefix(10)) }
    }
}
```

비즈니스 로직에서 사용하는 모델과 데이터 통신을 위한 모델을 분리합니다.
 - 도메인 모델: 순수한 비즈니스 로직만 포함하며 데이터 소스 구현에 독립적입니다.
 - 데이터 모델: API 응답 구조 또는 로컬 DB 스키마에 맞게 정의합니다.

# 향후 개선할 사항
1. ReactorKit 기반 비즈니스 로직의 단위 테스트 추가
   
   현재 구현된 ReactorKit 아키텍처는 자연스럽게 테스트 가능한 구조를 제공하지만, 이를 체계적으로 활용한 단위 테스트가 아직 완전히 구현되지 않았습니다. 향후 개선 작업은 다음과 같은 방향으로 진행될 예정입니다:
   
      - 리액터의 상태 변화 검증: 각 Action에 따른 State 변화를 검증하는 테스트 케이스 구현
      - 액션-뮤테이션-상태 흐름 검증: 단방향 데이터 흐름의 각 단계가 올바르게 작동하는지 검증
      - 테스트 커버리지 확대: 모든 비즈니스 로직 컴포넌트에 대한 테스트 커버리지 80% 이상 달성
  
2. ~~클린 아키텍처의 레포지토리 패턴 적용~~

   ~~현재 프로젝트는 매니저들과 의존성 주입을 통해 관리하고 있지만, 데이터 접근 계층을 더욱 체계화하기 위해 클린 아키텍처의 레포지토리 패턴을 도입할 계획입니다:~~

     - ~~데이터 레이어 추상화: 데이터 소스(로컬 저장소, 원격 API 등)에 상관없이 일관된 인터페이스를 제공하는 레포지토리 계층 도입~~
     - ~~도메인 모델과 데이터 모델 분리: 비즈니스 로직에서 사용하는 도메인 모델과 데이터 저장/통신에 사용하는 데이터 모델을 명확히 분리~~
     - ~~UseCase 패턴 도입: 비즈니스 로직을 캡슐화하는 UseCase 클래스 구현으로 리액터의 책임을 더욱 가볍게 만듦~~
     - ~~데이터 소스 전략 패턴: 네트워크, 로컬 간의 전환을 자동화하는 전략 패턴 구현~~

# Tech Stacks
<div align="leading">
  <img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white" />&nbsp
  <img src="https://img.shields.io/badge/RxSwift-B7178C?style=for-the-badge&logo=ReactiveX&logoColor=white" />&nbsp
  <img src="https://img.shields.io/badge/ReactorKit-324FFF?style=for-the-badge&logo=React&logoColor=white" />&nbsp
  <img src="https://img.shields.io/badge/SwiftLint-FF4088?style=for-the-badge&logo=atandt&logoColor=white" />&nbsp
  <img src="https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white" />&nbsp
  <img src="https://img.shields.io/badge/Clarity-171C36?style=for-the-badge&logo=Vercel&logoColor=white" />&nbsp
  <img src="https://img.shields.io/badge/GIT-E44C30?style=for-the-badge&logo=git&logoColor=white" />&nbsp
</div>

# Environment
 - Xcode 16.0(16A242d)
 - iOS Deployment Target 15.0
 - Ccocoapods Version 1.16.2

# Members
|오현식|서정덕|
|:---:|:---:|
|[hyeonsik971029](https://github.com/hyeonsik971029)|[JDeoks](https://github.com/JDeoks)|
|[hyeonsik971029@gmail.com](mailto:hyeonsik971029@gmail.com)|[JDeoksDev@gmail.com](mailto:JDeoksDev@gmail.com)|
