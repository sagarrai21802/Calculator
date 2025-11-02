//
//  ViewController.swift
//  Calculator
//
//  Created by Apple on 18/10/25.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var Labelfordisplay: UILabel!

    // Calculator state
    private var currentValue: Double = 0
    private var pendingOperation: String? = nil // "+", "-", "×", "÷"
    private var shouldResetDisplayOnNextDigit = false

    private var displayText: String {
        get { Labelfordisplay.text ?? "0" }
        set { Labelfordisplay.text = newValue }
    }

    private func appendDigit(_ digit: String) {
        let current = displayText
        if shouldResetDisplayOnNextDigit || current == "0" || current.isEmpty {
            displayText = digit == "." ? "0." : digit
            shouldResetDisplayOnNextDigit = false
        } else {
            if digit == "." {
                if !current.contains(".") { displayText = current + "." }
            } else {
                displayText = current + digit
            }
        }
    }

    private func setOperation(_ op: String) {
        // Commit any current display to currentValue
        if let value = Double(displayText) {
            if pendingOperation == nil {
                currentValue = value
            } else {
                // Chain operations: compute with existing pending op first
                currentValue = compute(lhs: currentValue, rhs: value, op: pendingOperation!)
                displayText = format(currentValue)
            }
        }
        pendingOperation = op
        shouldResetDisplayOnNextDigit = true
    }

    private func computeEquals() {
        guard let op = pendingOperation, let rhs = Double(displayText) else { return }
        let result = compute(lhs: currentValue, rhs: rhs, op: op)
        displayText = format(result)
        currentValue = result
        pendingOperation = nil
        shouldResetDisplayOnNextDigit = true
    }

    private func compute(lhs: Double, rhs: Double, op: String) -> Double {
        switch op {
        case "+": return lhs + rhs
        case "-": return lhs - rhs
        case "*", "x", "X": return lhs * rhs
        case "÷", "/": return rhs == 0 ? Double.nan : lhs / rhs
        default: return rhs
        }
    }

    private func clearAll() {
        currentValue = 0
        pendingOperation = nil
        shouldResetDisplayOnNextDigit = false
        displayText = "0"
    }

    private func toggleSign() {
        if var value = Double(displayText) {
            value = -value
            displayText = format(value)
        }
    }

    private func percent() {
        if let value = Double(displayText) {
            displayText = format(value / 100.0)
            shouldResetDisplayOnNextDigit = true
        }
    }

    private func format(_ value: Double) -> String {
        if value.isNaN || value.isInfinite { return "Error" }
        let intPart = Int64(value)
        if value == Double(intPart) {
            return String(intPart)
        } else {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 10
            formatter.minimumFractionDigits = 0
            formatter.minimumIntegerDigits = 1
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false
            return formatter.string(from: NSNumber(value: value)) ?? String(value)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Labelfordisplay.text = "0"
    }

    @IBAction func numebrbuttonpressed(_ sender : UIButton){
        guard let number = sender.titleLabel?.text else { return }
        // Accept digits 0-9 and decimal point
        if number == "." {
            appendDigit(".")
        } else {
            appendDigit(number)
        }
        print("Tapped number: \(number), display: \(Labelfordisplay.text ?? "")")
    }

    
    @IBAction func operationnumberpreseed(_ sender : UIButton){
        guard let operation = sender.titleLabel?.text else { return }
        print("DEBUG: Operation title is [\(operation)]")
        switch operation {
        case "+", "-", "×", "x", "*", "÷", "/":
            setOperation(operation)
        case "=":
            computeEquals()
        case "AC", "C":
            clearAll()
        case "+/-":
            toggleSign()
        case "%":
            percent()
        default:
            print("Unhandled operation: \(operation)")
        }
        print("Operation: \(operation), display: \(Labelfordisplay.text ?? "")")
    }
}

