//
//  NativeAdHelper.swift
//  SOOUM
//
//  Created by 오현식 on 3/29/26.
//

import GoogleMobileAds

final class NativeAdHelper: NSObject {
    
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
    private var pendingLoaders: [AdLoader] = []
    
    private weak var rootViewController: UIViewController?
    
    private let adQueue = DispatchQueue(label: "com.app.nativeAdHelper", attributes: .concurrent)
    
    private var adUnitID: String {
        return Info.adUnitId
    }
    
    var onAdLoaded: ((NativeAd) -> Void)?
    var onAdFailed: ((Error) -> Void)?
    
    func configure(root rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    func loadAd() {
        guard let rootViewController = self.rootViewController ?? UIApplication.topViewController else {
            Log.error("Can not find rootViewController")
            return
        }
        let adLoader = AdLoader(
            adUnitID: self.adUnitID,
            rootViewController: rootViewController,
            adTypes: [.native],
            options: nil
        )
        adLoader.delegate = self
        self.adQueue.async(flags: .barrier) {
            self.pendingLoaders.append(adLoader)
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
            self.pendingLoaders.removeAll()
        }
    }
    
    @objc
    private func handleAppDidBackground() {
        self.adQueue.async(flags: .barrier) {
            self.pendingLoaders.removeAll()
        }
    }
}

extension NativeAdHelper: NativeAdLoaderDelegate {
    
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        nativeAd.delegate = self
        let wrapper = NativeAdWrapper(ad: nativeAd, loadedAt: Date())
        self.adQueue.async(flags: .barrier) {
            self.loadedAds.append(wrapper)
        }
    }
    
    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        self.adQueue.async(flags: .barrier) {
            self.pendingLoaders.removeAll(where: { $0 == adLoader })
        }
        
        self.adQueue.async {
            if let wrapper = self.loadedAds.last {
                DispatchQueue.main.async { [weak self] in
                    self?.onAdLoaded?(wrapper.ad)
                }
            }
        }
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        self.adQueue.async(flags: .barrier) {
            self.pendingLoaders.removeAll(where: { $0 == adLoader })
        }
        
        DispatchQueue.main.async {
            self.onAdFailed?(error)
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
