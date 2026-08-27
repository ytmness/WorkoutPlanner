import SwiftUI

struct AddWorkoutView: View {
    
    @ObservedObject var vm: WorkoutViewModel
    @EnvironmentObject var exerciseVM: ExerciseViewModel
    @EnvironmentObject var settings: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedExerciseID: UUID? = nil
    @State private var peso: String = ""
    @State private var reps: String = ""
    @State private var series: String = ""
    
    @State private var inputUnit: WeightUnit = .kg // 🔥 LOCAL
    
    @State private var showAlert = false
    
    var existingWorkout: Workout? = nil
    
    var body: some View {
        Form {
            
            Section(header: Text("Workout Info")) {
                
                NavigationLink("➕ Create Exercise") {
                    AddExerciseView()
                }
                
                Picker("Exercise", selection: $selectedExerciseID) {
                    Text("Select exercise").tag(UUID?.none)
                    
                    ForEach(exerciseVM.exercises) { ex in
                        Text(ex.name).tag(Optional(ex.id))
                    }
                }
                
                // 🔥 SELECTOR DE UNIDAD (AQUÍ ESTABA EL PEDO)
                Picker("Unidad", selection: $inputUnit) {
                    Text("kg").tag(WeightUnit.kg)
                    Text("lb").tag(WeightUnit.lb)
                }
                .pickerStyle(.segmented)
                
                TextField("Peso (\(inputUnit.rawValue))", text: $peso)
                    .keyboardType(.decimalPad)
                
                TextField("Reps", text: $reps)
                    .keyboardType(.numberPad)
                
                TextField("Series", text: $series)
                    .keyboardType(.numberPad)
            }
            
            Button("Guardar") {
                guardarWorkout()
            }
            
            if existingWorkout != nil {
                Button("Delete Workout", role: .destructive) {
                    deleteWorkout()
                }
            }
        }
        .navigationTitle(existingWorkout == nil ? "New Workout" : "Edit Workout")
        .alert("Éxito", isPresented: $showAlert) {
            Button("OK") {
                limpiarCampos()
                dismiss()
            }
        } message: {
            Text("Saved successfully")
        }
        .onAppear {
            cargarDatos()
        }
    }
    
    // MARK: - LOGIC
    
    func guardarWorkout() {
        guard let id = selectedExerciseID,
              let ex = exerciseVM.exercises.first(where: { $0.id == id }) else {
            return
        }
        
        let inputPeso = Double(peso) ?? 0
        
        // 🔥 CONVERSIÓN CORRECTA
        let pesoEnKg = inputUnit == .kg
        ? inputPeso
        : lbToKg(inputPeso)
        
        if var w = existingWorkout {
            w.exerciseId = ex.id
            w.ejercicioNombre = ex.name
            w.ejercicio = ex.name
            w.tipo = ex.tipo
            w.peso = pesoEnKg
            w.repeticiones = Int(reps) ?? 0
            w.series = Int(series) ?? 0
            
            vm.updateWorkout(w)
            
        } else {
            let workout = Workout(
                ejercicio: ex.name,
                exerciseId: ex.id,
                ejercicioNombre: ex.name,
                peso: pesoEnKg,
                repeticiones: Int(reps) ?? 0,
                series: Int(series) ?? 0,
                tipo: ex.tipo
            )
            
            vm.addWorkout(workout)
        }
        
        showAlert = true
    }
    
    func cargarDatos() {
        inputUnit = settings.weightUnit // 🔥 usa preferencia inicial
        
        if let w = existingWorkout {
            selectedExerciseID = w.exerciseId
            reps = String(w.repeticiones)
            series = String(w.series)
            
            // 🔥 convertir para mostrar
            if inputUnit == .kg {
                peso = String(w.peso)
            } else {
                peso = String(kgToLb(w.peso))
            }
        }
    }
    
    func limpiarCampos() {
        peso = ""
        reps = ""
        series = ""
        selectedExerciseID = nil
    }
    
    func deleteWorkout() {
        guard let workout = existingWorkout else { return }
        vm.deleteWorkout(workout)
        dismiss()
    }
}
