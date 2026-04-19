//
//  LogginMonitor.swift
//  SOOUM
//
//  Created by 오현식 on 11/4/24.
//

import Alamofire

final class LogginMonitor: EventMonitor {
    
    private enum Constants {
        /// Slow request threshold
        static let slowRequestThreshold: TimeInterval = 2.0
    }
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private struct RequestState {
        var startedAt: Date
        var slowNotified: Bool
        var slowWorkItem: DispatchWorkItem?
    }
    
    private var requestStates: [String: RequestState] = [:]
    
    let queue: DispatchQueue = .init(label: "LogginMonitor")
    
    func requestDidResume(_ request: Request) {
        let requestId = String(describing: request.id)
        
        let slowWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard var state = self.requestStates[requestId], state.slowNotified == false else { return }
            
            state.slowNotified = true
            self.requestStates[requestId] = state
            
            let elapsed = Date().timeIntervalSince(state.startedAt)
            let elapsedMs = Int((elapsed * 1000).rounded())
            let statusCode = request.response?.statusCode ?? -99
            let url = request.request?.url?.absoluteString ?? ""
            let method = request.request?.httpMethod ?? ""
            
            Log.warning("""
                \nSLOW REQUEST DETECTED
            Elapsed: \(elapsedMs)ms
            Threshold: \(Int(Constants.slowRequestThreshold * 1000))ms
            URL: \(url)
            Method: \(method)
            Status Code: \(statusCode)
            """)
            
            NotificationCenter.default.post(
                name: .detectedSlowNetworkRequest,
                object: nil,
                userInfo: ["requestId": requestId]
            )
        }
        
        self.requestStates[requestId] = RequestState(
            startedAt: Date(),
            slowNotified: false,
            slowWorkItem: slowWorkItem
        )
        
        self.queue.asyncAfter(deadline: .now() + Constants.slowRequestThreshold, execute: slowWorkItem)
    }
    
    func requestDidFinish(_ request: Request) {
        let requestId = String(describing: request.id)
        var state = self.requestStates[requestId]
        self.requestStates.removeValue(forKey: requestId)
        state?.slowWorkItem?.cancel()
        
        let elapsed: TimeInterval? = {
            if let startedAt = state?.startedAt {
                return Date().timeIntervalSince(startedAt)
            }
            
            if let metrics = request.metrics {
                return metrics.taskInterval.duration
            }
            
            return nil
        }()
        
        let elapsedMs = Int(((elapsed ?? 0) * 1000).rounded())
        let errorDescription = request.error?.localizedDescription ?? "Nil"
        
        if let request = request.request {
            
            let currentTime = formatter.string(from: Date())
            Log.debug("""
                \nREQUEST [\(currentTime)]
            Elapsed: \(elapsedMs)ms
            URL: \(request.url?.absoluteString ?? "")
            Method: \(request.httpMethod ?? "")
            Headers: \(request.allHTTPHeaderFields ?? [:])
            Body: \(prettyPrintJSON(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""))
            Error: \(errorDescription)
            """)
        }
        
        NotificationCenter.default.post(
            name: .didFinishNetworkRequest,
            object: nil,
            userInfo: ["requestId": requestId]
        )
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
