//
//  Settings.swift
//  Calculator
//
//  Created by Konstantin on 18.04.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import Foundation

class Settings {
    struct Defaults {
        static let DigitLimit = 9
        static let ThemeIdx = 0
        static let FractionDigits = 6
        static let AxesColorIdx = 2
        static let GraphColorIdx = 0
        static let ShowResultPoint = false
        
    }
    
    private struct Keys {
        static let DigitLimit = "Settings.DigitLimit"
        static let ThemeIdx = "Settings.ThemeIdx"
        static let FractionDigits = "Settings.FractionDigits"
        static let AxesColorIdx = "Settings.AxesColorIdx"
        static let GraphColorIdx = "Settings.GraphColorIdx"
        static let ShowResultPoint = "Settings.ShowResultPoint"
        
    }
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: Settings
    
    var DigitLimit: Int {
        get { return (userDefaults.object(forKey: Keys.DigitLimit) as? Int) ?? Defaults.DigitLimit}
        set { userDefaults.set(newValue, forKey: Keys.DigitLimit)}
    }
    
    var ThemeIdx: Int {
        get { return (userDefaults.object(forKey: Keys.ThemeIdx) as? Int) ?? Defaults.ThemeIdx}
        set { userDefaults.set(newValue, forKey: Keys.ThemeIdx)}
    }
    
    var FractionDigits: Int {
        get { return (userDefaults.object(forKey: Keys.FractionDigits) as? Int) ?? Defaults.FractionDigits}
        set { userDefaults.set(newValue, forKey: Keys.FractionDigits)}
    }
    
    var AxesColorIdx: Int {
        get { return (userDefaults.object(forKey: Keys.AxesColorIdx) as? Int) ?? Defaults.AxesColorIdx}
        set { userDefaults.set(newValue, forKey: Keys.AxesColorIdx)}
    }
    
    var GraphColorIdx: Int {
        get { return (userDefaults.object(forKey: Keys.GraphColorIdx) as? Int) ?? Defaults.GraphColorIdx}
        set { userDefaults.set(newValue, forKey: Keys.GraphColorIdx)}
    }
    
    var ShowResultPoint: Bool {
        get { return (userDefaults.object(forKey: Keys.ShowResultPoint) as? Bool) ?? Defaults.ShowResultPoint}
        set { userDefaults.set(newValue, forKey: Keys.ShowResultPoint)}
    }
    
    func setDefault() {
        DigitLimit = Defaults.DigitLimit
        FractionDigits = Defaults.FractionDigits
        ThemeIdx = Defaults.ThemeIdx
        AxesColorIdx = Defaults.AxesColorIdx
        GraphColorIdx = Defaults.GraphColorIdx
        ShowResultPoint = Defaults.ShowResultPoint
    }
}
