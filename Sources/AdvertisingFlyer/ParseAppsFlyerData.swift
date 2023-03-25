//
//  ParseAppsFlyerData.swift
//  
//
//  Created by Developer on 25.07.2022.
//
import Foundation

final class ParseAppsFlyerData {
    
    var urlParameters: ((String?) -> Void)?
    var installCompletion: ((Install?) -> Void)?
    
    func parseCampaign(_ conversionInfo: [AnyHashable : Any]) {
        switch afStatus(conversionInfo: conversionInfo) {
            case .none:
                installCompletion?(nil)
            case .organic:
                installCompletion?(.organic)
            case .nonOrganic:
                let parameters = self.createParameters(conversionInfo: conversionInfo)
                installCompletion?(.nonOrganic(parameters))
        }
    }
    
    private func afStatus(conversionInfo: [AnyHashable : Any]) -> AfStatus {
        guard let afStatus = conversionInfo["af_status"] as? String else { return .none }
        guard let status = AfStatus(rawValue: afStatus) else { return .none }
        return status
    }
    
    private func createParameters(conversionInfo: [AnyHashable : Any]) -> String {
        let resultArray = conversionInfo.compactMap({ key, value in
            if let key = key as? String, let value = value as? String, let keyCreate = Key(rawValue: key) {
                let keyParameter = getAnalog(key: keyCreate)
                let valueParameter = value
                return keyParameter + "+" + valueParameter
            } else {
                return nil
            }
        })
        let parameters = resultArray.joined(separator: "&")
        return parameters
    }
    
    private func getAnalog(key: Key) -> String {
        switch key {
            case .pid:
                return Analog.utmSource.rawValue
            case .af_channel:
                return Analog.utmMedium.rawValue
            case .c:
                return Analog.utmCampaign.rawValue
            case .af_adset:
                return Analog.utmContent.rawValue
            case .af_ad:
                return Analog.utmTerm.rawValue
        }
    }
    
    init(){}
}

public enum Install {
    case organic
    case nonOrganic(String)
}

public enum AfStatus: String {
    case organic = "Organic"
    case nonOrganic = "Non-organic"
    case none
}

public enum Key: String {
    case pid
    case af_channel
    case c
    case af_adset
    case af_ad
}

public enum Analog: String {
    case utmSource = "utm_source"
    case utmMedium = "utm_medium"
    case utmCampaign = "utm_campaign"
    case utmContent = "utm_content"
    case utmTerm = "utm_term"
}
