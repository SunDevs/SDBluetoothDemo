//
//  ViewController.swift
//  SDBluetoothDemo
//
//  Created by sundevs 3 on 22/02/18.
//  Copyright © 2018 sundevs. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    var devicesView: SDDevicesView!
    var devices: [CBPeripheral]!
    
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var gvSensor1: SDGraphicsView!
    @IBOutlet weak var gvSensor2: SDGraphicsView!
    @IBOutlet weak var gvSensor3: SDGraphicsView!
    @IBOutlet weak var gvSensor4: SDGraphicsView!
    @IBOutlet weak var gvSensor5: SDGraphicsView!
    @IBOutlet weak var gvSensor6: SDGraphicsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SDBluetoothManager.sharedInstance.delegate = self
        
        devices = []
        devicesView = SDDevicesView()
        devicesView.delegate = self
        
        updateButtonTitle()
        hideDevicesViews(true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = 240.0
        let height = 240.0
        let x = (Double(view.frame.size.width) - width)/2
        let y = (Double(view.frame.size.height) - height)/2
        devicesView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBAction func lookUp(_ sender: Any) {
        if (sender as! UIButton) == btnSearch {
            if (SDBluetoothManager.sharedInstance.connectedPeripheral) != nil {
                SDBluetoothManager.sharedInstance.disconnectConnectedPeripheral()
            }else {
                devices = []
                let canScan =  SDBluetoothManager.sharedInstance.scanForPeripherals()
                if  !canScan {
                    print("mostrar alerta")
                }
            }
        }
    }
    
    private func updateButtonTitle() {
        if (SDBluetoothManager.sharedInstance.connectedPeripheral) != nil {
            btnSearch.setTitle("Disconnect device", for: .normal)
        }else {
            btnSearch.setTitle("Search devices", for: .normal)
        }
    }
    
    private func hideDevicesViews(_ hide: Bool) {
        if hide {
            gvSensor1.alpha = 0
            gvSensor2.alpha = 0
            gvSensor3.alpha = 0
            gvSensor4.alpha = 0
            gvSensor5.alpha = 0
            gvSensor6.alpha = 0
        }else {
            gvSensor1.alpha = 1
            gvSensor2.alpha = 1
            gvSensor3.alpha = 1
            gvSensor4.alpha = 1
            gvSensor5.alpha = 1
            gvSensor6.alpha = 1
        }
    }
    
    private func cleanDevicesViews() {
        gvSensor1.graficaImageView.removeFromSuperview()
        gvSensor2.graficaImageView.removeFromSuperview()
        gvSensor3.graficaImageView.removeFromSuperview()
        gvSensor4.graficaImageView.removeFromSuperview()
        gvSensor5.graficaImageView.removeFromSuperview()
        gvSensor6.graficaImageView.removeFromSuperview()
        gvSensor1.yArray = []
        gvSensor2.yArray = []
        gvSensor3.yArray = []
        gvSensor4.yArray = []
        gvSensor5.yArray = []
        gvSensor6.yArray = []
    }
}

extension ViewController: SDBluetoothManagerDelegate {
    
    func bluetoothManagerdidDiscoverPeriferials(_ peripherals: [CBPeripheral]) {
        devices = peripherals
        devicesView.devices = devices
        devicesView.devicesTableView.reloadData()
        view.addSubview(devicesView)
    }
    
    func bluetoothManagerdidConnectToPeriferial(_ peripheral: CBPeripheral, error: Error?) {
        if (error != nil) {
            print("mostrar alerta")
        }else {
            let service = peripheral.services?.first
            SDBluetoothManager.sharedInstance.selectService(service!)
            devicesView.removeFromSuperview()
            hideDevicesViews(false)
        }
        updateButtonTitle()
    }
    
    func bluetoothManagerdidDisconnectToPeriferial(_ peripheral: CBPeripheral, error: Error?) {
        updateButtonTitle()
        hideDevicesViews(true)
        cleanDevicesViews()
    }
    
    func bluetoothManagerGetDecodedSensorsInfo(_ decodeSensors: [String : [String : Int]]) {
        gvSensor1.yArray.append(decodeSensors[SDConstants.kSensor1]!)
        gvSensor2.yArray.append(decodeSensors[SDConstants.kSensor2]!)
        gvSensor3.yArray.append(decodeSensors[SDConstants.kSensor3]!)
        gvSensor4.yArray.append(decodeSensors[SDConstants.kSensor4]!)
        gvSensor5.yArray.append(decodeSensors[SDConstants.kSensor5]!)
        gvSensor6.yArray.append(decodeSensors[SDConstants.kSensor6]!)
        gvSensor1.graphicData()
        gvSensor2.graphicData()
        gvSensor3.graphicData()
        gvSensor4.graphicData()
        gvSensor5.graphicData()
        gvSensor6.graphicData()
    }
    
}

extension ViewController: SDDevicesViewDelegate {
    
    func closeDevicesView() {
        devicesView.removeFromSuperview()
    }
    
    func selectedPeriferial(_ peripheral: CBPeripheral) {
        SDBluetoothManager.sharedInstance.connectToPeripheral(peripheral)
    }
    
}
