//
//  ViewController.swift
//  calculator
//
//  Created by Matthew Bresnan on 8/8/17.
//  Copyright © 2017 Matthew Bresnan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var userTyping = false
    
    private var memVariables: Dictionary<String, Double> = [:]
    
    private var calcModel = CalculatorModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let evaluated = calcModel.evaluate()

        if userTyping {
            if let currentText = display.text {
                if digit == "." {
                    if currentText.range(of:".") == nil {
                        display.text = currentText + digit
                        setDescriptionLabel(with: "\(evaluated.description) + \(digit) ")
                    }
                } else {
                    display.text = currentText + digit
                    setDescriptionLabel(with: "\(evaluated.description) + \(digit) ")
                }
            }
        } else {
            display.text = digit
            userTyping = true
            setDescriptionLabel(with: "\(evaluated.description) + \(digit) ")
        }
        setDescriptionLabel(with: evaluated.description)
    }
    
    @IBAction func clear(_ sender: UIButton) {
        
        calcModel = CalculatorModel()
        displayValue = 0
        descriptionLabel.text = " "
        userTyping = false
        memVariables = [:]
    }
    
    @IBAction func pressOperation(_ sender: UIButton) {
        var evaluated = calcModel.evaluate(using: memVariables)
        if userTyping {
            calcModel.setOperand(displayValue)
            userTyping = false
        }
        if let symbol = sender.currentTitle {
            calcModel.performOperation(symbol)
            evaluated = calcModel.evaluate(using: memVariables)
        }
        if let result = evaluated.result {
            displayValue = result
        }
        setDescriptionLabel(with: evaluated.description)
    }
    
    @IBAction func memoryButtonPressed(_ sender: UIButton) {
        if sender.currentTitle == "→M" {
            memVariables["M"] = displayValue
            if let evalResult = calcModel.evaluate(using: memVariables).result {
                displayValue = evalResult
            }
        } else {
            calcModel.setOperand(variable: "M")
            if let evalResult = calcModel.evaluate(using: memVariables).result {
                displayValue = evalResult
            }
        }
    }
    
    func setDescriptionLabel(with description: String) {
        let evaluated = calcModel.evaluate()

        if evaluated.isPending {
            descriptionLabel.text = description + " ..."
        } else {
            descriptionLabel.text = description + " ="
        }
    }
}

