import AppsFlyerLib
import Combine
import AppTrackingTransparency

public final class GDAppsFlyer {
    
    private let appsFlyerDelegate = AppsFlyerDelegate()
    private let appsFlyerDeepLinkDelegate = AppsFlyerDeepLinkDelegate()
    private let parseAppsFlyerData = ParseAppsFlyerData()
    
    public var urlParameters: ((String?) -> Void)?
    public var installCompletion = PassthroughSubject<Install, Never>()
    public var completionDeepLinkResult: ((DeepLinkResult) -> Void)?
    
    public func setup(appID: String, devKey: String, interval: Double = 120){
        self.setup()
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: interval)
        AppsFlyerLib.shared().appsFlyerDevKey     = devKey
        AppsFlyerLib.shared().appleAppID          = appID
        AppsFlyerLib.shared().delegate            = self.appsFlyerDelegate
        AppsFlyerLib.shared().deepLinkDelegate    = self.appsFlyerDeepLinkDelegate
        AppsFlyerLib.shared().isDebug             = true
        AppsFlyerLib.shared().useUninstallSandbox = true
        AppsFlyerLib.shared().minTimeBetweenSessions = 10
        AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
            if (error != nil){
                print(error ?? "")
                return
            } else {
                print(dictionary ?? "")
                return
            }
        })
    }
    
    public func setDebag(isDebug: Bool){
        AppsFlyerLib.shared().isDebug = isDebug
    }
    
    public func startRequestTrackingAuthorization(){
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        AppsFlyerLib.shared().start()
        requestTrackingAuthorization()
    }
    
    private func requestTrackingAuthorization() {
        self.setup()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] (status) in
                guard let self = self else { return }
                switch status {
                    case .denied:
                        print("AuthorizationSatus is denied")
                        
                        self.installCompletion.send(.nonOrganic(""))
                        self.appsFlyerDelegate.installCompletion = nil
                    case .notDetermined:
                        print("AuthorizationSatus is notDetermined")
                        
                        self.installCompletion.send(.nonOrganic(""))
                        self.appsFlyerDelegate.installCompletion = nil
                    case .restricted:
                        print("AuthorizationSatus is restricted")
                        self.installCompletion.send(.nonOrganic(""))
                        self.appsFlyerDelegate.installCompletion = nil
                    case .authorized:
                        print("AuthorizationSatus is authorized")
                    @unknown default:
                        fatalError("Invalid authorization status")
                }
            }
        }
    }
    
    private func setup(){
        appsFlyerDeepLinkDelegate.completionDeepLinkResult = completionDeepLinkResult
        appsFlyerDelegate.installCompletion = { [weak self] install in
            guard let install = install else { return }
            guard let self = self else { return }
            self.installCompletion.send(install)
        }
        appsFlyerDelegate.urlParameters = urlParameters
    }

    public init(){}
}
//https://app.appsflyer.com/id1662068962?pid=conversionTest1&idfa=3E7D5A70-C304-4494-A12F-352A30E4BBB5

