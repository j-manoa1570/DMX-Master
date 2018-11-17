//
//  DMX.swift
//  DMX Master
//
//  Created by Jonathan Manoa on 11/17/18.
//  Copyright © 2018 ComboBreaker. All rights reserved.
//

import Foundation
let CHANNELS: Int = 128;
class DMX {
    
    // Variables for all channels
    private var channels: [Int] = [CHANNELS]
    private var blackout: [Int] = [CHANNELS]
    
    init() {
        for i in 0...CHANNELS {
            channels[i] = 0
            blackout[i] = 0
        }
    }
    
    
    
}
