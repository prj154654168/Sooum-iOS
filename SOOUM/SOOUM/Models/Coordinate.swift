//
//  Coordinate.swift
//  SOOUM
//
//  Created by 오현식 on 10/15/24.
//

import Foundation


struct Coordinate: Codable {
    let latitude: String
    let longitude: String
}

extension Coordinate {
    
    init() {
        self.latitude = ""
        self.longitude = ""
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try container.decode(String.self, forKey: .latitude)
        self.longitude = try container.decode(String.self, forKey: .longitude)
    }
}

extension Coordinate: Equatable {
    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
