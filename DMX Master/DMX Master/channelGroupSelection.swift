//
//  channelGroupSelection.swift
//  DMX Master
//
//  Created by Jonathan Manoa on 11/17/18.
//  Copyright © 2018 ComboBreaker. All rights reserved.
//

import Foundation

// Structure for the scene buttons so they can be used individually
struct ChannelSelection {
    private var chosen = false
    private var identifier: Int
    private static var identifierFactory = 0
    private static func getUniqueIdentifier() -> Int {
        ChannelSelection.identifierFactory += 1
        return identifierFactory
    }
    init() {
        self.identifier = ChannelSelection.getUniqueIdentifier()
    }
    mutating func setChosenStatus() {
        chosen = !chosen
    }
}
