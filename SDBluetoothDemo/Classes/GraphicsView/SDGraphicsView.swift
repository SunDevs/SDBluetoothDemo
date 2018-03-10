//
//  SDGraphicsView.swift
//  SDBluetoothDemo
//
//  Created by sundevs 3 on 25/02/18.
//  Copyright © 2018 sundevs. All rights reserved.
//

import UIKit

class SDGraphicsView: UIView {

    let nibName = "SDGraphicsView"
    var view: UIView!
    var yArray: [[String: Int]]!
    var isFirstime: Bool!
    var graficaImageView: UIImageView!
    
    @IBOutlet weak var lblChanel: UILabel!
    @IBOutlet weak var lblBateryLevel: UILabel!
    @IBOutlet weak var lblBitsPerSecond: UILabel!
    @IBOutlet weak var lblBitErrorRate: UILabel!
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isFirstime {
            isFirstime = false
            
            //DIBUJADO DE EJES
            let width = view.frame.size.width
            let height = view.frame.size.height
            let chanelWidth = lblChanel.frame.size.width;
            let bateryWidth = lblBateryLevel.frame.size.width;
            let contextWidth = width-(chanelWidth+bateryWidth)
            
            UIGraphicsBeginImageContext(CGSize(width:contextWidth , height: height));
            let contexto = UIGraphicsGetCurrentContext();
            
            //UIBezierPath *ejes = [UIBezierPath bezierPath];
            let ejes = UIBezierPath()
            let lineWidth:CGFloat =  1.0
            ejes.lineWidth = lineWidth
            ejes.move(to: CGPoint(x: 0, y: 0))
            ejes.addLine(to: CGPoint(x: 0, y: height))
            ejes.addLine(to: CGPoint(x: contextWidth, y: height))
            
            contexto?.setStrokeColor(UIColor.black.cgColor)
            ejes.stroke()
            
            let ejesImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let ejesImageView = UIImageView(image: ejesImage)
            ejesImageView.frame = CGRect(x: chanelWidth, y: 0, width: contextWidth, height: height)
            view.addSubview(ejesImageView)
        }
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
        isFirstime = true
        yArray = []
    }

    func graphicData() {
    
        let width = view.frame.size.width
        let height = view.frame.size.height
        let chanelWidth = lblChanel.frame.size.width;
        let bateryWidth = lblBateryLevel.frame.size.width;
        let contextWidth = width-(chanelWidth+bateryWidth)
        
        let bps = getBitsPerSecondFromData(yArray)
        if bps != ""  {
            lblBitsPerSecond.text = bps
        }
        lblBitErrorRate.text = getBitsErrorRateFromData(yArray)
        
        UIGraphicsBeginImageContext(CGSize(width: contextWidth, height: height));
        
        let contexto2: CGContext? = UIGraphicsGetCurrentContext()
        let grafica = UIBezierPath()
        grafica.lineWidth = 1.0
        grafica.move(to: CGPoint(x: 0, y: height))
        
        for i in 0..<yArray.count {
            let valuei: [String:Int] = yArray[i]
            let EMGValue: Int = valuei[SDConstants.kEMG]!
            let timestampValue: Int = valuei[SDConstants.kTimestamp]!
            let chanelValue: Int = valuei[SDConstants.kSensorId]!
            let bateryLevelValue: Int = valuei[SDConstants.kBateryLevel]!
            let yi = (EMGValue*Int(height))/4095
            var xi: Double = 0.0
            if yArray.count > 1{
                let value0: [String:Int] = yArray.first!
                let timestampValue0: Int = value0[SDConstants.kTimestamp]!
                let timeinMilis: Int = timestampValue - timestampValue0
                xi = Double(timeinMilis*Int(contextWidth))/SDConstants.kBaseMiliseconds
            }
            
            grafica.addLine(to: CGPoint(x: CGFloat(xi), y: CGFloat((Int(height) - yi))))
            //grafica.addLine(to: CGPoint(x: CGFloat(paso*i), y: CGFloat((Int(height) - yi))))
            
            lblChanel.text = String(format: "CH%@", String(chanelValue))
            lblBateryLevel.text = String(format: "Battery %@", String(bateryLevelValue))
        }
        
        contexto2?.setStrokeColor(UIColor.red.cgColor)
        grafica.stroke()
        let graficaImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if (graficaImageView != nil) {
            graficaImageView.removeFromSuperview()
            graficaImageView = nil
        }
        graficaImageView = UIImageView(image: graficaImage)
        graficaImageView.frame = CGRect(x: chanelWidth, y: 0, width: contextWidth, height: height)
        view.addSubview(graficaImageView)
        
        let value0: [String:Int] = yArray.first!
        let valueLast: [String:Int] = yArray.last!
        let timestampValue0: Int = value0[SDConstants.kTimestamp]!
        let timestampValueLast: Int = valueLast[SDConstants.kTimestamp]!
        let timeinMilis: Int = timestampValueLast - timestampValue0
        let lastX = Double(timeinMilis*Int(contextWidth))/SDConstants.kBaseMiliseconds
        if lastX >= Double(contextWidth) {
            //yArray = []
            yArray.remove(at: 0)
        }
    }
    
    private func getBitsPerSecondFromData(_ data: [[String: Int]]) -> String {
        var stringBps: String = ""
        let firstValue: [String:Int] = data.first!
        let lastValue: [String:Int] = data.last!
        let firstTimestampValue: Int = firstValue[SDConstants.kTimestamp]!
        let lastTimestampValue: Int = lastValue[SDConstants.kTimestamp]!
        let timeInterval = lastTimestampValue-firstTimestampValue
        if data.count > 1 && timeInterval > 0 {
            let timeIntervalInSeconds = Double(timeInterval)/1000.0
            let bps = Double(data.count * SDConstants.kBitsPerSensorInSample)/timeIntervalInSeconds
            stringBps = String(Int(bps))
        }
        return stringBps
    }
    
    private func getBitsErrorRateFromData(_ data: [[String: Int]]) -> String {
        var stringErrorRate: String = "0"
        var totalErrors: Int = 0
        for i in 0..<data.count {
            if i > 0 {
                let valueA: [String:Int] = data[i]
                let valueB: [String:Int] = data[(i-1)]
                let timestampValueA: Int = valueA[SDConstants.kTimestamp]!
                let timestampValueB: Int = valueB[SDConstants.kTimestamp]!
                let timeInterValues = timestampValueA-timestampValueB
                if timeInterValues != SDConstants.kMilisecondsSamplesInterval {
                    totalErrors += ((timeInterValues-SDConstants.kMilisecondsSamplesInterval)/SDConstants.kMilisecondsSamplesInterval)
                }
            }
        }
        let errorBitRate: Double = (Double(totalErrors)/Double(data.count))*100.0
        stringErrorRate = String(format:"%.1f", errorBitRate)
        stringErrorRate = stringErrorRate + "%"
        
        return stringErrorRate
    }
}
