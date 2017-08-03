//
//  GraphViewController.swift
//  Calculator
//
//  Created by Konstantin on 29.03.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    
    deinit {
        instanceCount -= 1
        print("GraphVC instance count = \(instanceCount)")
    }
    var instanceCount = 0
    
    private let settings = Settings()
    private let colors: [Int:UIColor] = [0:.black,1:.red,2:.blue,3:.brown,4:.gray,
                                            5:.green,6:.purple,7:.orange,8:.cyan,9:.magenta]
    
    var axesColor: UIColor?
    var graphColor: UIColor?
    var function: ((Double) -> Double?)?
    var cache: (result: Double?, operand: Double?)
    
    @IBOutlet weak var graphView: GraphView! {
        didSet { updateUI() }
    }
    
    func updateUI() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.changeScale(byReactingTo:)))
        let panRecognizer = UIPanGestureRecognizer(target: graphView, action: #selector(graphView.move(byReactingTo:)))
        let doubleTapRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.doubleTap(byReactingTo:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        
        graphView.addGestureRecognizer(doubleTapRecognizer)
        graphView.addGestureRecognizer(panRecognizer)
        graphView.addGestureRecognizer(pinchRecognizer)
        graphView.dataSource = self
    }
    
    func getScale() -> CGFloat {
        let sizeY = graphView.bounds.midY/2
        let sizeX = graphView.bounds.midX/2
        
        if let result = cache.result, !result.isZero,
            let operand = cache.operand, !operand.isZero {
            switch max(result, operand) {
            case result:
                return abs(sizeY/CGFloat(result))
            case operand:
                return abs(sizeX/CGFloat(operand))
            default:
                return Constants.defaultScale
            }
        } else { return Constants.defaultScale }
    }
  
    func getYCoordinate(x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(Double(x))!)
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axesColor = colors[settings.AxesColorIdx]
        graphColor = colors[settings.GraphColorIdx]
        graphView.showResultPoint = settings.ShowResultPoint
        
        instanceCount += 1
        print("GraphVC instance count = \(instanceCount)")
    }
}
