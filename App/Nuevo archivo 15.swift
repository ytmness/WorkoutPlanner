import SwiftUI
func kgToLb(_ kg: Double) -> Double {
    kg * 2.20462
}

func lbToKg(_ lb: Double) -> Double {
    lb / 2.20462
}
func displayWeight(_ kg: Double, unit: WeightUnit) -> String {
    if unit == .kg {
        return "\(Int(kg)) kg"
    } else {
        return "\(Int(kgToLb(kg))) lb"
    }
}
