//
//  CalculatorModel.swift
//  calculator
//
//  Created by Matthew Bresnan on 8/8/17.
//  Copyright © 2017 Matthew Bresnan. All rights reserved.
//

import Foundation

struct CalculatorModel {
    private var accumulator: Double?
    
    private var pendingBinaryOp: PendingBinaryOperation?
    
    private var variables: Dictionary<String, Double> = [:]
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var description: String = ""

    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOp != nil
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "sin": Operation.unaryOperation(sin),
        "cos": Operation.unaryOperation(cos),
        "tan": Operation.unaryOperation(tan),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "*": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "=": Operation.equals,
        "CLR": Operation.clear
    ]
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOp != nil && accumulator != nil {
            accumulator = pendingBinaryOp!.perform(with: accumulator!)
            pendingBinaryOp = nil
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    mutating func setOperand(variable named: String) {
        //TODO
    }
    
    
    mutating func updateDescription(with symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant:
                description += "\(symbol)"
            case .unaryOperation:
                description =  "\(symbol)(\(description))"
            case .binaryOperation:
                if pendingBinaryOp != nil {
                    description += " \(symbol) "
                }
            case .equals:
                break
            case .clear:
                description = ""
            }
        } else {
            description += symbol
        }
        print(description)
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                updateDescription(with: symbol)
            case .unaryOperation(let function):
                if accumulator != 0 {
                    accumulator = function(accumulator!)
                    pendingBinaryOp = nil
                    updateDescription(with: symbol)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOp = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
                updateDescription(with: symbol)
            case .equals:
                performPendingBinaryOperation()
                pendingBinaryOp = nil
                updateDescription(with: symbol)
            case .clear:
                pendingBinaryOp = nil
                accumulator = 0
                updateDescription(with: symbol)
            }

        }
    }

    

}
