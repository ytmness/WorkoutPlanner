import SwiftUI
import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @AppStorage("weightUnit") var weightUnitRaw: String = WeightUnit.kg.rawValue
    
    var weightUnit: WeightUnit {
        get { WeightUnit(rawValue: weightUnitRaw) ?? .kg }
        set { weightUnitRaw = newValue.rawValue }
    }
}
