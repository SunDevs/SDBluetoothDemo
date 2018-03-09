//
//  SDBluetoothManager.swift
//  SDBluetoothDemo
//
//  Created by sundevs 3 on 22/02/18.
//  Copyright © 2018 sundevs. All rights reserved.
//

import UIKit
import CoreBluetooth

let serviceCBUUID = CBUUID(string: "4fb2c091-3852-4cb6-bb62-540e88d11a64")
let characteristicCBUUID = CBUUID(string: "4869dfd2-32ef-4810-949b-66750aa37c1c")

protocol SDBluetoothManagerDelegate {
    func bluetoothManagerdidDiscoverPeriferials(_ peripherals: [CBPeripheral])
    func bluetoothManagerdidConnectToPeriferial(_ peripheral: CBPeripheral, error: Error?)
    func bluetoothManagerdidDisconnectToPeriferial(_ peripheral: CBPeripheral, error: Error?)
    func bluetoothManagerGetDecodedSensorsInfo(_ decodeSensors: [String:[String: Int]])
}

enum Bit: UInt8, CustomStringConvertible {
    case zero, one
    
    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}

class SDBluetoothManager: NSObject {
    
    static let sharedInstance = SDBluetoothManager()
    
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral!
    var delegate: SDBluetoothManagerDelegate?
    
    private var discoveredPeripheralMapping: [String:CBPeripheral]!
    private var scaningTimer = Timer()
    
    private override init() { }
    
    func intializeCentralManager()  {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() -> Bool {
        if centralManager.state == .poweredOn {
            discoveredPeripheralMapping = [:]
            centralManager.scanForPeripherals(withServices: [serviceCBUUID])
            scaningTimer.invalidate()
            scaningTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
            return true
        }
        return false
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral){
         connectedPeripheral = peripheral
         connectedPeripheral.delegate = self
         centralManager.connect(connectedPeripheral)
    }
    
    func selectService(_ service: CBService){
        connectedPeripheral.discoverCharacteristics([characteristicCBUUID], for: service)
    }
    
    func disconnectConnectedPeripheral() {
        if connectedPeripheral != nil {
            disconnectFromPeripheral(connectedPeripheral)
        }
    }
    
    private func discoveredPeriferials() -> [CBPeripheral] {
        let periferials = Array(discoveredPeripheralMapping.values)
        return periferials
    }
    
    private func insertDiscoveredPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let _ = discoveredPeripheralMapping[peripheral.identifier.uuidString] {
            return
        }
        discoveredPeripheralMapping[peripheral.identifier.uuidString] = peripheral
    }
    
    @objc private func timerAction() {
        centralManager.stopScan()
        scaningTimer.invalidate()
        delegate?.bluetoothManagerdidDiscoverPeriferials(discoveredPeriferials() )
    }
    
    private func disconnectFromPeripheral(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    private func decodingCharacteristicData(_ data: Data) {
        let sensors = SDBluetoothManager.sharedInstance.sensorsFromBytes([UInt8](data))
        var decodeSensors: [String:[String: Int]]
        decodeSensors = [:]
        for sensorKey in Array(sensors.keys) {
            let sensor = sensors[sensorKey]
            let decodeSensor = SDBluetoothManager.sharedInstance.decodedSensorsFromSensor(sensor!)
            decodeSensors[sensorKey] = decodeSensor
        }
        delegate?.bluetoothManagerGetDecodedSensorsInfo(decodeSensors)
    }
    
    private func sensorsFromBytes(_ bytes: [UInt8]) -> [String:[UInt8]] {
        var sensor1 = [UInt8]()
        var sensor2 = [UInt8]()
        var sensor3 = [UInt8]()
        var sensor4 = [UInt8]()
        var sensor5 = [UInt8]()
        var sensor6 = [UInt8]()
        for index in 0..<bytes.count {
            let byte = bytes[index]
            let indicator = index/6
            if indicator < 1{
                sensor1.append(byte)
            }else if indicator < 2 {
                sensor2.append(byte)
            }else if indicator < 3 {
                sensor3.append(byte)
            }else if indicator < 4 {
                sensor4.append(byte)
            }else if indicator < 5 {
                sensor5.append(byte)
            }else{
                sensor6.append(byte)
            }
        }
        let sensors = ["sensor1":sensor1, "sensor2":sensor2, "sensor3":sensor3, "sensor4":sensor4, "sensor5":sensor5, "sensor6":sensor6]
        return sensors
    }
    
    private func decodedSensorsFromSensor(_ sensor: [UInt8]) -> [String: Int] {
        let byte1 = SDBluetoothManager.sharedInstance.bits(fromByte: sensor[0])
        let byte2 = SDBluetoothManager.sharedInstance.bits(fromByte: sensor[1])
        let byte3 = SDBluetoothManager.sharedInstance.bits(fromByte: sensor[2])
        let byte4 = SDBluetoothManager.sharedInstance.bits(fromByte: sensor[3])
        let byte5 = SDBluetoothManager.sharedInstance.bits(fromByte: sensor[4])
        let byte6 = SDBluetoothManager.sharedInstance.bits(fromByte: sensor[5])
        
        let sensorIDBits = String(format: "%@%@%@", byte1[2].description, byte1[1].description, byte1[0].description)
        let sensorId = binaryToInt(binaryString: sensorIDBits)
        //print("sensorId \(sensorId)")
        
        let bateryLevelBits = String(format: "%@%@%@%@%@", byte1[7].description, byte1[6].description, byte1[5].description, byte1[4].description, byte1[3].description)
        let bateryLevel = binaryToInt(binaryString: bateryLevelBits)
        //print("bateryLevel \(bateryLevel)")
        
        let timestampBits = String(format: "%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", byte4[7].description, byte4[6].description, byte4[5].description, byte4[4].description, byte4[3].description, byte4[2].description, byte4[1].description, byte4[0].description, byte3[7].description, byte3[6].description, byte3[5].description, byte3[4].description, byte3[3].description, byte3[2].description, byte3[1].description, byte3[0].description, byte2[7].description, byte2[6].description, byte2[5].description, byte2[4].description, byte2[3].description, byte2[2].description, byte2[1].description, byte2[0].description)
        let timestamp = binaryToInt(binaryString: timestampBits)
        print("timestamp \(timestamp)")
        
        let EMGBits = String(format: "%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@", byte6[7].description, byte6[6].description, byte6[5].description, byte6[4].description, byte6[3].description, byte6[2].description, byte6[1].description, byte6[0].description, byte5[7].description, byte5[6].description, byte5[5].description, byte5[4].description, byte5[3].description, byte5[2].description, byte5[1].description, byte5[0].description)
        let EMG = binaryToInt(binaryString: EMGBits)
        
        return ["sensorId":sensorId, "bateryLevel":bateryLevel, "timestamp":timestamp, "EMG":EMG]
    }
    
    private func bits(fromByte byte: UInt8) -> [Bit] {
        var byte = byte
        var bits = [Bit](repeating: .zero, count: 8)
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = .one
            }
            
            byte >>= 1
        }
        
        return bits
    }
    
    func binaryToInt(binaryString: String) -> Int {
        return strtol(binaryString, nil, 2)
    }
}

extension SDBluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        SDBluetoothManager.sharedInstance.insertDiscoveredPeripheral(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral.discoverServices([serviceCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.bluetoothManagerdidConnectToPeriferial(peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        delegate?.bluetoothManagerdidDisconnectToPeriferial(peripheral, error: error)
    }
    
}

extension SDBluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        delegate?.bluetoothManagerdidConnectToPeriferial(peripheral, error: error)        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        let characteristic = characteristics.first
        peripheral.setNotifyValue(true, for: characteristic!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let characteristicData = characteristic.value else { return }
        SDBluetoothManager.sharedInstance.decodingCharacteristicData(characteristicData)
    }
}
