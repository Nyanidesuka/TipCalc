//
//  TipCalcViewController.swift
//  TipCalc
//
//  Created by Haley Jones on 6/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class TipCalcViewController: UIViewController {
    
    //MARK: Properties
    var billWhole: Int = 0
    var billChangeString = ""
    var billChange: Int {
        if billChangeString.count < 2{
            while billChangeString.count < 2{
                billChangeString += "0"
            }
        }
        guard let returnValue = Int(billChangeString) else {return 0}
        return returnValue
    }
    var billDouble: Double{
        return Double(billWhole) + (Double(billChange) / 100)
    }
    var tipAmmount: Double = 0.0
    var tipPercent: Int = 0
    var total: Double = 0.0
    var inDecimal = false
    var tipMode = false //are we in tip mode or are we still entering the bill
    //new stuff to enable splitting the bill with frenz (or enemies)
    var splitMode = false
    var splitFriends = 1
    var splitPerPerson: Double {
        return Double((billDouble + tipAmmount) / Double(splitFriends)).rounded(digits: 2)
    }
    

    //MARK: - Outlets
    
    @IBOutlet weak var operationLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearEverything()
    }
    
    //MARK: - The function that adds to the total
    func addNumberToBill(number: Int){
        //because i'm using Ints to make things accurate we need to know if we're in the change or not
        if inDecimal == false{
            var editingString = String(billWhole)
            if editingString != "0"{
                editingString += String(number)
                guard let newBillWhole = Int(editingString) else {return}
                billWhole = newBillWhole
            } else {
                editingString = String(number)
                guard let newBillWhole = Int(editingString) else {return}
                billWhole = newBillWhole
            }
        } else {
            if billChangeString.count < 2{
                billChangeString += String(number)
            }
        }
        self.updateViews()
    }
    
    func updateViews(){
        if !tipMode{
            if !inDecimal{
                self.moneyLabel.text = "$\(billWhole)"
            } else {
                print("we are in the decimal, lads")
                self.moneyLabel.text = "$\(billWhole).\(billChangeString)"
            }
            if !splitMode{
                totalLabel.text = ""
            } else {
                totalLabel.text = "Total: $\(splitPerPerson) each"
            }
            operationLabel.text = ""
            self.tipLabel.text = "Bill Total:"
        } else {
            let tipString = addZeros(toNumber: String(tipAmmount))
            let totalString = addZeros(toNumber: String(Double(billDouble + tipAmmount).rounded(digits: 2)))
            moneyLabel.text = "$\(tipString)"
            if !splitMode{
                totalLabel.text = "Total: $\(totalString)"
            } else {
                totalLabel.text = "Total: $\(splitPerPerson) each"
            }
            self.tipLabel.text = "Tip:"
        }
        if splitMode{
            splitLabel.text = "Split \(splitFriends) ways"
        } else {
            splitLabel.text = ""
        }
    }
    
    func addZeros(toNumber number: String) -> String{
        var returnString = number
        let index = returnString.firstIndex(of: ".")?.encodedOffset ?? returnString.count - 1
        let lastIndex = returnString.count - 1
            if lastIndex - index < 2{
                while (returnString.count - 1) - index < 2{
                returnString += "0"
            }
        }
        return returnString
    }
    
    func clearEverything(){
        billWhole = 0
        billChangeString = ""
        inDecimal = false
        tipMode = false
        splitFriends = 1
        splitMode = false
        self.tipLabel.text = ""
        self.splitLabel.text = ""
        self.updateViews()
    }
    
    //MARK: - Button Actions
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        clearEverything()
    }
    
    @IBAction func numberButtonTapped(sender: UIButton){
        if !tipMode{
            addNumberToBill(number: sender.tag)
        } else {
            clearEverything()
            addNumberToBill(number: sender.tag)
        }
    }
    
    //time to do math
    @IBAction func tipButtonTapped(sender: UIButton){
        tipMode = true
        var percent:Double = 0
        if sender.tag != 69{
            percent = Double(sender.tag) / 100
            tipPercent = sender.tag
            calculateTip(percent: percent)
        } else {
            let customTipAlert = UIAlertController(title: "Enter custom tip percentage:", message: nil, preferredStyle: .alert)
            customTipAlert.addTextField { (textField) in
                textField.keyboardType = .numberPad
                textField.placeholder = "Tip percentage"
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
                self.tipMode = false
                customTipAlert.dismiss(animated: true, completion: {
                    //
                })
                return
            }
            let enterAction = UIAlertAction(title: "Set", style: .default) { (_) in
                guard var tipText = customTipAlert.textFields?[0].text else {return}
                guard let tipPercent = Double(tipText)else {return}
                print(tipPercent)
                self.tipPercent = Int(tipPercent)
                percent = tipPercent / Double(100)
                self.calculateTip(percent: percent)
                customTipAlert.dismiss(animated: true, completion: {
                    //
                })
            }
            customTipAlert.addAction(enterAction)
            customTipAlert.addAction(cancelAction)
            self.present(customTipAlert, animated: true) {
                //
            }
        }
    }
    
    func calculateTip(percent: Double){
        if billChangeString.count < 2{
            while billChangeString.count < 2{
                billChangeString += "0"
            }
        }
        var tipDouble = billDouble * percent
        tipAmmount = tipDouble.rounded(digits: 2)
        operationLabel.text = "\(billDouble) * \(percent) ="
        self.updateViews()
    }
    
    @IBAction func unsplitButtonTapped(_ sender: Any) {
        self.splitMode = false
        self.splitFriends = 1
        self.updateViews()
    }
    
    @IBAction func dotButtonTapped(_ sender: Any) {
        if inDecimal == false{
            inDecimal = true
        }
        self.updateViews()
    }
    
    @IBAction func receiptButtonTapped(_ sender: Any) {
        var message = ""
        message += "\n Subtotal: $\(addZeros(toNumber: String(billDouble)))\n \n"
        if (tipMode){
            message += "Tip: $\(tipAmmount) (\(self.tipPercent)%)\n \n"
            message += "Total: $\(Double(billDouble + tipAmmount).rounded(digits: 2))\n \n"
        }
        if splitMode{
            message += "Split between \(splitFriends) parties \n \n"
            message += "$\(splitPerPerson) each (rounded up)"
        }
        let receiptAlert = UIAlertController(title: "Detailed Total", message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .destructive) { (_) in
            //
        }
        receiptAlert.addAction(closeAction)
        self.present(receiptAlert, animated: true) {
            //
        }
    }
    
    
    //Splitskies
    @IBAction func splitButtonPressed(_ sender: UIButton) {
        //so what we gotta do is present a little notification to ask them how many ways they wanna split
        let splitAlert = UIAlertController(title: "Split the bill", message: nil, preferredStyle: .alert)
        splitAlert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Number of parties"
        }
        let splitAction = UIAlertAction(title: "Split", style: .default) { (action) in
            guard let splitString = splitAlert.textFields?[0].text else {return}
            if splitString.contains(where: {!"0123456789".contains($0)}) || !splitString.contains(where: {"123456789".contains($0)}){
                let characterAlert = UIAlertController(title: "Woah there.", message: "This field only wants numbers, and it's gotta be at least 1.", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Got it.", style: .destructive, handler: { (_) in
                    self.present(splitAlert, animated: true, completion: {
                        //
                    })
                })
                characterAlert.addAction(closeAction)
                self.present(characterAlert, animated: true, completion: {
                    DispatchQueue.main.async {
                        guard let textField = splitAlert.textFields?[0] else {return}
                        textField.text = ""
                    }
                })
            } else {
                self.splitFriends = Int(splitString) ?? 0
                self.splitMode = true
                splitAlert.dismiss(animated: true, completion: {
                    //
                })
            }
            self.updateViews()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            //
        }
        splitAlert.addAction(splitAction)
        splitAlert.addAction(cancelAction)
        self.present(splitAlert, animated: true) {
            //
        }
    }
}
