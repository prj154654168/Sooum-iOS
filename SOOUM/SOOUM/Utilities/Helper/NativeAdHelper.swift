//
//  NativeAdHelper.swift
//  SOOUM
//
//  Created by 오현식 on 3/29/26.
//

import GoogleMobileAds

final class NativeAdHelper: NSObject {
    
    typealias LoadCompletion = (Result<NativeAd, Error>) -> Void
    
    static let shared = NativeAdHelper()
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private struct NativeAdWrapper {
        let ad: NativeAd
        let loadedAt: Date

        var isExpired: Bool {
            return Date().timeIntervalSince(self.loadedAt) > 3600
        }
    }
    
    private var loadedAds: [NativeAdWrapper] = []
    private var pendingRequests: [PendingRequest] = []
    
    private weak var rootViewController: UIViewController?
    
    private let adQueue = DispatchQueue(label: "com.app.nativeAdHelper", attributes: .concurrent)
    
    private var adUnitID: String {
        return Info.adUnitId
    }
    
    private final class PendingRequest {
        let loader: AdLoader
        let completion: LoadCompletion?
        var loadedAd: NativeAd?
        
        init(loader: AdLoader, completion: LoadCompletion?) {
            self.loader = loader
            self.completion = completion
        }
    }
    
    func configure(root rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    func loadAd(completion: LoadCompletion? = nil) {
        guard let rootViewController = self.rootViewController ?? UIApplication.topViewController else {
            Log.error("Can not find rootViewController")
            let error = NSError(
                domain: "com.sooum.nativeAdHelper",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Can not find rootViewController"]
            )
            completion?(.failure(error))
            return
        }
        
        self.loadAd(from: rootViewController, completion: completion)
    }
    
    func loadAd(from rootViewController: UIViewController, completion: LoadCompletion? = nil) {
        let adLoader = AdLoader(
            adUnitID: self.adUnitID,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: nil
        )
        adLoader.delegate = self
        
        let pendingRequest = PendingRequest(loader: adLoader, completion: completion)
        self.adQueue.async(flags: .barrier) {
            self.pendingRequests.append(pendingRequest)
        }
        
        adLoader.load(Request())
    }
    
    func dequeueAd() -> NativeAd? {
        self.adQueue.sync {
            self.loadedAds.removeAll(where: { $0.isExpired })
            guard self.loadedAds.isEmpty == false else { return nil }
            let wrapper = self.loadedAds.removeFirst()
            return wrapper.ad
        }
    }
    
    func reset() {
        self.adQueue.async(flags: .barrier) {
            self.loadedAds.removeAll()
            self.pendingRequests.removeAll()
        }
    }
    
    @objc
    private func handleAppDidBackground() {
        self.adQueue.async(flags: .barrier) {
            self.pendingRequests.removeAll()
        }
    }
}

extension NativeAdHelper: NativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.delegate = self
        let wrapper = NativeAdWrapper(ad: nativeAd, loadedAt: Date())
        self.adQueue.async(flags: .barrier) {
            self.loadedAds.append(wrapper)
            self.pendingRequests.first(where: { $0.loader == adLoader })?.loadedAd = nativeAd
        }
    }
    
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        self.adQueue.async(flags: .barrier) {
            guard let index = self.pendingRequests.firstIndex(where: { $0.loader == adLoader }) else { return }
            
            let request = self.pendingRequests.remove(at: index)
            guard let loadedAd = request.loadedAd else { return }
            
            DispatchQueue.main.async {
                request.completion?(.success(loadedAd))
            }
        }
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        self.adQueue.async(flags: .barrier) {
            guard let index = self.pendingRequests.firstIndex(where: { $0.loader == adLoader }) else { return }
            
            let request = self.pendingRequests.remove(at: index)
            DispatchQueue.main.async {
                request.completion?(.failure(error))
            }
        }
    }
}

extension NativeAdHelper: NativeAdDelegate {
    
    func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        Log.info("""
                Native ad exposure:
        icon: \(String(describing: nativeAd.icon?.imageURL))
        headline: \(nativeAd.headline ?? "None")
        body: \(nativeAd.body ?? "None")
        """)
    }
    
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        Log.info("Native ad clicked.")
    }
}
