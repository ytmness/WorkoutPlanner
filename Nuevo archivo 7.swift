import SwiftUI
struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var tipo: String
    var descripcion: String?
    
    init(name: String, tipo: String, descripcion: String? = nil) {
        self.id = UUID()
        self.name = name
        self.tipo = tipo
        self.descripcion = descripcion
    }
}
