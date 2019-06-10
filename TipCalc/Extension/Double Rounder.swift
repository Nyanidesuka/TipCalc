//
//  Double Rounder.swift
//  TipCalc
//
//  Created by Haley Jones on 6/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation

extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}
