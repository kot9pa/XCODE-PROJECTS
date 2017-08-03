//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Konstantin on 08.03.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import Foundation

struct CalculatorModel {
    
    //MARK: Properties
    
    enum Operation {
        case constant(Double)
        case precentOperation((String)->String)
        case nullaryOperation(()->Double, String)
        case unaryOperation((Double)->Double, ((String)->String)?, ((Double)->String?)?)
        case binaryOperation((Double,Double)->Double, ((String, String)->String)?, Int, ((Double, Double)->String?)? )
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        
        "rand":Operation.nullaryOperation({Double(arc4random())/Double(UInt32.max)}, "rand()"),
        "pi":Operation.constant(Double.pi),
        "e":Operation.constant(M_E),
        "%":Operation.precentOperation({ "%\($0)" }),
        "√":Operation.unaryOperation(sqrt, nil, { $0 < 0 ? "Error" : nil }),
        "cos":Operation.unaryOperation(cos, nil, nil),
        "sin":Operation.unaryOperation(sin, nil, nil),
        "tan":Operation.unaryOperation(tan, nil, nil),
        "atan":Operation.unaryOperation(atan, nil, nil),
        "exp":Operation.unaryOperation(exp, nil, nil),
        "lg":Operation.unaryOperation(log10, nil, { $0 <= 0 ? "Error" : nil }),
        "lb":Operation.unaryOperation(log2, nil, { $0 <= 0 ? "Error" : nil }),
        "ln":Operation.unaryOperation(log, nil, { $0 <= 0 ? "Error" : nil }),
        "±":Operation.unaryOperation({-$0}, nil, nil),
        "¹/x":Operation.unaryOperation({1.0/$0}, { "¹/(\($0))" }, { $0 == 0 ? "Error" : nil }),
        "x²":Operation.unaryOperation({$0*$0}, { "(\($0))²" }, nil),
        "xʸ":Operation.binaryOperation(pow, { "\($0) ^ \($1)" }, Int.max, nil),
        "logxʸ":Operation.binaryOperation({log($1)/log($0)}, { "log\($0) \($1)" }, Int.max, nil),
        "+":Operation.binaryOperation({$0+$1}, nil, Int.min, nil),
        "-":Operation.binaryOperation({$0-$1}, nil, Int.min, nil),
        "×":Operation.binaryOperation({$0*$1}, nil, Int.max, nil),
        "÷":Operation.binaryOperation({$0/$1}, nil, Int.max, { $1 == 0 ? "Error" : nil }),
        "=":Operation.equals
        
    ]
    
    private var iteration = 0
    private var accumulator: Double?
    private var currentPriority = Int.max
    fileprivate var pending: PendingBinaryOperation?
    private var error: String? = nil
    private var isSetOperand = false
    
    private var descriptionAccumulator: String? {
        didSet {
            if !resultIsPending {
                currentPriority = Int.max
            }
        }
    }

    var resultIsPending: Bool {
        get {
            return pending != nil
        }
    }

    var resultIsError: Bool {
        get {
            return error != nil
        }
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var description: String? {
        get {
            if !resultIsPending {
                return descriptionAccumulator
            } else {
                return pending!.description(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator! : "")
            }
        }
    }
   
    //MARK: Functions
    
    func getDescription() -> String? {
        if let description = description {
            return resultIsPending ? (description + " ..."): (description + " =")
        } else {
            return nil
        }
    }
    
    mutating func setOperand(_ operand: Double) {        
        accumulator = operand
        if let value = accumulator {
            descriptionAccumulator = (value as NSNumber).stringValue
        }
        isSetOperand = true
        error = nil
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .precentOperation(let description):
                if accumulator != nil {
                    accumulator = performPrecentOperation(accumulator!)
                    descriptionAccumulator = description(descriptionAccumulator!)
                }
            case .nullaryOperation(let function, let description):
                accumulator = function()
                descriptionAccumulator = description
                
            case .unaryOperation(let function, var description, let validator):
                if accumulator != nil {
                    error = validator?(accumulator!)
                    accumulator = function(accumulator!)
                    if description == nil {
                        description = {symbol + "(" + $0 + ")"}
                    }
                    descriptionAccumulator = description!(descriptionAccumulator!)
                }
            case .binaryOperation(let function, var description, let priority, let validator):
                if isSetOperand {
                    iteration = 0
                    performPendingBinaryOperation()
                    
                }
                if accumulator != nil {
                    if description == nil {
                        description = {$0 + " " + symbol + " " + $1}
                    }
                    if currentPriority < priority && iteration<1 {
                        descriptionAccumulator = "(\(descriptionAccumulator!))"
                        iteration += 1
                        
                    }
                    currentPriority = priority
                    pending = PendingBinaryOperation(function: function, description: description!, firstOperand: accumulator!, descriptionOperand: descriptionAccumulator!, validator: validator)
                    
                    //accumulator = nil
                    //descriptionAccumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
                
            }
        }
        isSetOperand = false
        
    }
    
    mutating func performPendingBinaryOperation() {
        if resultIsPending && accumulator != nil {
            error = pending!.performValidate(with: accumulator!)
            accumulator = pending!.perform(with: accumulator!)
            descriptionAccumulator = pending!.performDescription(with: descriptionAccumulator!)
            
            pending = nil
        }
    }
    
    func performPrecentOperation(_ secondValue: Double) -> Double {
        if resultIsPending {
            let firstValue = pending!.firstOperand/100
            return firstValue*secondValue
            
        }
        return secondValue/100
    
    }
    
    mutating func clear() {
        accumulator = nil
        currentPriority = Int.max
        descriptionAccumulator = nil
        error = nil
        pending = nil
        
    }
}

private struct PendingBinaryOperation {
    let function: (Double, Double)->Double
    var description: (String, String)->String
    let firstOperand: Double
    var descriptionOperand: String
    let validator: ((Double, Double)->String?)?
    
    func perform(with secondOperand: Double) -> Double {
        return function(firstOperand, secondOperand)
    }
    func performDescription(with secondOperand: String) -> String {
        return description(descriptionOperand, secondOperand)
    }
    func performValidate(with secondOperand: Double) -> String? {
        return validator?(firstOperand, secondOperand)
    }
    
}

let decimalFormatter:NumberFormatter = {
    let decimalFormatter = NumberFormatter()
    decimalFormatter.numberStyle = .decimal
    //decimalFormatter.maximumFractionDigits = 9
    decimalFormatter.notANumberSymbol =  "Error"
    decimalFormatter.decimalSeparator = "."
    decimalFormatter.groupingSeparator = " "
    return decimalFormatter
    
} ()

let scientificFormatter:NumberFormatter = {
    let scientificFormatter = NumberFormatter()
    scientificFormatter.numberStyle = .scientific
    //scientificFormatter.maximumFractionDigits = 9
    scientificFormatter.notANumberSymbol =  "Error"
    scientificFormatter.decimalSeparator = "."
    return scientificFormatter
    
} ()
