//
//  Photo.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 12/10/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id: String
    let width: Int
    let height: Int
    let color: String
    let description: String?
    let altDescription: String?
    let urls: [String: String]
    let links: [String: String]
    let categories: [String]
    let user: User
    //let sponsorship: Sponsorship
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case color
        case description
        case altDescription = "alt_description"
        case urls
        case links
        case categories
        case user
    }
}
