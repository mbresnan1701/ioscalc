//
//  CalculatorModel.swift
//  calculator
//
//  Created by Matthew Bresnan on 8/8/17.
//  Copyright © 2017 Matthew Bresnan. All rights reserved.
//

import Foundation

struct CalculatorModel {
//    private var variables: Dictionary<String, Double> = [:]
    
    @available(*, deprecated, message: "no longer needed ...")
    var description: String? {
        return evaluate().description
    }
    
    @available(*, deprecated, message: "no longer needed ...")
    var result: Double? {
        get {
            return evaluate().result
        }
    }
    
    @available(*, deprecated, message: "no longer needed ...")
    var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }
    
    private var opStack = [Element]()
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "sin": Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "cos": Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "tan": Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "+": Operation.binaryOperation(+, { $0 + "+" + $1 }),
        "-": Operation.binaryOperation(-, { $0 + "-" + $1 }),
        "x": Operation.binaryOperation(*, { $0 + "X" + $1 }),
        "÷": Operation.binaryOperation(/, { $0 + "/" + $1 }),
        "=": Operation.equals
    ]
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private enum Element {
        case variable(String)
        case operation(String)
        case operand(Double)
    }
    
    mutating func setOperand(_ operand: Double) {
        opStack.append(Element.operand(operand))
    }
    
    mutating func setOperand(variable named: String) {
        opStack.append(Element.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
        opStack.append(Element.operation(symbol))
    }
    
    mutating func popOperationStack() {
        if(opStack.count > 0) {
            opStack.removeLast()
        }
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let firstOperand: (Double, String)
            let description: (String, String) -> String
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        var accumulator: (Double, String)?
        
        var pendingBinaryOp: PendingBinaryOperation?
        
        var description: String? {
            if pendingBinaryOp != nil {
                return pendingBinaryOp!.description(pendingBinaryOp!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }
        }
        
        var result: Double? {
            if accumulator != nil {
                return accumulator!.0
            }
            return nil
        }
        
        var resultIsPending: Bool {
            get {
                return pendingBinaryOp != nil
            }
        }

        func performPendingBinaryOperation() {
            if pendingBinaryOp != nil && accumulator != nil {
                accumulator = pendingBinaryOp!.perform(with: accumulator!)
                pendingBinaryOp = nil
            }
        }
        
        for element in opStack {
            switch element {
            case .operand(let value):
                if accumulator != nil {
                    accumulator = (value, "\(accumulator!.1)")
                } else {
                    accumulator = (value, "\(value)")
                }
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, "\(value)")
                    case .unaryOperation(let function, let description):
                        if accumulator != nil {
                            accumulator = (function(accumulator!.0), description(accumulator!.1))
                            pendingBinaryOp = nil
                        }
                    case .binaryOperation(let function, let description):
                        performPendingBinaryOperation()
                        if accumulator != nil {
                            pendingBinaryOp = PendingBinaryOperation(function: function, firstOperand: accumulator!, description: description)
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    }
                }
            case .variable(let symbol):
                if let value = variables?[symbol] {
                    accumulator = (value, "\(symbol)")
                } else {
                    accumulator = (0, "\(symbol)")
                }
                
            }
        }
        return (result, pendingBinaryOp != nil, description ?? "")
        
    }

}
