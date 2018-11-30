//
//  scene.swift
//  DMX Master
//
//  Created by Jonathan Manoa on 11/17/18.
//  Copyright © 2018 ComboBreaker. All rights reserved.
//

import Foundation

// Structure for the scene buttons so they can be used individually
class Scene {
    private var channels: [Int] = []
    private var isSet = false
    private var identifier: Int
    
    init(id: Int, channelValues: [Int]) {
        self.identifier = id
        isSet = true
        for i in 0..<channelValues.count {
            channels.append(channelValues[i])
        }
    }
    
    // GETCHANNELVALUES()
    // Returns the channel values
    func getChannelValues() -> [Int] {
        return channels
    }
}
