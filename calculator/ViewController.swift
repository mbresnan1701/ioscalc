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
        if userTyping {
            if let currentText = display.text {
                if digit == "." {
                    if currentText.range(of:".") == nil {
                        display.text = currentText + digit
//                        calcModel.updateDescription(with: digit)
                        setDescriptionLabel(with: "\(calcModel.description!) + \(digit) ")
                    }
                } else {
                    display.text = currentText + digit
                    setDescriptionLabel(with: "\(calcModel.description!) + \(digit) ")
                }
            }
        } else {
            display.text = digit
            userTyping = true
            setDescriptionLabel(with: "\(calcModel.description!) + \(digit) ")
        }
        setDescriptionLabel(with: calcModel.description!)
    }
    
    @IBAction func pressOperation(_ sender: UIButton) {
        if userTyping {
            calcModel.setOperand(displayValue)
            userTyping = false
        }
        if let symbol = sender.currentTitle {
            calcModel.performOperation(symbol)
        }
        if let result = calcModel.result {
            displayValue = result
        }
        setDescriptionLabel(with: calcModel.description!)
    }
    
    func setDescriptionLabel(with description: String) {
        if calcModel.resultIsPending {
            descriptionLabel.text = description + " ..."
        } else {
            descriptionLabel.text = description + " ="
        }
    }
}

