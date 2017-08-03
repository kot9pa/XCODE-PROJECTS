//
//  Themes.swift
//  Calculator
//
//  Created by Konstantin on 17.04.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

// TODO: Create themes

struct ThemeColors {
    let Primary: UIColor
    let Secondary: UIColor
    let BackgroundPrimary: UIColor
    let BackgroundSecondary: UIColor
    let TextDark: UIColor
    let TextLight: UIColor
    
}

enum ButtonStyle : String {
    case Digits, Functions
    case Operations
    
}

enum TextStyle : String {
    case Display, History
    case Memory
    
}

protocol Theme {
    var colors: ThemeColors {get}
    
    func themeApplication()
    func styleForTextStyle(textStyle: TextStyle) -> UIColor
    
    func themeButton(buttons: [UIButton], style: ButtonStyle)
    func themeLabel(label: UILabel, textStyle: TextStyle)
    func themeText(view: UITextView, textStyle: TextStyle)
    func themeSwitch(switchView: UISwitch)
    func themeStepper(stepper: UIStepper)
}

extension Theme {
    func themeLabel(label: UILabel, textStyle: TextStyle) {
        let style = styleForTextStyle(textStyle: textStyle)
        label.textColor = style
        label.backgroundColor = colors.BackgroundSecondary
    }
    
    func themeText(view: UITextView, textStyle: TextStyle) {
        let style = styleForTextStyle(textStyle: textStyle)
        view.textColor = style
        view.backgroundColor = colors.BackgroundSecondary
    }
    
    func themeApplication() {
        UIApplication.shared.keyWindow?.tintColor = colors.Secondary
        themeSwitch(switchView: UISwitch.appearance())
        themeStepper(stepper: UIStepper.appearance())
    }
    
    func themeSwitch(switchView: UISwitch) {
        //switchView.onTintColor = colors.Secondary
    }
    
    func themeStepper(stepper: UIStepper) {
        //stepper.tintColor = colors.Secondary
    }
}

class WhiteTheme : Theme {
    
    let colors: ThemeColors
    
    init() {
        colors = ThemeColors(
            Primary: UIColor(colorLiteralRed: 0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1),
            Secondary: UIColor(colorLiteralRed: 0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1),
            BackgroundPrimary: UIColor.lightGray.withAlphaComponent(0.9),
            BackgroundSecondary: UIColor.lightGray,
            TextDark: UIColor.darkGray,
            TextLight: UIColor.white
            
        )
    }
    
    func styleForTextStyle(textStyle: TextStyle) -> UIColor {
        var color: UIColor
        switch textStyle {
        case .Display, .History:
            color = colors.TextLight
        case .Memory:
            color = colors.Primary
        }
        
        return color
    }
    
    func themeButton(buttons: [UIButton], style: ButtonStyle) {
        switch style {
        case .Digits, .Functions:
            for button in buttons {
                button.setTitleColor(colors.TextDark, for: .normal)
                button.backgroundColor = colors.BackgroundSecondary
            }
                        
        case .Operations:
            for button in buttons {
                button.setTitleColor(colors.Primary, for: .normal)
                button.backgroundColor = colors.BackgroundSecondary
            }
        }
    }
}

class BlackTheme : Theme {
    
    let colors: ThemeColors
    
    init() {
        colors = ThemeColors(
            Primary: UIColor(colorLiteralRed: 0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1),
            Secondary: UIColor(colorLiteralRed: 0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1),
            BackgroundPrimary: UIColor.darkGray.withAlphaComponent(0.9),
            BackgroundSecondary: UIColor.darkGray,
            TextDark: UIColor.lightGray,
            TextLight: UIColor.lightGray
            
            )
    }
    
    func styleForTextStyle(textStyle: TextStyle) -> UIColor {
        var color: UIColor
        switch textStyle {
        case .Display, .History:
            color = colors.TextLight
        case .Memory:
            color = colors.Primary
        }
        
        return color
    }
    
    func themeButton(buttons: [UIButton], style: ButtonStyle) {
        switch style {
        case .Digits, .Functions:
            for button in buttons {
                button.setTitleColor(colors.TextDark, for: .normal)
                button.backgroundColor = colors.BackgroundSecondary
            }
            
        case .Operations:
            for button in buttons {
                button.setTitleColor(colors.Primary, for: .normal)
                button.backgroundColor = colors.BackgroundSecondary
            }
        }
    }
}

class ThemeManager {
    static var theme: Theme = BlackTheme()
}

