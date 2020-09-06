//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public struct Location: Codable, Hashable {
    public let woeId: Int64
    public let title: String
    public let latitude: Float
    public let longitude: Float
}
