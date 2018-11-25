//
//  ViewController.swift
//  JunctionHack
//
//  Created by Goran Vuksic on 24/11/2018.
//  Copyright © 2018 Goran Vuksic. All rights reserved.
//

import UIKit
import SwiftCharts

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}

class ViewController: UIViewController {

    fileprivate var chart: Chart? // arc
    
    private var didLayout: Bool = false
    
    fileprivate var lastOrientation: UIInterfaceOrientation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.black
    }

    private func initChart() {
        
        let labelSettings = ChartLabelSettings(font: UIFont.systemFont(ofSize: 12.0), fontColor: UIColor.white)
        
        let firstTime: Double = 0
        let lastTime: Double = 60
        
        let xValuesGenerator = ChartAxisGeneratorMultiplier(1)
        
        var labCopy = labelSettings
        labCopy.fontColor = UIColor.red
        let xEmptyLabelsGenerator = ChartAxisLabelsGeneratorFunc {value in return
            ChartAxisLabel(text: "", settings: labCopy)
        }
        
        let xModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstTime, lastModelValue: lastTime, axisTitleLabels: [], axisValuesGenerator: xValuesGenerator, labelsGenerator:
            xEmptyLabelsGenerator)
        
        let rangeSize: Double = view.frame.width < view.frame.height ? 12 : 6 // adjust intervals for orientation
        let rangedMult: Double = rangeSize / 2
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        
        let xRangedLabelsGenerator = ChartAxisLabelsGeneratorFunc {value -> ChartAxisLabel in
            if value < lastTime && value.truncatingRemainder(dividingBy: rangedMult) == 0 && value.truncatingRemainder(dividingBy: rangeSize) != 0 {
                let val1 = value - rangedMult
                let val2 = value + rangedMult
                return ChartAxisLabel(text: "\(String(format: "%.0f", val1)) - \(String(format: "%.0f", val2))", settings: labelSettings)
            } else {
                return ChartAxisLabel(text: "", settings: labelSettings)
            }
        }
        
        let xValuesRangedGenerator = ChartAxisGeneratorMultiplier(rangedMult)
        
        let xModelForRanges = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstTime, lastModelValue: lastTime, axisTitleLabels: [], axisValuesGenerator: xValuesRangedGenerator, labelsGenerator: xRangedLabelsGenerator)
        
        let xValuesGuidelineGenerator = ChartAxisGeneratorMultiplier(rangeSize)
        let xModelForGuidelines = ChartAxisModel(lineColor: UIColor.white, firstModelValue: firstTime, lastModelValue: lastTime, axisTitleLabels: [], axisValuesGenerator: xValuesGuidelineGenerator, labelsGenerator: xEmptyLabelsGenerator)
        
        let generator = ChartAxisGeneratorMultiplier(10)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        
        let yModel = ChartAxisModel(lineColor: UIColor.white, firstModelValue: 10, lastModelValue: 40, axisTitleLabels: [], axisValuesGenerator: generator, labelsGenerator: labelsGenerator)
        
        let chartFrame = Defaults.chartFrame(view.bounds)
        
        var chartSettings = Defaults.chartSettingsWithPanZoom
        
        chartSettings.axisStrokeWidth = 0.5
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.leading = -1
        chartSettings.trailing = 40
        
        let coordsSpace = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let coordsSpaceForRanges = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForRanges, yModel: yModel)
        let coordsSpaceForGuidelines = ChartCoordsSpaceRightBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModelForGuidelines, yModel: yModel)
        
        var (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        var (xRangedAxisLayer, _, _) = (coordsSpaceForRanges.xAxisLayer, coordsSpaceForRanges.yAxisLayer, coordsSpaceForRanges.chartInnerFrame)
        let (xGuidelinesAxisLayer, _, _) = (coordsSpaceForGuidelines.xAxisLayer, coordsSpaceForGuidelines.yAxisLayer, coordsSpaceForGuidelines.chartInnerFrame)
        
        
        // lines layer
        let line1ChartPoints = line1ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        let line1Model = ChartLineModel(chartPoints: line1ChartPoints, lineColor: UIColor(red: 31.0/255.0, green: 130.0/255.0, blue: 223.0/255.0, alpha: 1.0), lineWidth: 2, animDuration: 0, animDelay: 0)
        
        let line2ChartPoints = line2ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        let line2Model = ChartLineModel(chartPoints: line2ChartPoints, lineColor: UIColor(red: 206.0/255.0, green: 124.0/255.0, blue: 250.0/255.0, alpha: 1.0), lineWidth: 2, animDuration: 0, animDelay: 0)
        
        let line3ChartPoints = line3ModelData.map{ChartPoint(x: ChartAxisValueDouble($0.0), y: ChartAxisValueDouble($0.1))}
        let line3Model = ChartLineModel(chartPoints: line3ChartPoints, lineColor: UIColor.white, lineWidth: 2, animDuration: 0, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer<ChartPoint>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [line1Model, line2Model, line3Model], pathGenerator: CubicLinePathGenerator(tension1: 0.2, tension2: 0.2))
        
        
        // markers
        let viewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsViewsLayer, chart: Chart) -> UIView? in
            let h: CGFloat = 30
            let w: CGFloat = 60
            
            let center = chartPointModel.screenLoc
            let label = UILabel(frame: CGRect(x: chart.containerView.frame.maxX, y: center.y - h / 2, width: w, height: h))
            label.backgroundColor = {
                return UIColor.white
            }()
            
            label.textAlignment = NSTextAlignment.center
            label.text = chartPointModel.chartPoint.y.description
            label.font = Defaults.labelFont
            
            let shape = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: h / 2))
            path.addLine(to: CGPoint(x: 20, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 20, y: h))
            path.close()
            shape.path = path.cgPath
            label.layer.mask = shape
            
            return label
        }
        
        // last chart points
        let chartPointsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [line1ChartPoints.last!, line2ChartPoints.last!, line3ChartPoints.last!], viewGenerator: viewGenerator, mode: .custom, clipViews: false)
        
        chartPointsLayer.customTransformer = {(model, view, layer) -> Void in
            var model = model
            model.screenLoc = layer.modelLocToScreenLoc(x: model.chartPoint.x.scalar, y: model.chartPoint.y.scalar)
            view.frame.origin = CGPoint(x: layer.chart?.containerView.frame.maxX ?? 0, y: model.screenLoc.y - 20 / 2)
        }
        
        chartSettings.customClipRect = CGRect(x: 0, y: chartSettings.top, width: view.frame.width, height: view.frame.height - 120)
        
        // guidelines layer
        let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.white, linesWidth: 0.3)
        let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        // dividers layer
        let dividersSettings =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 1, start: 2, end: 0)
        let dividersLayer = ChartDividersLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, axis: .xAndY, settings: dividersSettings)
        
        
        // dividers layer with long lines
        let dividersSettings2 =  ChartDividersLayerSettings(linesColor: UIColor.white, linesWidth: 0.5, start: 30, end: 0)
        let dividersLayer2 = ChartDividersLayer(xAxisLayer: xGuidelinesAxisLayer, yAxisLayer: yAxisLayer, axis: .x, settings: dividersSettings2)
        
        xRangedAxisLayer.canChangeFrameSize = false
        xAxisLayer.canChangeFrameSize = false
        
        // create chart instance with frame and layers
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                xRangedAxisLayer,
                xGuidelinesAxisLayer,
                yAxisLayer,
                guidelinesLayer,
                chartPointsLayer,
                chartPointsLineLayer,
                dividersLayer,
                dividersLayer2
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
        
    }
    
    // white
    fileprivate var line1ModelData: [(Double, Double)] = [(0, 23), (10, 23), (20, 23), (30, 23), (40, 23), (50, 23), (60, 23)]
    // blue
    fileprivate var line2ModelData: [(Double, Double)] = [(0, 23), (10, 23), (20, 23), (30, 23), (40, 23), (50, 23), (60, 23)]
    // pink
    fileprivate var line3ModelData: [(Double, Double)] = [(0, 23), (10, 23), (20, 23), (30, 23), (40, 23), (50, 23), (60, 23)]

    var value0 : Double = 23
    var value10 : Double = 23
    var value20 : Double = 23
    var value30 : Double = 23
    var value40 : Double = 23
    var value50 : Double = 23
    var value60 : Double = 23
    
    var globalChecksumOnResponse : String = "0000"

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !self.didLayout {
            self.didLayout = true
            self.initChart()
            var timerDelay : Int = 0
            _ = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in

                // print("timer fired")

                timerDelay += 1

                // inital delay
                if timerDelay > 2 {

                let urlPath = "<removed-for-code-submit>/junctionStage/data"
                guard let endpoint = URL(string: urlPath) else {
                    print("Error creating endpoint")
                    return
                }

                URLSession.shared.dataTask(with: endpoint) { (data, response, error) in
                    do {
                        guard let data = data else {
                            throw JSONError.NoData
                        }
                        let json = try JSONSerialization.jsonObject(with: data, options:[]) as! NSDictionary
                        
                        let v0 = json["value0temp"] as! Int
                        let v0time = json["value0time"] as! String

                        var valueToUpdate : Int = 23
                        
                        if self.globalChecksumOnResponse != v0time {
                            self.globalChecksumOnResponse = v0time
                            valueToUpdate = v0
                        }
                        
                        // shift left
                        self.value0 = self.value10
                        self.value10 = self.value20
                        self.value20 = self.value30
                        self.value30 = self.value40
                        self.value40 = self.value50
                        self.value50 = self.value60
                        self.value60 = Double(valueToUpdate)

                        // reinit chart
                        DispatchQueue.main.async {
                            self.chart?.view.removeFromSuperview()
                            self.line1ModelData = [(0, self.value0), (10, self.value10), (20, self.value20), (30, self.value30), (40, self.value40), (50, self.value50), (60, self.value60)]
                            self.initChart()
                        }

                    } catch let error as JSONError {
                        print(error.rawValue)
                    } catch let error as NSError {
                        print(error.debugDescription)
                    }
                    }.resume()
                
                }
            }
        }
    }
    
    
    @objc func rotated() {
        let orientation = UIApplication.shared.statusBarOrientation
        guard (lastOrientation.map{$0.rawValue != orientation.rawValue} ?? true) else {return}
        
        lastOrientation = orientation
        
        guard let chart = chart else {return}
        for view in chart.view.subviews {
            view.removeFromSuperview()
        }
        self.initChart()
        chart.view.setNeedsDisplay()
        
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

