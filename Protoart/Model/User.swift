//
//  User.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 12/9/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: String
    let username: String
    let name: String
    let firstName: String
    let lastName: String?
    let portfolioURL: String?
    let bio: String?
    let location: String?
    let links: [String: String]
    let profileImage: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case portfolioURL = "portfolio_url"
        case bio
        case location
        case links
        case profileImage = "profile_image"
    }
}
