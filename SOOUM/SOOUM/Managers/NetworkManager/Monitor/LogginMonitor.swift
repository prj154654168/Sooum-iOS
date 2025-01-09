//
//  LogginMonitor.swift
//  SOOUM
//
//  Created by 오현식 on 11/4/24.
//

import Foundation

import Alamofire


class LogginMonitor: EventMonitor {
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    let queue: DispatchQueue = .init(label: "LogginMonitor")
    
    func requestDidFinish(_ request: Request) {
        
        if let request = request.request {
            
            let currentTime = formatter.string(from: Date())
            Log.debug("""
                \nREQUEST [\(currentTime)]
            URL: \(request.url?.absoluteString ?? "")
            Method: \(request.httpMethod ?? "")
            Headers: \(request.allHTTPHeaderFields ?? [:])
            Body: \(prettyPrintJSON(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""))
            """)
        }
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        
        let currentTime = formatter.string(from: Date())
        Log.debug("""
            \nRESPONSE [\(currentTime)]
        Status Code: \(response.response?.statusCode ?? -99)
        Response: \(prettyPrintJSON(String(data: response.data ?? Data(), encoding: .utf8) ?? ""))
        Error: \(response.error?.localizedDescription ?? "")
        """)
    }
    
    private func prettyPrintJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
}
