//
//  APIImagesManager.swift
//  UnsplashDemo
//
//  Created by Prithvi Raj on 17/03/19.
//  Copyright © 2019 Prithvi Raj. All rights reserved.
//

import Foundation

enum ImagesType: FinalURLPoint {
    
    var baseURL: URL {
        return URL(string: "https://api.unsplash.com/search/photos")!
    }
    
    var path: String {
        switch self {
        case .Current(let apiKey, let quary, let pageNumber):
            return "?client_id=\(apiKey)&query=\(quary)&page=\(pageNumber)&per_page=20"
        }
    }
    
    var request: URLRequest {
        let url = URL(string: path, relativeTo: baseURL)
        if url == nil {
            return URLRequest(url: URL(fileURLWithPath: "https://api.unsplash.com/photos/?client_id=96a1c0fb0df4e13205530b5a607c742742d63ac89d0ba005960bd66035e6cf0b"))
        } else{
            return URLRequest(url: url!)
        }
    }
    case Current(apiKey: String, quary: String, pageNumber: Int)
}

final class APIImagesManager: APIManager {
    
    var sessionConfiguration: URLSessionConfiguration
    let apiKey: String
    
    //var sessionConfiguration: URLSessionConfiguration
    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration)
    }()
    
    init(sessionConfiguration: URLSessionConfiguration, apiKey: String) {
        self.sessionConfiguration = sessionConfiguration
        self.apiKey = apiKey
    }
    
    convenience init(apiKey: String) {
        self.init(sessionConfiguration: URLSessionConfiguration.default, apiKey: apiKey)
    }
    
    func featchCurrent(quary: String, pageNumber: Int, completionHandler: @escaping (APIResult<BaseModel>) -> Void) {
        
        let request = ImagesType.Current(apiKey: self.apiKey, quary: quary, pageNumber: pageNumber).request
        print(request)
        fetch(request: request, parse: { (json) -> Array<Any>?  in
            
            print(URLResponse.self)
            if let dictionaryData = json["results"] as? [Dictionary<String, AnyObject>] {
                var arrayImages:[BaseModel] = []
                for imageDictionary in dictionaryData {
                    let someImageDict = BaseModel(JSON: imageDictionary)
                    arrayImages.append(someImageDict!)
                }
                return arrayImages
            } else {
                return nil
            }
        }, completionHandler: completionHandler)
        print(BaseModel.self)
    }
}
