//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by Konstantin on 07.04.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

class EmotionsViewController: UIViewController {
    
    private let emotionalFaces: Dictionary<String, FacialExpression> = [
        "Sad": FacialExpression(eyes: .closed, mouth: .frown),
        "Happy": FacialExpression(eyes: .open, mouth: .smile),
        "Worried": FacialExpression(eyes: .open, mouth: .smirk)
    
    ]

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if let faceViewController = destinationViewController as? FaceViewController,
            let identifier = segue.identifier,
            let expression = emotionalFaces[identifier] {
            faceViewController.expression = expression
            faceViewController.navigationItem.title = (sender as? UIButton)?.currentTitle
        }
    }

}
