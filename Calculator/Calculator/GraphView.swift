//
//  GraphView.swift
//  Calculator
//
//  Created by Konstantin on 28.03.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

//FIXME: origin to center not work on rotate

import UIKit

protocol GraphViewDataSource {
    func getScale() -> CGFloat
    func getYCoordinate(x: CGFloat) -> CGFloat?
    var graphColor: UIColor? { get }
    var axesColor: UIColor? { get }
    var cache: (result: Double?, operand: Double?) { get }

}

//@IBDesignable
class GraphView: UIView {

    //MARK: Public API

    var colorGraph:UIColor? { didSet { setNeedsDisplay() }}
    var colorAxes:UIColor? { didSet { setNeedsDisplay() }}
    
    //@IBInspectable
    var lineWidth:CGFloat = 2 { didSet { setNeedsDisplay() }}
    
    var showResultPoint:Bool! { didSet { setNeedsDisplay() }}
    
    private var originSet: CGPoint? { didSet { setNeedsDisplay() }}
    private var scaleSet: CGFloat? { didSet { setNeedsDisplay() }}
    
    private var graphColor: UIColor {
        get{ return colorGraph ?? dataSource?.graphColor ?? UIColor.black }
    }
    
    private var axesColor: UIColor {
        get{ return colorAxes ?? dataSource?.axesColor ?? UIColor.blue }
    }
    
    private var scale: CGFloat {
        get{
            return scaleSet ?? dataSource?.getScale() ?? Constants.defaultScale
        }
        set{
            scaleSet = newValue
        }
    }
    
    private var origin: CGPoint {
        get{
            return originSet ?? CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set{
            originSet = newValue
        }
    }
    
    var dataSource: GraphViewDataSource?
    private var axes = AxesDrawer()
    private var resultPoint: CGPoint?
    
    // MARK: Path Function

    private func pathForFunction() {
        let path = UIBezierPath()
        
        guard let data = dataSource else { return }
        let result = CGFloat(data.cache.result ?? 0.0)

        var funcPoint = CGPoint()
        var pathIsEmpty =  true
        let oldYGraph: CGFloat = 0.0
        var disContinuity: Bool // discontinuity point - tan()
        
        for pixel in 0...Int(bounds.size.width * contentScaleFactor) {
            
            funcPoint.x = CGFloat(pixel)/contentScaleFactor
            
            if let y = data.getYCoordinate(x: (funcPoint.x - origin.x)/scale) {
                
                if !y.isFinite {
                    pathIsEmpty = true
                    continue
                }
                
                disContinuity = abs(y - oldYGraph) > max(bounds.width, bounds.height)*1.5
                funcPoint.y = origin.y - y*scale
                
                if funcPoint.y.rounded() == (origin.y - result*scale).rounded() {
                    resultPoint = funcPoint
                
                }
                
                if pathIsEmpty {
                    path.move(to: funcPoint)
                    pathIsEmpty = false
                } else {
                    if disContinuity {
                        pathIsEmpty = true
                    } else {
                        path.addLine(to: funcPoint)
                    }
                }
            }
            //print("x=\(funcPoint.x), y=\(funcPoint.y)")
            
        }
        //print("result = \(result)")
        //print("origin = \(origin)")
        //print("point = \(String(describing: resultPoint))")
        //print("scale = \(scale)")
        
        graphColor.set()
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    private func pathForResult(_ point: CGPoint) {
        guard showResultPoint else { return }
        let path = UIBezierPath()
      
        path.addArc(withCenter: point, radius: 3.0, startAngle: 0.0, endAngle: 2*CGFloat.pi, clockwise: false)
        
        if point.y.isNormal && point.x.isNormal {
            path.move(to: point)
            path.addLine(to: CGPoint(x: point.x, y: origin.y))
            path.move(to: point)
            path.addLine(to: CGPoint(x: origin.x, y: point.y))
            
         }
        //print("pathForResult() complete")
        
        UIColor.green.set()
        path.lineWidth = 1
        path.stroke()
        path.fill()
        
        resultPoint = nil
    }

    override func draw(_ rect: CGRect) {
       
        pathForFunction()
        pathForResult(resultPoint ?? origin)
        
        axes.contentScaleFactor = contentScaleFactor
        axes.color = axesColor
        axes.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        
    }
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        
        switch pinchRecognizer.state {
        case .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default: break
        }
    }
    
    func move(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed, .ended:
            let translation = panRecognizer.translation(in: self)
            if translation != CGPoint.zero {
                origin.x += translation.x
                origin.y += translation.y
                panRecognizer.setTranslation(CGPoint.zero, in: self)
            }
        default: break
        }
    }
    
    func doubleTap(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            origin = CGPoint(x: bounds.midX, y: bounds.midY)
            scale = dataSource?.getScale() ?? Constants.defaultScale
        }
    }
    
}
