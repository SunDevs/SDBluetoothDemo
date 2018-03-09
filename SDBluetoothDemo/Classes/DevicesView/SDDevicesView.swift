//
//  SDDevicesView.swift
//  SDBluetoothDemo
//
//  Created by sundevs 3 on 24/02/18.
//  Copyright © 2018 sundevs. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol SDDevicesViewDelegate {
    func selectedPeriferial(_ peripheral: CBPeripheral)
    func closeDevicesView()
}

class SDDevicesView: UIView {

    @IBOutlet weak var devicesTableView: UITableView!
    let nibName = "SDDevicesView"
    var view: UIView!
    var devices: [CBPeripheral]!
    let cellReuseIdentifier = "cell"
    var delegate: SDDevicesViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetUp()
        initialize()
    }
    
    func xibSetUp() {
        view = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        // grabs the appropriate bundle
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func initialize() {
        devices = []
        self.devicesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
    }
    
    @IBAction func closeButtonTouch(_ sender: UIButton) {
        delegate?.closeDevicesView()
    }
}

extension SDDevicesView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = devices[indexPath.row]
        delegate?.selectedPeriferial(device)
    }
    
}

extension SDDevicesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:UITableViewCell = self.devicesTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
            
        let device = devices[indexPath.row]
            cell.textLabel?.text = device.name
            
        return cell
    }
    
}
