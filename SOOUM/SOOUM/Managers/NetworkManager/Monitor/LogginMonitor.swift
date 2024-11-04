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
            print("\n--------------------------------")
            print("📡 REQUEST [\(currentTime)]")
            print("URL: \(request.url?.absoluteString ?? "")")
            print("Method: \(request.httpMethod ?? "")")
            
            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                print("Headers: \(headers)")
            }
            
            if let body = request.httpBody,
               let jsonString = String(data: body, encoding: .utf8) {
                print("Body: \(prettyPrintJSON(jsonString))")
            }
        }
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        let currentTime = formatter.string(from: Date())
        print("\n📡 RESPONSE [\(currentTime)]")
        
        if let statusCode = response.response?.statusCode {
            print("Status Code: \(statusCode)")
        }
        
        if let data = response.data {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response: \(prettyPrintJSON(jsonString))")
            }
        }
        
        if let error = response.error {
            print("Error: \(error.localizedDescription)")
        }
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
