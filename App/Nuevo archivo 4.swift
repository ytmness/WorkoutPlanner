import SwiftUI

struct Workout: Identifiable, Codable, Hashable {
    let id: UUID
    
    // 🔴 viejo (mantener temporalmente)
    var ejercicio: String
    
    // 🔥 nuevo
    var exerciseId: UUID
    var ejercicioNombre: String
    
    var peso: Double
    var repeticiones: Int
    var series: Int
    var fecha: Date
    var tipo: String
    
    init(
        ejercicio: String,
        exerciseId: UUID,
        ejercicioNombre: String,
        peso: Double,
        repeticiones: Int,
        series: Int,
        tipo: String
    ) {
        self.id = UUID()
        
        // 🔴 viejo
        self.ejercicio = ejercicio
        
        // 🔥 nuevo
        self.exerciseId = exerciseId
        self.ejercicioNombre = ejercicioNombre
        
        self.peso = peso
        self.repeticiones = repeticiones
        self.series = series
        self.fecha = Date()
        self.tipo = tipo
    }
}
