//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Konstantin on 07.03.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit
import AVFoundation

private var player: AVAudioPlayer?

class CalculatorViewController: UIViewController {
    
    var instanceCount = 0
    deinit {
        instanceCount -= 1
        print("CalcVC instance count = \(instanceCount)")
    }
    
    // MARK: Properties
      
    lazy var model = CalculatorModel()
    private var audioPlayer = AVAudioPlayer()
    private var cache: (operand:Double?, operation:String?)
    fileprivate var isUserTyping = false
    fileprivate var isErrorResult = false
    private let settings = Settings()
    private var themes: [Theme] = [BlackTheme(), WhiteTheme()]
    private var fractionDigits: Int?
    private var digitsLimit: Int?
    private var numberOfDigitsTyping = 0
    private var isDigitsLimit: Bool {
        get {
            if let limit = digitsLimit,
                numberOfDigitsTyping < limit
            {
                return false
            }
            return true
        }
    }
    
    private var arrayOfMemory: Double? {
        willSet {
            if let value = newValue {
                memory.text = "M = \(value)"
            } else {
                memory.text = ""
            }
        }
    }

    private var displayValue: Double? {
        get {
            if let text = display.text,
                let value = Double(text) {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                if value < Double(Int.max) {
                    decimalFormatter.maximumFractionDigits = fractionDigits ?? 0
                    display.text = decimalFormatter.string(from: value as NSNumber)
                } else {
                    scientificFormatter.maximumFractionDigits = fractionDigits ?? 0
                    display.text = scientificFormatter.string(from: value as NSNumber)
                }
                history.text = model.getDescription()
                
            } else {
                display.text = "0"
                history.text = " "
                isUserTyping = false
            }
        }
    }
    
    private var resultValue: (value: Double?, error: String?) = (0.0, nil) {
        didSet {
            switch resultValue {
            case (_, nil):
                if let result = resultValue.value {
                    displayValue = result
                    isErrorResult = false
                    graphView.isEnabled = true
                }
            case (_, let error):
                display.text = error
                history.text = model.getDescription()
                isErrorResult = true
                isUserTyping = false
                
            }
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet var digitButtons: [UIButton]!
    @IBOutlet var functionButtons: [UIButton]!
    @IBOutlet var operationButtons: [UIButton]!
    @IBOutlet weak var display: UILabel!    
    @IBOutlet weak var history: UITextView!
    @IBOutlet weak var memory: UITextView!
    @IBOutlet weak var properties: UIButton!    
    @IBOutlet weak var graphView: UIButton! {
        didSet {
            graphView.isEnabled = false
            
        }
    }
    
    // MARK: Actions
    
    @IBAction func clearDisplay(_ sender: UIButton) {
        displayValue = nil
        arrayOfMemory = nil
        numberOfDigitsTyping = 0
        isUserTyping = false
        graphView.isEnabled = false
        
        model.clear()

    }
    
    @IBAction func clearMemory(_ sender: UIButton) {
        arrayOfMemory = nil

    }
    
    @IBAction func pushMemory(_ sender: UIButton) {
        if let value = arrayOfMemory {
            displayValue = value
            isUserTyping = true
            
        }
    }
    
    @IBAction func addMemory(_ sender: UIButton) {
        if !isErrorResult {
            if let value = displayValue {
                arrayOfMemory = value
                
            }
        }
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if isUserTyping {
            guard !display.text!.isEmpty else { return }
            display.text = String(display.text!.characters.dropLast())
            numberOfDigitsTyping -= 1
            if display.text!.isEmpty {
                isUserTyping = false
                resultValue = model.resultIsError ? (0.0,"Error"):(model.result,nil)
            }
            playButton()
            
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if isUserTyping && !isDigitsLimit {
            let currentText = display.text!
            //-- delete lead zero --
            if (digit == "0") && ((display.text == "0") || (display.text == "-0")){ return }
            if (digit !=  Constants.decimalDelimiter) && ((display.text == "0") || (display.text == "-0"))
            { display.text = digit ; return }
            //----------------------
            if !digit.contains(Constants.decimalDelimiter) ||
                (currentText.range(of: Constants.decimalDelimiter) == nil)
            {
                display.text = currentText + digit
                numberOfDigitsTyping += 1
            }
        } else if !isDigitsLimit {
            display.text = digit
            numberOfDigitsTyping = 1
            
        }
        isUserTyping = true
        graphView.isEnabled = false
        
        playButton()
        animateButton(sender)
        
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if isUserTyping {
            if let value = displayValue {
                model.setOperand(value)
                cache.operand = value
                //print("operand = \(String(describing: cache.operand))")
                
            }
            isUserTyping = false
            numberOfDigitsTyping = 0

        }
        if let operation = sender.currentTitle {
            model.performOperation(operation)
            cache.operation = operation
            //print("operation = \(String(describing: cache.operation))")
            
        }
        resultValue = model.resultIsError ? (0.0,"Error"):(model.result,nil)
        playButton()
        
    }
    
    // MARK: Functions
    
    private func prepareGraphVC(_ vc: GraphViewController) {
        
        vc.cache.result = (model.result == resultValue.value) ? model.result : resultValue.value
        vc.navigationItem.title = history.text ?? ""
        vc.cache.operand = cache.operand ?? displayValue
        vc.function = { [weak weakSelf = self] x in
            weakSelf?.model.setOperand(x)
            weakSelf?.model.performOperation((weakSelf?.cache.operation)!)
            return weakSelf?.model.result
        }
        
        isUserTyping = true
    }
    
    private func loadSettings() {
        digitsLimit = settings.DigitLimit
        fractionDigits = settings.FractionDigits
        ThemeManager.theme = themes[settings.ThemeIdx]
        
    }
    
    private func loadTheme() {
        let theme = ThemeManager.theme
        
        view.backgroundColor = theme.colors.BackgroundPrimary
        theme.themeButton(buttons: digitButtons, style: .Digits)
        theme.themeButton(buttons: functionButtons, style: .Functions)
        theme.themeButton(buttons: operationButtons, style: .Operations)
        
        theme.themeLabel(label: display, textStyle: .Display)
        theme.themeText(view: history, textStyle: .History)
        theme.themeText(view: memory, textStyle: .Memory)
    
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let audioSession = AVAudioSession.sharedInstance()
        try!audioSession.setCategory(AVAudioSessionCategoryAmbient)
        
        instanceCount += 1
        print("CalcVC instance count = \(instanceCount)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        memory.setContentOffset(CGPoint.zero, animated: animated) // UITextView alignment top-left
        
        loadSettings()
        loadTheme()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier {
            switch identifier {
            case Segue.showProperties:
                let vc = segue.destination as! SettingsTableViewController
                vc.navigationItem.title = "Properties"
            case Segue.showGraph:
                let vc = segue.destination as! GraphViewController
                prepareGraphVC(vc)
            default:
                break
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        switch identifier {            
        case Segue.showGraph:
            return !model.resultIsPending
        case Segue.showProperties:
            return true
        default:
            return false
        }
    }
}

private func playButton() {
    let url = Bundle.main.url(forResource: "touch", withExtension: "m4a")!
    
    do {
        player = try AVAudioPlayer(contentsOf: url)
        guard let player = player else { return }
        player.prepareToPlay()
        player.volume = 0.25
        player.play()
    } catch let error {
        print(error.localizedDescription)
    }
}

private func animateButton(_ sender: UIButton) {
    
    UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: { sender.alpha = 0.75 }, completion: nil)
    UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction, animations: { sender.alpha = 1 }, completion: nil)
    
}
