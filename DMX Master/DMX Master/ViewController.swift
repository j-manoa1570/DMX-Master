//
//  ViewController.swift
//  DMX Master
//
//  Created by Jonathan Manoa on 11/16/18.
//  Copyright © 2018 ComboBreaker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    
    // Displays the current slider value.
    @IBAction func sliderValueUpdate(_ sender: UISlider) {
        if let sliderChannel = channelSlidersCollection.firstIndex(of: sender) {
            channelValuesCollection[sliderChannel].text = String(Int(channelSlidersCollection[sliderChannel].value))
        }
    }
    
    // Channel group selection. Updates color of button and slider label.
    @IBAction func channelLabelChange(_ sender: UIButton) {
        if let channelLabel = channelSelectCollection.firstIndex(of:sender) {
            var numberForLabel = (channelLabel * 16) + 1
            for i in 0...15 {
                channelLabelsCollection[i].text = String(numberForLabel)
                numberForLabel += 1
            }
            for i in channelSelectCollection.indices {
                channelSelectCollection[i].backgroundColor = (i == channelLabel) ? #colorLiteral(red: 0.1668410003, green: 0.6179428697, blue: 0, alpha: 1) : #colorLiteral(red: 0.8823529412, green: 0.1960784314, blue: 0.1607843137, alpha: 1)
            }
        }
    }
}

