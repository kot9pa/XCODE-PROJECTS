//
//  SettingsTableViewController.swift
//  Calculator
//
//  Created by Konstantin on 18.04.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    deinit {
        instanceCount -= 1
        print("SettingsVC instance count = \(instanceCount)")
    }
    var instanceCount = 0
    
    // MARK: Properties
    
    @IBOutlet weak var showResultCell: UITableViewCell!
    @IBOutlet weak var themeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var digitsLimitStepper: UIStepper!
    @IBOutlet weak var fractionLimitStepper: UIStepper!
    @IBOutlet weak var digitsLimitField: UILabel!
    @IBOutlet weak var fractionLimitField: UILabel!
    @IBOutlet weak var axesColorPicker: UIPickerView!
    @IBOutlet weak var graphColorPicker: UIPickerView!
    
    private let settings = Settings()
    private let titleColors = ["Black","Red","Blue","Brown","Gray","Green","Purple","Orange","Cyan","Magenta"]
    private let colors: [Int:UIColor] = [0:.black,1:.red,2:.blue,3:.brown,4:.gray,
                                         5:.green,6:.purple,7:.orange,8:.cyan,9:.magenta]
    
    // MARK: Actions
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl)
    {
        settings.ThemeIdx = sender.selectedSegmentIndex
    }
    
    @IBAction func digitsValueChanged(_ sender: UIStepper) {
        digitsLimitField.text = String(Int(sender.value))
        settings.DigitLimit = Int(sender.value)
    }
    
    @IBAction func fractionValueChanged(_ sender: UIStepper) {
        fractionLimitField.text = String(Int(sender.value))
        settings.FractionDigits = Int(sender.value)
    }
    
    // MARK: Function
    
    private func showAlert() {
        let alert = UIAlertController(title: "Warning!", message: "Reset all settings to default value?", preferredStyle: .alert)
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let buttonOK = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.settings.setDefault()
            self.loadSettings() })
        
        alert.addAction(buttonOK)
        alert.addAction(buttonCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loadSettings() {
        // load settings from Settings()
        //self.tableView.reloadData()
        digitsLimitStepper.value = Double(settings.DigitLimit)
        digitsLimitField.text = String(Int(settings.DigitLimit))
        fractionLimitStepper.value = Double(settings.FractionDigits)
        fractionLimitField.text = String(Int(settings.FractionDigits))
        themeSegmentedControl.selectedSegmentIndex = settings.ThemeIdx
        axesColorPicker.selectRow(settings.AxesColorIdx, inComponent: 0, animated: true)
        graphColorPicker.selectRow(settings.GraphColorIdx, inComponent: 0, animated: true)
        showResultCell.accessoryType = settings.ShowResultPoint ? .checkmark: .none
        
    }
    
        
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instanceCount += 1
        print("SettingsVC instance count = \(instanceCount)")
        
        loadSettings()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Picker Viewer Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titleColors[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return titleColors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case axesColorPicker:
            settings.AxesColorIdx = row
        case graphColorPicker:
            settings.GraphColorIdx = row
        default:
            return
        }
        pickerView.reloadAllComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let color = colors[row]
        return NSAttributedString(string: titleColors[row], attributes: [NSForegroundColorAttributeName : color!])
    }
    
    // MARK: Table View Functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if indexPath.section == 3 && indexPath.row == 0 {
            showAlert()
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                settings.ShowResultPoint = false
            } else {
                cell.accessoryType = .checkmark
                settings.ShowResultPoint = true
            }
        }
    }
    
}
