//
//  ViewController.swift
//  Wagner
//
//  Created by Guru on 1/3/19.
//  Copyright © 2019 Guru. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let centralManager = CBCentralManager(delegate: nil, queue: nil, options: nil)
    
    var para0: String?
    var para1: String?
    var para2: String?
    var para3: String?
    var para4: String?
    var para5: String?
    var para6: String?
    var para7: String?
    var para8: String?
    var para9: String?
    var para10: String?
    var para11: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        centralManager.delegate = self
        
        
    }

    func parseParameters(_ raw: [UInt8], mac: String) {
        let externalRH = Int(raw[6]) + (Int(raw[7]) << 8)
        let externalTemp = Int(raw[8]) + (Int(raw[9]) << 8)
        para0 = "\(externalRH)/\(externalTemp)"
        
        //•  Ambient reading (RH/Temp)
        let ambientRH = Int(raw[25]) + (Int(raw[26]) << 8)
        let ambientTemp = Int(raw[27]) + (Int(raw[28]) << 8)

        para1 = "\(ambientRH)/\(externalTemp)"

        //•  Device date time(hh:mm:ss)
        let timestamp = UInt32(raw[16]) + (UInt32(raw[17]) << 8) + (UInt32(raw[18]) << 16) + (UInt32(raw[19]) << 24);
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let formattedTime = dateFormatter.string(from: date)
        
        para2 = formattedTime

        //•  Phone date time (hh:mm:ss)
        let now = Date()
        let formattedNow = dateFormatter.string(from: now)
        para3 = formattedNow

        //•  Battery level
        let battery = Int(raw[20])
        para4 = "\(battery)%"

        //•  Sensor serial number
        let snraw = raw[10..<16]

        let sn = String(bytes: snraw, encoding: .ascii)
        para5 = sn

        //•  Device mac address
        para6 = mac
        
        //•  Fw version
        let fwraw = raw[29..<34]
        let fwversion = String(bytes: fwraw, encoding: .ascii)
        para7 = fwversion
        
        //•  Device type
        var deviceType: String
        switch (raw[1]) {
        case 0xBA:
        deviceType = "Reader";
        case 0xBC:
        deviceType = "Grabber";
        case 0xBD:
        deviceType = "Mini";
        default:
            deviceType = "Unknown"
        }
        para8 = deviceType
        
        //•  Sensor type
        let sensorType = "\(raw[0])"
        para9 = sensorType
        //•  Device name
        let nameraw = raw[34..<46]
        let deviceName = String(bytes: nameraw, encoding: .ascii    )
        
        para10 = deviceName

        tableView.reloadData()
    }

}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth On")
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print(advertisementData[CBAdvertisementDataManufacturerDataKey])
        
        guard let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return
        }
        let rawExtra = [UInt8](data)
        
        if rawExtra[0] == 0x90 && rawExtra[1] == 0x33 {
            let raw = rawExtra[2..<rawExtra.count]
//            print(raw)
            DispatchQueue.main.async {
                self.parseParameters([UInt8](raw), mac: peripheral.identifier.uuidString)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "External reading (RH/Temp)"
            cell.detailTextLabel?.text = para0
        case 1:
            cell.textLabel?.text = "Ambient (RH/Temp)"
            cell.detailTextLabel?.text = para1
        case 2:
            cell.textLabel?.text = "Device date time"
            cell.detailTextLabel?.text = para2
        case 3:
            cell.textLabel?.text = "Phone date time"
            cell.detailTextLabel?.text = para3
        case 4:
            cell.textLabel?.text = "Battery Level"
            cell.detailTextLabel?.text = para4
        case 5:
            cell.textLabel?.text = "Sensor serial number"
            cell.detailTextLabel?.text = para5
        case 6:
            cell.textLabel?.text = "Device mac address"
            cell.detailTextLabel?.text = para6
        case 7:
            cell.textLabel?.text = "Fw version"
            cell.detailTextLabel?.text = para7
        case 8:
            cell.textLabel?.text = "Device tytpe"
            cell.detailTextLabel?.text = para8
        case 9:
            cell.textLabel?.text = "Sensor type"
            cell.detailTextLabel?.text = para9
        case 10:
            cell.textLabel?.text = "Device Name"
            cell.detailTextLabel?.text = para10
        default:
            cell.textLabel?.text = "Unknown"
            cell.detailTextLabel?.text = "Unknown"
        }
        return cell
    }
    
}
