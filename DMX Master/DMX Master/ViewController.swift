//
//  ViewController.swift
//  DMX Master
//
//  Created by Jonathan Manoa on 11/16/18.
//  Copyright © 2018 ComboBreaker. All rights reserved.
//

import UIKit
import CoreBluetooth

let BLE_Arduino_UART_Service_CBUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

let BLE_Arduino_UART_RX_Characteristic_CBUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
let BLE_Arduino_UART_TX_Characteristic_CBUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager?
    var peripheralArduinoDMX: CBPeripheral?
    var characteristicRX: CBCharacteristic?
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: [BLE_Arduino_UART_Service_CBUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager?.stopScan()
        peripheralArduinoDMX = peripheral
        centralManager?.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([BLE_Arduino_UART_Service_CBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == BLE_Arduino_UART_Service_CBUUID}) {
            peripheral.discoverCharacteristics([BLE_Arduino_UART_RX_Characteristic_CBUUID], for: service)
            peripheral.discoverCharacteristics([BLE_Arduino_UART_TX_Characteristic_CBUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
       
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(BLE_Arduino_UART_RX_Characteristic_CBUUID) {
                characteristicRX = characteristic
                peripheral.setNotifyValue(true, for: characteristicRX!)
            }
        }
    }
    

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
    @IBOutlet weak var transitionSlider: UISlider!
    @IBOutlet weak var transitionTimeLabel: UILabel!
    @IBOutlet weak var sceneSlider: UISlider!
    @IBOutlet weak var sceneTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BLE Stuff
        let centralQueue: DispatchQueue = DispatchQueue(label: "Arduino_Queue", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        
        
        
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
        // Send the instruction type
        var data = 9
        let intData = Data(bytes: &data, count: MemoryLayout.size(ofValue: data))
        peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    // Updates the view to display current scene timer value
    @IBAction func sceneTimerValueUpdate(_ sender: UISlider) {
        let value = Int(sceneSlider.value)
        DMXController.setSceneTimer(time: value)
        sceneTimeLabel.text = "Scene Time: " + String(value) + "s"
    }
    
    // Updates the view to display current transition timer value
    @IBAction func transitionTimerValueUpdate(_ sender: Any) {
        let value = Int(transitionSlider.value)
        DMXController.setTransitionTimer(time: value)
        transitionTimeLabel.text = "Transition Time: " + String(value) + "s"
    }
    
    // Displays the current slider value.
    @IBAction func sliderValueUpdate(_ sender: UISlider) {
        let channelGroup = DMXController.getChannelSet()
        if let sliderChannel = channelSlidersCollection.firstIndex(of: sender) {
            channelValuesCollection[sliderChannel].text = String(Int(channelSlidersCollection[sliderChannel].value))
            DMXController.channelValueSet(channelIndex: ((channelGroup * 16) + (sliderChannel + 1)), channelValue: Int(channelSlidersCollection[sliderChannel].value))
            var data: [Int] = []
            // Send the instruction type
            data.append(1)
            //var intData = Data(bytes: &data, count: MemoryLayout.size(ofValue: data))
            //peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse)
            
            // Send the channel
            data.append(((channelGroup * 16) + (sliderChannel + 1)))
            //intData = Data(bytes: &data, count: MemoryLayout.size(ofValue: data))
            //peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse)
            
            // Send it
            data.append(Int(channelSlidersCollection[sliderChannel].value))
           // intData = Data(bytes: &data, count: MemoryLayout.size(ofValue: data))
            //peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse)
            
            for stuff in 0...2 {
                BLETransmission(data: data[stuff])
            }
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
    
    // Button used to allow for saving scenes locally
    @IBAction func saveOnOffButton(_ sender: UIButton) {
        DMXController.setSaveStatus()
        saveButtonOnOff.backgroundColor = DMXController.getSaveStatus() ? #colorLiteral(red: 0.1668410003, green: 0.6179428697, blue: 0, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    }
    
    // Buttons that are used to switch between scenes
    @IBAction func sceneSelect(_ sender: UIButton) {
        let scene = scceneSelection.firstIndex(of: sender)
        if DMXController.getSaveStatus() {
            DMXController.setSaveStatus()
            DMXController.updateScene(index: scene!)
            saveButtonOnOff.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
            scceneSelection[scene!].backgroundColor = #colorLiteral(red: 1, green: 0.6238600496, blue: 0, alpha: 1)
            BLETransmission(data: 4)
            BLETransmission(data: 1)
            BLETransmission(data: scene!)
            /*var data = 4
            var intData = Data(bytes: &data, count: MemoryLayout.size(ofValue: data))
            peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse)
            data = 1
            intData = Data(bytes: &data, count: MemoryLayout.size(ofValue: data))
            peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse)
            data = scene!
            intData = Data(bytes: &data, count: MemoryLayout.size(ofValue: data))
            peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse) */

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
    
    func BLETransmission(data: Int) {
        var value = data
        let intData = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        peripheralArduinoDMX?.writeValue(intData, for: characteristicRX!, type: CBCharacteristicWriteType.withoutResponse)
    }
}
