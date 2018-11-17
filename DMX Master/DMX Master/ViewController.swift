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
    
    // individual elements
    @IBOutlet weak var blackoutSelection: UIButton!
    @IBOutlet weak var saveButtonOnOff: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Slider Rotation
        for i in channelSlidersCollection.indices {
            channelSlidersCollection[i].transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            channelValuesCollection[i].text = String(Int(channelSlidersCollection[i].value))
        }
    }
    
}

