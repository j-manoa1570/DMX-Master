//
//  ViewController.swift
//  DMX Master
//
//  Created by Jonathan Manoa on 11/16/18.
//  Copyright © 2018 ComboBreaker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy private var DMXController = DMX()
    
    // Collections for scenes, channel values, channel sliders
    @IBOutlet var channelValuesCollection: [UILabel]!
    @IBOutlet var scceneSelection: [UIButton]!
    @IBOutlet var channelSlidersCollection: [UISlider]!
    @IBOutlet var channelSelectCollection: [UIButton]!
    @IBOutlet var channelLabelsCollection: [UILabel]!
    
    // individual elements
    @IBOutlet weak var blackoutSelection: UIButton!
    @IBOutlet weak var saveButtonOnOff: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Slider Rotation, set slider values to current value, set background to
        // green for default channel selection(1-16), and label sliders with channels.
        for i in channelSlidersCollection.indices {
            channelSlidersCollection[i].transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            channelValuesCollection[i].text = String(Int(channelSlidersCollection[i].value))
            channelLabelsCollection[i].text = String(i + 1)
        }
        channelSelectCollection[0].backgroundColor = #colorLiteral(red: 0.1668410003, green: 0.6179428697, blue: 0, alpha: 1)
    }
 
    // Manages blackout button. When selected, calls DMX class methods for Blackout and updates UI.
    @IBAction func blackoutChannelsbutton(_ sender: UIButton) {
        DMXController.setBlackoutStatus()
        DMXController.changeBlackOutStatus()
        let channelGroup = DMXController.getChannelSet()
        var channelNumber = (channelGroup * 16) + 1
        for i in 0...15 {
            channelSlidersCollection[i].setValue(Float(DMXController.getChannelValue(channelToSet: channelNumber)), animated: false)
            channelValuesCollection[i].text = String(Int(channelSlidersCollection[i].value))
            channelNumber += 1
        }
        blackoutSelection.backgroundColor = DMXController.getBlackoutStatus() ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    
    // Displays the current slider value.
    @IBAction func sliderValueUpdate(_ sender: UISlider) {
        let channelGroup = DMXController.getChannelSet()
        if let sliderChannel = channelSlidersCollection.firstIndex(of: sender) {
            channelValuesCollection[sliderChannel].text = String(Int(channelSlidersCollection[sliderChannel].value))
            DMXController.channelValueSet(channelIndex: ((channelGroup * 16) + (sliderChannel + 1)), channelValue: Int(channelSlidersCollection[sliderChannel].value))
        }
    }
    
    // Channel group selection. Updates color of button and slider label.
    @IBAction func channelLabelChange(_ sender: UIButton) {
        if let channelLabel = channelSelectCollection.firstIndex(of:sender) {
            DMXController.setNewChannelSet(CollectionIndexValue: channelLabel)
            var numberForLabel = (channelLabel * 16) + 1
            for i in 0...15 {
                channelSlidersCollection[i].setValue(Float(DMXController.getChannelValue(channelToSet: numberForLabel)), animated: false)
                channelValuesCollection[i].text = String(Int(channelSlidersCollection[i].value))
                channelLabelsCollection[i].text = String(numberForLabel)
                numberForLabel += 1
            }
            for i in channelSelectCollection.indices {
                channelSelectCollection[i].backgroundColor = (i == channelLabel) ? #colorLiteral(red: 0.1668410003, green: 0.6179428697, blue: 0, alpha: 1) : #colorLiteral(red: 0.8823529412, green: 0.1960784314, blue: 0.1607843137, alpha: 1)
            }
        }
    }
    
    // TODO: Scenes
    @IBAction func saveOnOffButton(_ sender: UIButton) {
        DMXController.setSaveStatus()
        saveButtonOnOff.backgroundColor = DMXController.getSaveStatus() ? #colorLiteral(red: 0.1668410003, green: 0.6179428697, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
    @IBAction func sceneSelect(_ sender: UIButton) {
        let scene = scceneSelection.firstIndex(of: sender)
        if DMXController.getSaveStatus() {
            DMXController.setSaveStatus()
            DMXController.updateScene(index: scene!)
            saveButtonOnOff.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            scceneSelection[scene!].backgroundColor = #colorLiteral(red: 1, green: 0.6238600496, blue: 0, alpha: 1)
        } else {
            var values: [Int] = DMXController.getSceneChannelValues(sceneID: scene!)
            for i in 0..<129 {
                DMXController.channelValueSet(channelIndex: i, channelValue: values[i])
            }
            for i in scceneSelection.indices {
                if i == scene! {
                    if DMXController.sceneSet(index: i) {
                        DMXController.copyChannels(index: i)
                        var label = (DMXController.getChannelSet() * 16) + 1
                        for i in 0..<channelSlidersCollection.count {
                            channelSlidersCollection[i].setValue(Float(DMXController.getChannelValue(channelToSet: (label))), animated: false)
                            channelValuesCollection[i].text = String(Int(channelSlidersCollection[i].value))
                            channelLabelsCollection[i].text = String(label)
                            label += 1
                        }
                    }
                    scceneSelection[i].backgroundColor = #colorLiteral(red: 0.1668410003, green: 0.6179428697, blue: 0, alpha: 1)
                    
                } else {
                    scceneSelection[i].backgroundColor = DMXController.sceneSet(index: i) ? #colorLiteral(red: 1, green: 0.6238600496, blue: 0, alpha: 1) : #colorLiteral(red: 0.8823529412, green: 0.1960784314, blue: 0.1607843137, alpha: 1)
                }
            }
        }
    }
}

