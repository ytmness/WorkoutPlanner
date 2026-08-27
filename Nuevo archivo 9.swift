import SwiftUI
import SwiftUI

struct AddExerciseView: View {
    
    @EnvironmentObject var exerciseVM: ExerciseViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var tipo = "Chest"
    @State private var descripcion = ""
    
    let tipos = ["Chest", "Back", "Legs", "Arms", "Shoulders"]
    
    var body: some View {
        Form {
            TextField("Exercise Name", text: $name)
            
            Picker("Type", selection: $tipo) {
                ForEach(tipos, id: \.self) {
                    Text($0)
                }
            }
            
            TextField("Description (optional)", text: $descripcion)
            
            Button("Save Exercise") {
                let new = Exercise(
                    name: name,
                    tipo: tipo,
                    descripcion: descripcion
                )
                
                exerciseVM.addExercise(new)
                dismiss()
            }
        }
        .navigationTitle("New Exercise")
    }
}
