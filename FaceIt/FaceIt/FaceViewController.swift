//
//  FaceViewController.swift
//  FaceIt
//
//  Created by Konstantin on 20.03.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {

    @IBOutlet weak var faceView: FaceView! {
        didSet {
            let handler = #selector(faceView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: faceView, action: handler)
            //let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toogleEyes(byReactingTo:)))
            let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(increaseHappines))
            swipeUpRecognizer.direction = .up
            let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(decreaseHappines))
            swipeDownRecognizer.direction = .down
            faceView.addGestureRecognizer(pinchRecognizer)
            //faceView.addGestureRecognizer(tapRecognizer)
            faceView.addGestureRecognizer(swipeUpRecognizer)
            faceView.addGestureRecognizer(swipeDownRecognizer)
            
            updateUI()
        }
    }
    
    var expression = FacialExpression(eyes: .open, mouth: .smile) {
        didSet {
            updateUI()
        }
    }
    
    private let mouthCurvatures = [FacialExpression.Mouth.grin:0.5,
                                   .frown:-1.0,
                                   .smile:1.0,
                                   .neutral:0.0,
                                   .smirk:-0.5]
    
    func updateUI() {
        
        switch expression.eyes {
        case .open:
            faceView?.eyesOpen = true
        case .closed:
            faceView?.eyesOpen = false
        case .squinting: break
            //faceView?.eyesOpen = false
        }
        
        faceView?.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
    
    }
    
    // MARK: Head Shake
    
    @IBAction func shakeHead(_ sender: UITapGestureRecognizer) {
        shakeHead()
    }
    
    private struct HeadShake {
        static let angle = CGFloat.pi/6                 // radians
        static let segmentDuration: TimeInterval = 0.5  // each head shake has 3 segments
    }
    
    private func rotateFace(by angle: CGFloat) {
        faceView.transform = faceView.transform.rotated(by: angle)
    }
    
    private func shakeHead() {
        UIView.animate(
            withDuration: HeadShake.segmentDuration,
            animations: { self.rotateFace(by: HeadShake.angle) },
            completion: { finished in
                if finished {
                    UIView.animate(
                        withDuration: HeadShake.segmentDuration,
                        animations: { self.rotateFace(by: -HeadShake.angle*2) },
                        completion: { finished in
                            if finished {
                                UIView.animate(
                                    withDuration: HeadShake.segmentDuration,
                                    animations: { self.rotateFace(by: HeadShake.angle) }
                                )
                            }
                    }
                    )
                }
        }
        )
    }
    /*
    func toogleEyes(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            let eyesState:FacialExpression.Eyes = (expression.eyes == .closed) ? .open : .closed
            expression = FacialExpression(eyes: eyesState, mouth: expression.mouth)
        }
    }*/
    
    func increaseHappines() {
        expression = expression.happier
    }
    
    func decreaseHappines() {
        expression = expression.sadder
    }

}

