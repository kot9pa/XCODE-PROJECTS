//
//  BlinkingFaceViewController.swift
//  FaceIt
//
//  Created by Konstantin on 09.07.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

class BlinkingFaceViewController: FaceViewController {
    var blinking = false {
        didSet {
            blinkIfNeed()
        }
    }
    
    private func blinkIfNeed() {
        if blinking {
            faceView.eyesOpen = false
            Timer.scheduledTimer(withTimeInterval: BlinkRate.closedDuration, repeats: false, block: { [weak self] (timer) in
                self?.faceView.eyesOpen = true
                Timer.scheduledTimer(withTimeInterval: BlinkRate.openDuration, repeats: false, block: { [weak self] (timer) in
                    self?.blinkIfNeed()
                })
            })
        }
        
    }
    
    private struct BlinkRate {
        static let closedDuration: TimeInterval = 0.4
        static let openDuration: TimeInterval = 2.5
        
    }
    
    // MARK: Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        blinking = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        blinking = false
    }

}
