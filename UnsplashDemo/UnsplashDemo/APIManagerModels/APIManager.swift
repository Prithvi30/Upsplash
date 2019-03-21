//
//  APIManager.swift
//  UnsplashDemo
//
//  Created by Prithvi Raj on 17/03/19.
//  Copyright © 2019 Prithvi Raj. All rights reserved.
//

import Foundation

typealias JSONCompletionHandler = ([String: AnyObject]?, URLResponse?, Error?) -> Void
typealias JSONTask = URLSessionDataTask

enum APIResult<T> {
    case Seccess(Array<Any>?)
    case Failure(Error)
}

protocol FinalURLPoint {
    var baseURL: URL {get}
    var path: String {get}
    var request: URLRequest {get}
}

protocol JSONDecodable {
    init?(JSON: Dictionary<String, AnyObject>)
}

protocol APIManager {
    var sessionConfiguration: URLSessionConfiguration {get}
    var session: URLSession {get}
    
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHandler) -> JSONTask
    
    func fetch<T>(request: URLRequest, parse: @escaping ([String: AnyObject]) -> Array<Any>?, completionHandler: @escaping(APIResult<T>) -> Void)
}

extension APIManager {
    
    func JSONTaskWith(request: URLRequest, completionHandler: @escaping JSONCompletionHandler) -> JSONTask {
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            guard let HTTPResponse = response as? HTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")]
                let error = NSError(domain: "VITUnsplashAPP", code: 100, userInfo: userInfo)
                completionHandler(nil, nil, error)
                return
            }
            if data == nil {
                if let error = error {
                    completionHandler(nil, HTTPResponse, error)
                }
            } else {
                switch HTTPResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        completionHandler(json, HTTPResponse, nil)
                    } catch let error as NSError {
                        completionHandler(nil, HTTPResponse, error)
                    }
                default:
                    print("we have got response status: \(HTTPResponse.statusCode)")
                }
            }
        }
        return dataTask
    }
    
    func fetch<T>(request: URLRequest, parse: @escaping ([String: AnyObject]) -> Array<Any>?, completionHandler: @escaping(APIResult<T>) -> Void) {
        
        let task = JSONTaskWith(request: request) { (json, response, error) in
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completionHandler(.Failure(error))
                    }
                    return
                }
                if let value = parse(json) {
                    completionHandler(.Seccess(value))
                } else {
                    let error = NSError(domain: "VITUnsplashAPP", code: 200, userInfo: nil)
                    completionHandler(.Failure(error))
                }
            }
        }
        task.resume()
    }
}
