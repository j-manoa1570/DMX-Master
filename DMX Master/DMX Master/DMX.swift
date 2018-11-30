//
//  DMX.swift
//  DMX Master
//
//  Created by Jonathan Manoa on 11/17/18.
//  Copyright © 2018 ComboBreaker. All rights reserved.
//

import Foundation
let CHANNELS: Int = 129;
class DMX {
    
    // Variables for all channels
    private var channels = Array(repeating: 0, count: CHANNELS)
    private var blackout = Array(repeating: 0, count: CHANNELS)
    private var blackoutOn: Bool = false
    private var saveOn: Bool = false
    private var channelSet: Int = 0
    private var numberOfScenes: Int = 0
    private var currentlyUsedScenes: [Scene] = []
    
    // MAKESCENE()
    // Creates a new scene
    func makeScene(sceneID: Int) {
        let newScene = Scene(id: sceneID, channelValues: channels)
        currentlyUsedScenes.append(newScene)
        numberOfScenes += 1
    }
    
    // CHANGEBLACKOUTSTATUS()
    // When the blackout button is pressed, all channels will given
    // a value of 0 or revert to what they were before
    func changeBlackOutStatus() {
        if blackoutOn {
            for i in 0..<CHANNELS {
                blackout[i] = channels[i]
                channels[i] = 0
            }
        } else {
            for i in 0..<CHANNELS {
                channels[i] = blackout[i]
            }
        }
    }
    
    // CHANNELVALUESET()
    // sets the given channel to the given value
    func channelValueSet(channelIndex: Int, channelValue: Int) {
        channels[channelIndex] = channelValue
    }
    
    // SETNEWCHANNELSET()
    // Updates what channel group we are set to
    func setNewChannelSet(CollectionIndexValue: Int) {
        channelSet = CollectionIndexValue
    }
    
    // SETBLACKOUTSTATUS()
    // Sets the new blackout status
    func setBlackoutStatus() {
        blackoutOn = !blackoutOn
    }
    
    // SETSAVESTATUS()
    // Sets the new save status
    func setSaveStatus() {
        saveOn = !saveOn
    }
    
    // GETCHANNELVALUE()
    // The second half to channelValueSet(), returns the
    // channel value
    func getChannelValue(channelToSet: Int) -> Int {
        return channels[channelToSet]
    }
    
    // GETCHANNELSET()
    // Returns what channel set the user is on
    func getChannelSet() -> Int {
        return channelSet
    }
    
    // GETBLACKOUTSTATUS()
    func getBlackoutStatus() -> Bool {
        return blackoutOn
    }
    
    // GETSAVESTATUS()
    // Returns save status button
    func getSaveStatus() -> Bool {
        return saveOn
    }
    
    // GETSCENECHANNELVALUES()
    // Returns the values that the scene was storing
    func getSceneChannelValues(sceneID: Int) -> [Int] {
        return currentlyUsedScenes[sceneID].getChannelValues()
    }
}
