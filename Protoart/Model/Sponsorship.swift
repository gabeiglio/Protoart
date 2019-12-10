//
//  Sponsorship.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 12/10/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import Foundation

class Sponsorship: Codable {
    let impressionURL: [String] //impression_url
    let impressionsId: String //impressions_id
    let tagline: String
    let sponsor: User
}
