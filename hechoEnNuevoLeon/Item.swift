//
//  Item.swift
//  hechoEnNuevoLeon
//
//  Created by Alan Joel Cruz Ortega on 28/03/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
