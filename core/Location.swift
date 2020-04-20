//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public struct Location: Codable, Hashable {
    let woeId: Int64
    let title: String
    let latitude: Float
    let longitude: Float
}