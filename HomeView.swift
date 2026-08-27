import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var exerciseVM: ExerciseViewModel 
    @StateObject var vm: WorkoutViewModel
    @EnvironmentObject var settings: SettingsViewModel
    
    @State private var animateCards = false
    @State private var animateChart = false
    @State private var pressButton = false
    @State private var goToWorkout = false
    @State private var weekOffset = 0
    @State private var selectedWorkout: Workout?
    @State private var selectedTipo: String? = nil
    @State private var selectedDay: String? = nil
    @State private var selectedExerciseDetail: Exercise?
    
    // 🔥 STREAK
    @State private var lastStreak = 0
    @State private var showStreakAnimation = false
    @State private var confettiTrigger = 0
    
    // 🔥 HEATMAP
    @State private var selectedHeatmapDate: Date?
    @State private var showHeatmapSheet = false
    
    init(session: SessionManager) {
        _vm = StateObject(
            wrappedValue: WorkoutViewModel(userEmail: session.userEmail)
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 🔥 HEADER PRO
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back")
                                .foregroundColor(.gray)
                                .font(.caption)
                            
                            Text(session.userName)
                                .font(.title2)
                                .bold()
                            
                            Text("Ready to train today?")
                                .foregroundColor(.gray)
                                .font(.caption2)
                        }
                        
                        Spacer()
                        
                        Menu {
                            Section {
                                Button("kg") { settings.weightUnit = .kg }
                                Button("lb") { settings.weightUnit = .lb }
                            }
                            
                            Section {
                                Button(role: .destructive) {
                                    session.isLoggedIn = false
                                    session.userEmail = ""
                                } label: {
                                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            }
                            
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title3)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .opacity(animateCards ? 1 : 0)
                    .offset(y: animateCards ? 0 : 20)
                    
                    
                    // 🔥 STREAK
                    let streak = WorkoutStreak.currentStreak(workouts: vm.workouts)
                    
                    StreakView(streak: streak)
                        .scaleEffect(showStreakAnimation ? 1.1 : 1)
                        .animation(.spring(), value: showStreakAnimation)
                    
                    
                    // 🔥 HEATMAP
                    HeatmapView(workouts: vm.workouts) { date in
                        selectedHeatmapDate = date
                        showHeatmapSheet = true
                    }
                    
                    
                    // 🔥 CHART
                    VStack(alignment: .leading, spacing: 10) {
                        
                        HStack {
                            Button {
                                withAnimation { weekOffset -= 1 }
                            } label: {
                                Image(systemName: "chevron.left")
                            }
                            
                            Spacer()
                            
                            VStack(spacing: 2) {
                                Text("Weekly Volume")
                                    .font(.headline)
                                
                                Text(rangoSemana())
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation { weekOffset += 1 }
                            } label: {
                                Image(systemName: "chevron.right")
                            }
                        }
                        
                        WeeklyChartView(
                            data: volumenPorDiaYTipo(filtro: selectedTipo),
                            onDayTap: { day in
                                withAnimation(.easeInOut) {
                                    selectedDay = (selectedDay == day) ? nil : day
                                }
                            }
                        )
                        .overlay(alignment: .bottom) {
                            if let selectedDay {
                                GeometryReader { geo in
                                    let index = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
                                        .firstIndex(of: selectedDay) ?? 0
                                    
                                    let width = geo.size.width / 7
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.green, lineWidth: 2)
                                        .frame(width: width * 0.6, height: 110)
                                        .offset(x: width * CGFloat(index) + width * 0.2)
                                        .animation(.easeInOut, value: selectedDay)
                                }
                            }
                        }
                        .scaleEffect(animateChart ? 1 : 0.8)
                        .opacity(animateChart ? 1 : 0)
                        
                        HStack(spacing: 12) {
                            legendItem(color: .red, label: "Chest", tipo: "Chest")
                            legendItem(color: .blue, label: "Back", tipo: "Back")
                            legendItem(color: .orange, label: "Legs", tipo: "Legs")
                            legendItem(color: .purple, label: "Arms", tipo: "Arms")
                            legendItem(color: .green, label: "Shoulders", tipo: "Shoulders")
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .opacity(animateCards ? 1 : 0)
                    .offset(y: animateCards ? 0 : 20)
                    
                    
                    // 🔥 WORKOUTS DEL DÍA
                    if let day = selectedDay {
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Text("Workouts on \(day)")
                                .font(.headline)
                            
                            let workouts = workoutsForSelectedDay(day)
                            
                            if workouts.isEmpty {
                                Text("No workouts")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(workouts) { workout in
                                    workoutCard(workout, unit: settings.weightUnit)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    
                    // 🔥 LISTA
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("Recent Workouts")
                            .font(.headline)
                        
                        if vm.workouts.isEmpty {
                            Text("Start your first workout")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(Array(vm.workouts.reversed())) { workout in
                                workoutCard(workout, unit: settings.weightUnit)
                                    .onTapGesture {
                                        if let ex = exerciseVM.exercises.first(where: { $0.id == workout.exerciseId }) {
                                            selectedExerciseDetail = ex
                                        }
                                    }
                                    .contextMenu {
                                        Button("Edit") {
                                            selectedWorkout = workout
                                        }
                                        
                                        Button(role: .destructive) {
                                            vm.deleteWorkout(workout)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    
                    
                    // 🔥 BOTÓN
                    Button {
                        pressButton = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            pressButton = false
                            goToWorkout = true
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("START WORKOUT")
                                    .font(.headline)
                                    .bold()
                                
                                Text("Track your progress")
                                    .font(.caption)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .foregroundColor(.black)
                    }
                    
                    NavigationLink(
                        destination: AddWorkoutView(vm: vm),
                        isActive: $goToWorkout
                    ) { EmptyView() }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .foregroundColor(.white)
            
            .navigationDestination(item: $selectedWorkout) { workout in
                AddWorkoutView(vm: vm, existingWorkout: workout)
            }
            .navigationDestination(item: $selectedExerciseDetail) { exercise in
                ExerciseDetailView(exercise: exercise, vm: vm)
            }
            
            // 🔥 SHEET HEATMAP
            .sheet(isPresented: $showHeatmapSheet) {
                if let date = selectedHeatmapDate {
                    HeatmapDetailView(
                        date: date,
                        workouts: vm.workouts,
                        unit: settings.weightUnit
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCards = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateChart = true
            }
            
            lastStreak = WorkoutStreak.currentStreak(workouts: vm.workouts)
            
            StreakNotificationManager.scheduleIfNeeded(workouts: vm.workouts)
        }
        .onChange(of: vm.workouts.count) { _ in
            
            let newStreak = WorkoutStreak.currentStreak(workouts: vm.workouts)
            
            if newStreak > lastStreak {
                showStreakAnimation = true
                confettiTrigger += 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showStreakAnimation = false
                }
            }
            
            lastStreak = newStreak
        }
    }
    
    // MARK: HELPERS
    
    func workoutsForSelectedDay(_ day: String) -> [Workout] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        let calendar = Calendar.current
        let today = Date()
        
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today),
              let weekInterval = calendar.dateInterval(of: .weekOfYear, for: targetDate) else {
            return []
        }
        
        return vm.workouts.filter { w in
            w.fecha >= weekInterval.start &&
            w.fecha < weekInterval.end &&
            formatter.string(from: w.fecha) == day
        }
    }
    
    func volumenPorDiaYTipo(filtro: String? = nil) -> [String: [String: Double]] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        let today = Date()
        
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today),
              let weekInterval = calendar.dateInterval(of: .weekOfYear, for: targetDate) else {
            return [:]
        }
        
        var result: [String: [String: Double]] = [:]
        
        for w in vm.workouts {
            if w.fecha >= weekInterval.start && w.fecha < weekInterval.end {
                if let filtro = filtro, w.tipo != filtro { continue }
                
                let day = formatter.string(from: w.fecha)
                let volumen = w.peso * Double(w.repeticiones * w.series)
                
                result[day, default: [:]][w.tipo, default: 0] += volumen
            }
        }
        
        return result
    }
    
    func rangoSemana() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let today = Date()
        
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today),
              let weekInterval = calendar.dateInterval(of: .weekOfYear, for: targetDate)
        else { return "" }
        
        let start = formatter.string(from: weekInterval.start)
        let endDate = calendar.date(byAdding: .day, value: -1, to: weekInterval.end) ?? weekInterval.end
        let end = formatter.string(from: endDate)
        
        return "\(start) - \(end)"
    }
    
    func legendItem(color: Color, label: String, tipo: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.caption2)
        }
        .foregroundColor(
            selectedTipo == nil || selectedTipo == tipo ? .white : .gray
        )
        .opacity(
            selectedTipo == nil || selectedTipo == tipo ? 1 : 0.4
        )
        .onTapGesture {
            selectedTipo = (selectedTipo == tipo) ? nil : tipo
        }
    }
}
