//
//  BaseModel.swift
//  UnsplashDemo
//
//  Created by Prithvi Raj on 17/03/19.
//  Copyright © 2019 Prithvi Raj. All rights reserved.
//

import Foundation

struct BaseModel {
    let userName: String
    let urls: [String: AnyObject]
    let description: String
    let user: [String: AnyObject]
    let smallURL: String
    let fullURL: String
}

extension BaseModel: JSONDecodable {
    init?(JSON: Dictionary<String, AnyObject>) {
        description = JSON["description"] as? String ?? ""
        urls = JSON["urls"] as? [String: AnyObject] ?? [:]
        user = JSON["user"] as? [String: AnyObject] ?? [:]
        userName = user["name"] as? String ?? ""
        smallURL = urls["small"] as? String ?? ""
        fullURL = urls["full"] as? String ?? ""
    }
}
