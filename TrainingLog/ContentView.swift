//
//  ContentView.swift
//  TrainingLog
//
//  Created by Andrew Mitchell on 4/7/26.
//

import SwiftUI
import Observation
import Charts
internal import Combine

extension Color {
    static let appBackground = Color(red: 0.07, green: 0.08, blue: 0.09)
    static let appCard = Color(red: 0.13, green: 0.14, blue: 0.16)
    static let appCardSecondary = Color(red: 0.18, green: 0.19, blue: 0.22)

    static let appPrimary = Color(red: 0.28, green: 0.45, blue: 0.62)
    static let appAccent = Color(red: 0.90, green: 0.38, blue: 0.14)

    static let appTextPrimary = Color.white
    static let appTextSecondary = Color(red: 0.72, green: 0.75, blue: 0.78)
}
struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.appCard)
            .cornerRadius(18)
    }
}

extension View {
    func appCard() -> some View {
        self.modifier(AppCardModifier())
    }
}

struct WorkoutSetEntry: Identifiable, Codable {
    let id: UUID
    let setNumber: Int
    let weight: String
    let reps: String
    let rpe: String
}

struct WorkoutHistoryEntry: Identifiable, Codable {
    let id: UUID
    let workoutTitle: String
    let date: Date
    let exercise: String
    let details: String
    let sets: [WorkoutSetEntry]
    
    var totalReps: Int {
        sets.compactMap { Int($0.reps) }.reduce(0, +)
    }
    
    var totalVolume: Double {
        sets.reduce(0) { total, set in
            let weight = Double(set.weight) ?? 0
            let reps = Double(set.reps) ?? 0
            return total + (weight * reps)
        }
    }
}
struct ExerciseItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let details: String
    let notes: String
    var setCount: Int
    var groupLabel: String
    var category: ExerciseCategory
    var targetRepRange: String
    var restSeconds: Int
}
struct WorkoutCompleteEntry: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: Date
}
struct EditableSetLog: Identifiable {
    let id = UUID()
    var setNumber: Int
    var weight: String = ""
    var reps: String = ""
    var rpe: String = ""
}
struct ExercisePR: Identifiable {
    let id = UUID()
    let exercise: String
    let category: ExerciseCategory
    let displayValue: String
}
struct WorkoutCheckIn: Identifiable, Codable {
    let id: UUID
    let date: Date
    let workoutTitle: String
    
    let sleep: Int
    let stress: Int
    let recovery: Int
    let motivation: Int
    let energy: Int
    let mood: Int
    
    let bodyweight: String
    
    var readinessAverage: Double {
        let total = sleep + recovery + motivation + energy + mood + (6 - stress)
        return Double(total) / 6.0
    }
}
struct ActiveWorkoutStep: Identifiable {
    let id = UUID()
    let exercise: ExerciseItem
    let setNumber: Int
}
func formattedDateTime(_ date: Date) -> String {
    date.formatted(date: .abbreviated, time: .shortened)
}
struct WorkoutCheckOut: Identifiable, Codable {
    let id: UUID
    let date: Date
    let workoutTitle: String
    
    let sessionRPE: Int
    let injuryNotes: String
}
enum ExerciseCategory: String, Codable, CaseIterable {
    case mainLift = "Main Lift"
    case accessory = "Accessory"
    case bodyweight = "Bodyweight"
    case conditioning = "Conditioning"
}
struct WorkoutTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var category: WorkoutTemplateCategory
    var exercises: [ExerciseItem]
}
struct WorkoutBriefItem: Identifiable {
    let id = UUID()

    let exercise: ExerciseItem

    let suggestedWeight: String

    let previousWeight: String

    let recommendation: String

    let showReason: Bool

    let reason: String
}

struct WorkoutPR: Identifiable {
    let id = UUID()
    let exercise: String
    let type: String
    let value: String
}

struct PRHistoryEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let exercise: String
    let type: String
    let value: String
    let workoutTitle: String
}
enum BJJSessionType: String, Codable, CaseIterable {
    case gi = "Gi"
    case noGi = "No-Gi"
}

enum BeltLevel: String, Codable, CaseIterable {
    case white = "White"
    case blue = "Blue"
    case purple = "Purple"
    case brown = "Brown"
    case black = "Black"
    case unknown = "Unknown"
}
func beltColor(_ belt: BeltLevel) -> Color {
    switch belt {
    case .white:
        return .white
    case .blue:
        return .blue
    case .purple:
        return .purple
    case .brown:
        return .brown
    case .black:
        return .red
    case .unknown:
        return .appTextSecondary
    }
}

struct BJJRounds: Identifiable, Codable {
    let id: UUID
    var beltLevel: BeltLevel
    var durationMinutes: Int
    var roundRPE: Int
    var notes: String
}

struct BJJSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let sessionType: BJJSessionType
    let totalDurationMinutes: Int
    let sleep: Int
    let stress: Int
    let recovery: Int
    let motivation: Int
    let energy: Int
    let mood: Int

    var readinessAverage: Double {
        let total = sleep + recovery + motivation + energy + mood + (6 - stress)
        return Double(total) / 6.0
    }
    let sessionRPE: Int
    let notes: String
    let rounds: [BJJRounds]
    let submissionsFinished: [SubmissionCount]
    let submissionsReceived: [SubmissionCount]
    
    var totalLiveMinutes: Int {
        rounds.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var totalRounds: Int {
        rounds.count
    }
    
    var averageRoundRPE: Double {
        guard !rounds.isEmpty else { return 0 }
        let total = rounds.reduce(0) { $0 + $1.roundRPE }
        return Double(total) / Double(rounds.count)
    }
    
}
enum BJJAnalyticsRange: String, CaseIterable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case currentBelt = "Current Belt"
    case allTime = "All Time"
}
struct SubmissionCount: Identifiable, Codable {
    let id: UUID
    let submission: SubmissionType
    let count: Int
}
enum SubmissionType: String, Codable, CaseIterable {
    case rearNakedChoke = "Rear Naked Choke"
    case guillotine = "Guillotine"
    case darce = "D'Arce"
    case anaconda = "Anaconda"
    case triangle = "Triangle"
    case armTriangle = "Arm Triangle"
    case ezekiel = "Ezekiel"
    case bowAndArrow = "Bow and Arrow"
    case baseballBatChoke = "Baseball Bat Choke"
    case crossCollarChoke = "Cross Collar Choke"
    case loopChoke = "Loop Choke"
    
    case armbar = "Armbar"
    case kimura = "Kimura"
    case americana = "Americana"
    case omoplata = "Omoplata"
    case wristLock = "Wrist Lock"
    
    case straightAnkleLock = "Straight Ankle Lock"
    case heelHook = "Heel Hook"
    case kneeBar = "Kneebar"
    case toeHold = "Toe Hold"
    case calfSlicer = "Calf Slicer"
    
    case other = "Other"
}
struct BeltRankChange: Identifiable, Codable {
    let id: UUID
    let date: Date
    let beltLevel: BeltLevel
}
enum WorkoutTemplateCategory: String, Codable, CaseIterable {
    case strength = "Strength"
    case hypertrophy = "Hypertrophy"
    case power = "Power"
    case conditioning = "Conditioning"
    case maintenance = "Maintenance"
    case competitionPrep = "Competition Prep"
    case recovery = "Recovery"
    case custom = "Custom"
}

@Observable
class AppStore {
    var historyEntries: [WorkoutHistoryEntry] = [] {
        didSet { save() }
    }
    
    var completedWorkouts: [WorkoutCompleteEntry] = [] {
        didSet { save() }
    }
    var todaysWorkoutTitle: String = "Lower Body Strength" {
        didSet { save() }
    }
    var todaysWorkoutNotes: String = "" {
        didSet { UserDefaults.standard.set(todaysWorkoutNotes, forKey: "todaysWorkoutNotes") }
    }
    var checkOuts: [WorkoutCheckOut] = [] {
        didSet { save() }
    }
    var todaysExercises: [ExerciseItem] = [
        ExerciseItem(
            id: UUID(),
            name: "Back Squat",
            details: "5x5 @ moderate load",
            notes: "Keep torso rigid, drive up fast",
            setCount: 5,
            groupLabel: "",
            category: .mainLift,
            targetRepRange: "3-6",
            restSeconds: 90
        ),
        ExerciseItem(
            id: UUID(),
            name: "Romanian Deadlift",
            details: "3x8 focus on hinge",
            notes: "Hips back, lats tight",
            setCount: 3,
            groupLabel: "",
            category: .mainLift,
            targetRepRange: "3-6",
            restSeconds: 90
        ),
        ExerciseItem(
            id: UUID(),
            name: "Walking Lunges",
            details: "3x12 each leg",
            notes: "Knee tracks toes, long stride",
            setCount: 3,
            groupLabel: "",
            category: .accessory,
            targetRepRange: "8-15",
            restSeconds: 90
        ),
        ExerciseItem(
            id: UUID(),
            name: "Pull Ups",
            details: "3 sets to near failure",
            notes: "Full hang, chest to bar",
            setCount: 3,
            groupLabel: "",
            category: .bodyweight,
            targetRepRange: "AMRAP",
            restSeconds: 90
        )
    ] {
        didSet { save() }
    }
    var workoutTemplates: [WorkoutTemplate] = []
    var checkIns: [WorkoutCheckIn] = [] {
        didSet { save() }
    }
    
    init() {
        load()
    }
    var prHistoryEntries: [PRHistoryEntry] = [] {
        didSet { save() }
    }
    var bjjSessions: [BJJSession] = [] {
        didSet { save() }
    }
    
    private func save() {
        let encoder = JSONEncoder()
        
        if let historyData = try? encoder.encode(historyEntries) {
            UserDefaults.standard.set(historyData, forKey: "historyEntries")
        }
        
        if let completedData = try? encoder.encode(completedWorkouts) {
            UserDefaults.standard.set(completedData, forKey: "completedWorkouts")
        }
        
        if let todaysExercisesData = try? encoder.encode(todaysExercises) {
            UserDefaults.standard.set(todaysExercisesData, forKey: "todaysExercises")
        }
        if let templateData = try? encoder.encode(workoutTemplates) {
            UserDefaults.standard.set(
                templateData,
                forKey: "workoutTemplates"
            )
        }
        if let checkInData = try? encoder.encode(checkIns) {
            UserDefaults.standard.set(checkInData, forKey: "checkIns")
        }
        if let checkOutData = try? encoder.encode(checkOuts) {
            UserDefaults.standard.set(checkOutData, forKey: "checkOuts")
        }
        if let bjjData = try? encoder.encode(bjjSessions) {
            UserDefaults.standard.set(bjjData, forKey: "bjjSessions")
        }
        if let beltData = try? encoder.encode(beltRankChanges) {
            UserDefaults.standard.set(beltData, forKey: "beltRankChanges")
        }
        if let prData = try? encoder.encode(prHistoryEntries) {
            UserDefaults.standard.set(prData, forKey: "prHistoryEntries")
        }
        if let bjjData = try? encoder.encode(bjjSessions) {
            UserDefaults.standard.set(bjjData, forKey: "bjjSessions")
        }

        UserDefaults.standard.set(todaysWorkoutTitle, forKey: "todaysWorkoutTitle")
    }
    
    private func load() {
        let decoder = JSONDecoder()
        if let checkInData = UserDefaults.standard.data(forKey: "checkIns"),
           let decodedCheckIns = try? decoder.decode([WorkoutCheckIn].self, from: checkInData) {
            checkIns = decodedCheckIns
        }
        if let savedTitle = UserDefaults.standard.string(forKey: "todaysWorkoutTitle") {
            todaysWorkoutTitle = savedTitle
        }
        if let historyData = UserDefaults.standard.data(forKey: "historyEntries"),
           let decodedHistory = try? decoder.decode([WorkoutHistoryEntry].self, from: historyData) {
            historyEntries = decodedHistory
        }
        
        if let completedData = UserDefaults.standard.data(forKey: "completedWorkouts"),
           let decodedCompleted = try? decoder.decode([WorkoutCompleteEntry].self, from: completedData) {
            completedWorkouts = decodedCompleted
        }
        
        if let todaysExercisesData = UserDefaults.standard.data(forKey: "todaysExercises"),
           let decodedTodaysExercises = try? decoder.decode([ExerciseItem].self, from: todaysExercisesData) {
            todaysExercises = decodedTodaysExercises
        }
        if let templateData = UserDefaults.standard.data(
            forKey: "workoutTemplates"
        ),
        let decodedTemplates = try? decoder.decode(
            [WorkoutTemplate].self,
            from: templateData
        ) {
            workoutTemplates = decodedTemplates
        }
        if let savedNotes = UserDefaults.standard.string(forKey: "todaysWorkoutNotes") {
            todaysWorkoutNotes = savedNotes
        }
        if let checkOutData = UserDefaults.standard.data(forKey: "checkOuts"),
           let decodedCheckOuts = try? decoder.decode([WorkoutCheckOut].self, from: checkOutData) {
            checkOuts = decodedCheckOuts
        }
        if let bjjData = UserDefaults.standard.data(forKey: "bjjSessions"),
           let decodedBJJ = try? decoder.decode([BJJSession].self, from: bjjData) {
            bjjSessions = decodedBJJ
        }
        if let beltData = UserDefaults.standard.data(forKey: "beltRankChanges"),
           let decodedBelts = try? decoder.decode([BeltRankChange].self, from: beltData) {
            beltRankChanges = decodedBelts
        }
        if let prData = UserDefaults.standard.data(forKey: "prHistoryEntries"),
           let decodedPRs = try? decoder.decode([PRHistoryEntry].self, from: prData) {
            prHistoryEntries = decodedPRs
        }
        if let bjjData = UserDefaults.standard.data(forKey: "bjjSessions"),
           let decodedBJJ = try? decoder.decode([BJJSession].self, from: bjjData) {
            bjjSessions = decodedBJJ
        }
    }
    func addCheckIn(
        sleep: Int,
        stress: Int,
        recovery: Int,
        motivation: Int,
        energy: Int,
        mood: Int,
        bodyweight: String
    ) {
        let checkIn = WorkoutCheckIn(
            id: UUID(),
            date: Date(),
            workoutTitle: todaysWorkoutTitle,
            sleep: sleep,
            stress: stress,
            recovery: recovery,
            motivation: motivation,
            energy: energy,
            mood: mood,
            bodyweight: bodyweight
        )
        
        checkIns.insert(checkIn, at: 0)
    }
    func clearAllData() {
        self.historyEntries = []
        self.completedWorkouts = []
        self.todaysExercises = []
        UserDefaults.standard.removeObject(forKey: "historyEntries")
        UserDefaults.standard.removeObject(forKey: "completedWorkouts")
        UserDefaults.standard.removeObject(forKey: "todaysExercises")
        self.checkIns = []
        UserDefaults.standard.removeObject(forKey: "checkIns")
        self.checkOuts = []
        UserDefaults.standard.removeObject(forKey: "checkOuts")
        self.bjjSessions = []
        UserDefaults.standard.removeObject(forKey: "bjjSessions")
        self.beltRankChanges = []
        UserDefaults.standard.removeObject(forKey: "beltRankChanges")
    }
    func addExercise(
        name: String,
        details: String,
        notes: String = "",
        setCount: Int,
        groupLabel: String,
        category: ExerciseCategory,
        targetRepRange: String
    ) {
        let restSeconds: Int

        switch category {
        case .mainLift:
            restSeconds = 180

        case .accessory:
            restSeconds = 90

        case .bodyweight:
            restSeconds = 90

        case .conditioning:
            restSeconds = 60
        }

        let newExercise = ExerciseItem(
            id: UUID(),
            name: name,
            details: details,
            notes: notes,
            setCount: setCount,
            groupLabel: groupLabel,
            category: category,
            targetRepRange: targetRepRange,
            restSeconds: restSeconds
        )
        
        todaysExercises.append(newExercise)
    }
    func deleteTodaysExercises(at offsets: IndexSet) {
        todaysExercises.remove(atOffsets: offsets)
    }
    func moveTodaysExercises(from source: IndexSet, to destination: Int) {
        todaysExercises.move(fromOffsets: source, toOffset: destination)
    }
    func updateExercise(
        id: UUID,
        name: String,
        details: String,
        notes: String,
        setCount: Int,
        groupLabel: String,
        category: ExerciseCategory,
        targetRepRange: String,
        restSeconds: Int
    ) {
        guard let index = todaysExercises.firstIndex(where: { $0.id == id }) else { return }
        
        todaysExercises[index] = ExerciseItem(
            id: id,
            name: name,
            details: details,
            notes: notes,
            setCount: setCount,
            groupLabel: groupLabel,
            category: category,
            targetRepRange: targetRepRange,
            restSeconds: restSeconds
        )
    }
    func addCheckOut(
        sessionRPE: Int,
        injuryNotes: String
    ) {
        let checkOut = WorkoutCheckOut(
            id: UUID(),
            date: Date(),
            workoutTitle: todaysWorkoutTitle,
            sessionRPE: sessionRPE,
            injuryNotes: injuryNotes
        )
        
        checkOuts.insert(checkOut, at: 0)
    }
    func saveWorkoutTemplate(
        name: String,
        category: WorkoutTemplateCategory,
        exercises: [ExerciseItem]
    ) {
        let template = WorkoutTemplate(
            id: UUID(),
            name: name,
            category: category,
            exercises: exercises
        )
        
        workoutTemplates.append(template)
    }
    func loadWorkoutTemplate(_ template: WorkoutTemplate) {
        todaysExercises = template.exercises
    }
    func duplicateExercise(id: UUID) {
        guard let index = todaysExercises.firstIndex(where: { $0.id == id }) else { return }
        
        let original = todaysExercises[index]

        let copy = ExerciseItem(
            id: UUID(),
            name: "\(original.name) Copy",
            details: original.details,
            notes: original.notes,
            setCount: original.setCount,
            groupLabel: original.groupLabel,
            category: original.category,
            targetRepRange: original.targetRepRange,
            restSeconds: original.restSeconds
        )
        
        todaysExercises.insert(copy, at: index + 1)
    }
    func updateExerciseInTemplate(
        templateID: UUID,
        exerciseID: UUID,
        name: String,
        details: String,
        notes: String,
        setCount: Int,
        groupLabel: String,
        category: ExerciseCategory,
        targetRepRange: String,
        restSeconds: Int
    )
    {
        guard let templateIndex = workoutTemplates.firstIndex(where: { $0.id == templateID }) else {
            return
        }
        
        guard let exerciseIndex = workoutTemplates[templateIndex]
            .exercises
            .firstIndex(where: { $0.id == exerciseID }) else {
            return
        }
        
        workoutTemplates[templateIndex].exercises[exerciseIndex] = ExerciseItem(
            id: exerciseID,
            name: name,
            details: details,
            notes: notes,
            setCount: setCount,
            groupLabel: groupLabel,
            category: category,
            targetRepRange: targetRepRange,
            restSeconds: restSeconds
        )
    }
    func defaultRepRange(
        templateCategory: WorkoutTemplateCategory,
        exerciseCategory: ExerciseCategory
    ) -> String {
        switch templateCategory {
        case .strength:
            switch exerciseCategory {
            case .mainLift: return "3-6"
            case .accessory: return "5-10"
            case .bodyweight: return "AMRAP"
            case .conditioning: return "Conditioning"
            }
            
        case .hypertrophy:
            switch exerciseCategory {
            case .mainLift: return "5-10"
            case .accessory: return "8-15"
            case .bodyweight: return "AMRAP"
            case .conditioning: return "Conditioning"
            }
            
        case .power:
            switch exerciseCategory {
            case .mainLift: return "1-5"
            case .accessory: return "3-8"
            case .bodyweight: return "Explosive"
            case .conditioning: return "Short Intervals"
            }
            
        case .maintenance:
            switch exerciseCategory {
            case .mainLift: return "3-8"
            case .accessory: return "8-12"
            case .bodyweight: return "AMRAP"
            case .conditioning: return "Moderate"
            }
            
        case .competitionPrep:
            switch exerciseCategory {
            case .mainLift: return "2-5"
            case .accessory: return "6-10"
            case .bodyweight: return "Controlled"
            case .conditioning: return "Sport Specific"
            }
            
        case .conditioning:
            return "Conditioning"
            
        case .recovery:
            return "Easy"
            
        case .custom:
            switch exerciseCategory {
            case .mainLift: return "3-6"
            case .accessory: return "8-15"
            case .bodyweight: return "AMRAP"
            case .conditioning: return "Conditioning"
            }
        }
    }
    func addBodyweightEntry(weight: String) {
        let checkIn = WorkoutCheckIn(
            id: UUID(),
            date: Date(),
            workoutTitle: "Manual Bodyweight Entry",
            sleep: 5,
            stress: 5,
            recovery: 5,
            motivation: 5,
            energy: 5,
            mood: 5,
            bodyweight: weight
        )
        
        checkIns.insert(checkIn, at: 0)
    }
    func duplicateWorkoutTemplate(id: UUID) {
        guard let original = workoutTemplates.first(where: { $0.id == id }) else {
            return
        }
        
        let copy = WorkoutTemplate(
            id: UUID(),
            name: "\(original.name) Copy",
            category: original.category,
            exercises: original.exercises
        )
        
        workoutTemplates.append(copy)
    }
    func updateWorkoutTemplate(
        id: UUID,
        name: String,
        category: WorkoutTemplateCategory
    ) {
        guard let index = workoutTemplates.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        workoutTemplates[index].name = name
        workoutTemplates[index].category = category
        
        workoutTemplates[index].exercises = workoutTemplates[index].exercises.map { exercise in
            ExerciseItem(
                id: exercise.id,
                name: exercise.name,
                details: exercise.details,
                notes: exercise.notes,
                setCount: exercise.setCount,
                groupLabel: exercise.groupLabel,
                category: exercise.category,
                targetRepRange: defaultRepRange(
                    templateCategory: category,
                    exerciseCategory: exercise.category
                ),
                restSeconds: exercise.restSeconds
            )
        }
    }
    func deleteExerciseFromTemplate(
        templateID: UUID,
        offsets: IndexSet
    ) {
        guard let index = workoutTemplates.firstIndex(where: { $0.id == templateID }) else {
            return
        }
        
        workoutTemplates[index].exercises.remove(atOffsets: offsets)
    }
    func moveExerciseInTemplate(
        templateID: UUID,
        from source: IndexSet,
        to destination: Int
    ) {
        guard let index = workoutTemplates.firstIndex(where: { $0.id == templateID }) else {
            return
        }
        
        workoutTemplates[index].exercises.move(
            fromOffsets: source,
            toOffset: destination
        )
    }
    func resetTemplateRepRanges(
        templateID: UUID
    ) {
        guard let index = workoutTemplates.firstIndex(
            where: { $0.id == templateID }
        ) else {
            return
        }

        let templateCategory = workoutTemplates[index].category

        workoutTemplates[index].exercises =
            workoutTemplates[index].exercises.map { exercise in

                ExerciseItem(
                    id: exercise.id,
                    name: exercise.name,
                    details: exercise.details,
                    notes: exercise.notes,
                    setCount: exercise.setCount,
                    groupLabel: exercise.groupLabel,
                    category: exercise.category,
                    targetRepRange: defaultRepRange(
                        templateCategory: templateCategory,
                        exerciseCategory: exercise.category
                    ),
                    restSeconds: exercise.restSeconds
                )
        }
    }
    func addBJJSession(
        sessionType: BJJSessionType,
        totalDurationMinutes: Int,
        sleep: Int,
        stress: Int,
        recovery: Int,
        motivation: Int,
        energy: Int,
        mood: Int,
        sessionRPE: Int,
        notes: String,
        rounds: [BJJRounds],
        submissionsFinished: [SubmissionCount],
        submissionsReceived: [SubmissionCount]
    ) {
        let session = BJJSession(
            id: UUID(),
            date: Date(),
            sessionType: sessionType,
            totalDurationMinutes: totalDurationMinutes,
            sleep: sleep,
            stress: stress,
            recovery: recovery,
            motivation: motivation,
            energy: energy,
            mood: mood,
            sessionRPE: sessionRPE,
            notes: notes,
            rounds: rounds,
            submissionsFinished: submissionsFinished,
            submissionsReceived: submissionsReceived
        )
        
        bjjSessions.insert(session, at: 0)
    }
    func addBeltRankChange(
        beltLevel: BeltLevel,
        date: Date = Date()
    ) {
        let change = BeltRankChange(
            id: UUID(),
            date: date,
            beltLevel: beltLevel
        )
        
        beltRankChanges.append(change)
        beltRankChanges.sort { $0.date < $1.date }
    }
    func beltRank(for date: Date) -> BeltLevel {
        let applicableRanks = beltRankChanges
            .filter { $0.date <= date }
            .sorted { $0.date < $1.date }
        
        return applicableRanks.last?.beltLevel ?? .white
    }
    func deleteBJJSession(id: UUID) {
        bjjSessions.removeAll { $0.id == id }
    }
    func updateBJJSession(_ updatedSession: BJJSession) {
        guard let index = bjjSessions.firstIndex(where: { $0.id == updatedSession.id }) else {
            return
        }
        
        bjjSessions[index] = updatedSession
    }
    func updateBJJSessionRounds(sessionID: UUID, rounds: [BJJRounds]) {
        guard let index = bjjSessions.firstIndex(where: { $0.id == sessionID }) else {
            return
        }
        
        let session = bjjSessions[index]
        
        bjjSessions[index] = BJJSession(
            id: session.id,
            date: session.date,
            sessionType: session.sessionType,
            totalDurationMinutes: session.totalDurationMinutes,
            sleep: session.sleep,
            stress: session.stress,
            recovery: session.recovery,
            motivation: session.motivation,
            energy: session.energy,
            mood: session.mood,
            sessionRPE: session.sessionRPE,
            notes: session.notes,
            rounds: rounds,
            submissionsFinished: session.submissionsFinished,
            submissionsReceived: session.submissionsReceived
        )
    }
    func updateBJJSessionSubmissions(
        sessionID: UUID,
        submissionsFinished: [SubmissionCount],
        submissionsReceived: [SubmissionCount]
    ) {
        guard let index = bjjSessions.firstIndex(where: { $0.id == sessionID }) else {
            return
        }
        
        let session = bjjSessions[index]
        
        bjjSessions[index] = BJJSession(
            id: session.id,
            date: session.date,
            sessionType: session.sessionType,
            totalDurationMinutes: session.totalDurationMinutes,
            sleep: session.sleep,
            stress: session.stress,
            recovery: session.recovery,
            motivation: session.motivation,
            energy: session.energy,
            mood: session.mood,
            sessionRPE: session.sessionRPE,
            notes: session.notes,
            rounds: session.rounds,
            submissionsFinished: submissionsFinished,
            submissionsReceived: submissionsReceived
        )
    }
    func deleteWorkoutTemplate(id: UUID) {
        workoutTemplates.removeAll { $0.id == id }
    }
    func addExerciseToTemplate(
        templateID: UUID,
        name: String,
        details: String,
        notes: String,
        setCount: Int,
        groupLabel: String,
        category: ExerciseCategory
    ) {
        guard let index = workoutTemplates.firstIndex(where: { $0.id == templateID }) else {
            return
        }
        
        let templateCategory = workoutTemplates[index].category

        let defaultRange = defaultRepRange(
            templateCategory: templateCategory,
            exerciseCategory: category
        )

        let restSeconds: Int

        switch category {
        case .mainLift:
            restSeconds = 180

        case .accessory:
            restSeconds = 90

        case .bodyweight:
            restSeconds = 90

        case .conditioning:
            restSeconds = 60
        }

        let exercise = ExerciseItem(
            id: UUID(),
            name: name,
            details: details,
            notes: notes,
            setCount: setCount,
            groupLabel: groupLabel,
            category: category,
            targetRepRange: defaultRange,
            restSeconds: restSeconds
        )

        workoutTemplates[index].exercises.append(exercise)
    }
    var exercisePRs: [ExercisePR] {
        let grouped = Dictionary(grouping: historyEntries, by: { $0.exercise })
        
        return grouped.compactMap { exerciseName, entries in
            guard let exerciseItem = todaysExercises.first(where: { $0.name == exerciseName }) else {
                return nil
            }
            
            let allSets = entries.flatMap { $0.sets }
            
            switch exerciseItem.category {
            case .mainLift:
                let bestWeight = allSets.compactMap { Double($0.weight) }.max()
                guard let bestWeight else { return nil }
                
                return ExercisePR(
                    exercise: exerciseName,
                    category: exerciseItem.category,
                    displayValue: "\(Int(bestWeight)) lbs"
                )
                
            case .accessory:
                let bestVolume = entries.map { $0.totalVolume }.max()
                guard let bestVolume else { return nil }
                
                return ExercisePR(
                    exercise: exerciseName,
                    category: exerciseItem.category,
                    displayValue: "\(Int(bestVolume)) lbs volume"
                )
                
            case .bodyweight:
                let bestReps = allSets.compactMap { Int($0.reps) }.max()
                guard let bestReps else { return nil }
                
                return ExercisePR(
                    exercise: exerciseName,
                    category: exerciseItem.category,
                    displayValue: "\(bestReps) reps"
                )
                
            case .conditioning:
                return nil
            }
        }
        .sorted { $0.exercise < $1.exercise }
    }
    var readinessEntries: [(date: Date, readiness: Double)] {
        checkIns
            .map { checkIn in
                (
                    date: checkIn.date,
                    readiness: checkIn.readinessAverage
                )
            }
            .sorted { $0.date < $1.date }
    }

    var latestReadiness: Double? {
        readinessEntries.last?.readiness
    }
    var bodyweightEntries: [(date: Date, weight: Double)] {
        checkIns
            .compactMap { checkIn in
                if let weight = Double(checkIn.bodyweight) {
                    return (date: checkIn.date, weight: weight)
                }
                return nil
            }
            .sorted { $0.date > $1.date }
    }
    var latestBodyweight: Double? {
        bodyweightEntries.first?.weight
    }

    var averageBodyweight: Double? {
        let weights = bodyweightEntries.map { $0.weight }
        guard !weights.isEmpty else { return nil }
        return weights.reduce(0, +) / Double(weights.count)
    }
    var bodyweightDifferenceFromAverage: Double? {
        guard let latest = latestBodyweight,
              let average = averageBodyweight else {
            return nil
        }
        
        return latest - average
    }
    var minimumBodyweight: Double {
        let weights = bodyweightEntries.map { $0.weight }
        guard let min = weights.min() else { return 0 }
        return min - 5
    }

    var maximumBodyweight: Double {
        let weights = bodyweightEntries.map { $0.weight }
        guard let max = weights.max() else { return 300 }
        return max + 5
    }
    var beltRankChanges: [BeltRankChange] = [] {
        didSet { save() }
    }
}

struct ContentView: View {
    @State private var appStore = AppStore()
    
    var body: some View {
        TabView {
            TodayView(appStore: appStore)
                .tabItem {
                    Label("Today", systemImage: "figure.strengthtraining.traditional")
                }
            BJJView(appStore: appStore)
                .tabItem {
                    Label("BJJ", systemImage: "figure.wrestling")
                }
        
            HistoryView(appStore: appStore)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            TrainingProgressView(appStore: appStore)
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            TemplatesView(appStore: appStore)
                .tabItem {
                    Label("Templates", systemImage: "rectangle.stack")
                }
            
            ExercisesView(appStore: appStore)
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet")
                }
            
            SettingsView(appStore: appStore)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

struct TodayView: View {
    @Bindable var appStore: AppStore
    
    @State private var showAddExerciseSheet = false
    @State private var showEditTitleSheet = false
    @State private var showActiveWorkout = false
    @State private var showSaveTemplateSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(appStore.todaysWorkoutTitle)
                    .font(.title2)
                    .foregroundColor(.gray)
                
                if !appStore.todaysWorkoutNotes.isEmpty {
                    Text(appStore.todaysWorkoutNotes)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Divider()

                List {
                    ForEach(appStore.todaysExercises) { exercise in
                        NavigationLink {
                            ExerciseDetailView(
                                exerciseItem: exercise,
                                appStore: appStore
                            )
                        } label: {
                            WorkoutRow(
                                exercise: exercise.name,
                                details: exercise.details,
                                groupLabel: exercise.groupLabel,
                                targetRepRange: exercise.targetRepRange,
                                restSeconds: exercise.restSeconds
                            )
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: appStore.deleteTodaysExercises)
                    .onMove(perform: appStore.moveTodaysExercises)
                }
                .listStyle(.plain)
                .frame(minHeight: 300)

                Button {
                    showActiveWorkout = true
                } label: {
                    Text("Start Workout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding()
            .navigationTitle("Training Log")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showEditTitleSheet = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    
                    Button {
                        showAddExerciseSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        showSaveTemplateSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
            .sheet(isPresented: $showEditTitleSheet) {
                EditWorkoutTitleView(appStore: appStore)
            }
            .sheet(isPresented: $showAddExerciseSheet) {
                AddExerciseView(appStore: appStore)
            }
            .sheet(isPresented: $showActiveWorkout) {
                WorkoutCheckInView(
                    appStore: appStore,
                    onFinish: {
                        showActiveWorkout = false
                    }
                )
            }
            .sheet(isPresented: $showSaveTemplateSheet) {
                SaveTemplateView(appStore: appStore)
            }
        }
    }
}
struct CheckInRowView: View {
    let checkIn: WorkoutCheckIn
    
    var body: some View {
        let readinessText = String(format: "%.1f", checkIn.readinessAverage)
        
        VStack(alignment: .leading, spacing: 8) {
            Text(checkIn.workoutTitle)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
            
            Text(formattedDateTime(checkIn.date))
                .font(.caption)
                .foregroundColor(.appTextSecondary)
            
            Text("Readiness: \(readinessText)/10")
                .font(.subheadline)
                .foregroundColor(.appTextSecondary)
            
            if !checkIn.bodyweight.isEmpty {
                Text("Bodyweight: \(checkIn.bodyweight) lbs")
                    .font(.caption)
                    .foregroundColor(.appTextSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}
enum HistoryTab: String, CaseIterable {
    case workouts = "Workouts"
    case exercises = "Exercises"
    case prs = "PRs"
    case readiness = "Readiness"
    case bodyweight = "Bodyweight"
}
struct WorkoutHistoryDetailView: View {
    let workout: WorkoutCompleteEntry
    @Bindable var appStore: AppStore

    var workoutEntries: [WorkoutHistoryEntry] {
        appStore.historyEntries.filter {
            $0.workoutTitle == workout.title &&
            Calendar.current.isDate($0.date, inSameDayAs: workout.date)
        }
    }

    var workoutPRs: [PRHistoryEntry] {
        appStore.prHistoryEntries.filter {
            $0.workoutTitle == workout.title &&
            Calendar.current.isDate($0.date, inSameDayAs: workout.date)
        }
    }

    var totalSets: Int {
        workoutEntries.reduce(0) { total, entry in
            total + entry.sets.count
        }
    }

    var totalReps: Int {
        workoutEntries.reduce(0) { total, entry in
            total + entry.totalReps
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(workout.title)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.appTextPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)

                    Text(formattedDateTime(workout.date))
                        .foregroundColor(.appTextPrimary)

                    Text("Sets: \(totalSets)")
                        .foregroundColor(.appTextSecondary)

                    Text("Reps: \(totalReps)")
                        .foregroundColor(.appTextSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appCard)
                .cornerRadius(16)

                if !workoutPRs.isEmpty {
                    Text("PRs Earned")
                        .font(.headline)
                        .foregroundColor(.appTextSecondary)

                    ForEach(workoutPRs) { pr in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(pr.type.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.appAccent)

                            Text(pr.exercise)
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)

                            Text(pr.value)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.appTextPrimary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appCard)
                        .cornerRadius(16)
                    }
                }

                Text("Exercises")
                    .font(.headline)
                    .foregroundColor(.appTextSecondary)

                ForEach(workoutEntries) { entry in
                    NavigationLink {
                        HistoryDetailView(entry: entry)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.exercise)
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)

                            Text(entry.details)
                                .foregroundColor(.appTextSecondary)

                            Text("\(entry.totalReps) reps")
                                .foregroundColor(.appTextSecondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appCard)
                        .cornerRadius(16)
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Workout Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct HistoryView: View {
    @Bindable var appStore: AppStore
    @State private var selectedHistoryTab: HistoryTab = .workouts
    @State private var showExerciseLogs = true
    
    var body: some View {
        let checkIns = appStore.checkIns
        let checkOuts = appStore.checkOuts
        let completedWorkouts = appStore.completedWorkouts
        let historyEntries = appStore.historyEntries
        
        NavigationStack {
            List {
                Picker("History", selection: $selectedHistoryTab) {
                    ForEach(HistoryTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                switch selectedHistoryTab {
                case .workouts:
                    if completedWorkouts.isEmpty {
                        Text("No completed workouts yet.")
                            .foregroundColor(.appTextSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appCard)
                            .cornerRadius(16)
                            .listRowBackground(Color.appBackground)
                    } else {
                        Section("Completed Workouts") {
                            ForEach(completedWorkouts) { workout in
                                
                                NavigationLink {
                                    WorkoutHistoryDetailView(
                                        workout: workout,
                                        appStore: appStore
                                    )
                                } label: {
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        
                                        Text(workout.title)
                                            .foregroundColor(.appTextPrimary)
                                        
                                        Text(formattedDateTime(workout.date))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appCard)
                                    .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    if !checkOuts.isEmpty {
                        Section("Check-Outs") {
                            ForEach(checkOuts) { checkOut in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(checkOut.workoutTitle)
                                        .foregroundColor(.appTextPrimary)

                                    Text(formattedDateTime(checkOut.date))
                                        .foregroundColor(.appTextSecondary)

                                    Text("Session RPE: \(checkOut.sessionRPE)/10")
                                        .foregroundColor(.appTextSecondary)
                                    
                                    if !checkOut.injuryNotes.isEmpty {
                                        Text("Notes: \(checkOut.injuryNotes)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.appCard)
                                .cornerRadius(16)
                                .listRowBackground(Color.appBackground)
                            }
                        }
                    }
                    
                case .exercises:
                    if historyEntries.isEmpty {
                        Text("No exercise logs yet.")
                            .foregroundColor(.appTextSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appCard)
                            .cornerRadius(16)
                            .listRowBackground(Color.appBackground)
                    } else {
                        Section("Exercise Logs") {
                            ForEach(historyEntries) { entry in
                                NavigationLink {
                                    HistoryDetailView(entry: entry)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {

                                        Text(entry.exercise)
                                            .font(.headline)
                                            .foregroundColor(.appTextPrimary)

                                        Text(entry.workoutTitle)
                                            .foregroundColor(.appTextSecondary)

                                        Text(formattedDateTime(entry.date))
                                            .foregroundColor(.appTextSecondary)

                                        Text(entry.details)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.appTextPrimary)

                                        Text("Total: \(entry.totalReps) reps, \(Int(entry.totalVolume)) lb volume")
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appCard)
                                    .cornerRadius(16)
                                }
                                .listRowBackground(Color.appBackground)
                            }
                        }
                    }
                    
                case .prs:
                    if appStore.prHistoryEntries.isEmpty {
                        Text("No PRs recorded yet.")
                            .foregroundColor(.appTextSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appCard)
                            .cornerRadius(16)
                            .listRowBackground(Color.appBackground)
                    } else {
                        Section("PR History") {
                            ForEach(appStore.prHistoryEntries) { pr in
                                VStack(alignment: .leading, spacing: 8) {

                                    Text(pr.type.uppercased())
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appAccent)

                                    Text(pr.exercise)
                                        .font(.headline)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Text(pr.value)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appTextPrimary)

                                    Text(pr.workoutTitle)
                                        .foregroundColor(.appTextSecondary)

                                    Text(formattedDateTime(pr.date))
                                        .font(.caption)
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.appCard)
                                .cornerRadius(16)
                                .listRowBackground(Color.appBackground)
                            }
                        }
                    }
                    
                case .readiness:
                    if checkIns.isEmpty {
                        Text("No readiness check-ins yet.")
                            .foregroundColor(.appTextSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appCard)
                            .cornerRadius(16)
                            .listRowBackground(Color.appBackground)
                    } else {
                        Section("Readiness Check-Ins") {
                            ForEach(checkIns) { checkIn in
                                CheckInRowView(checkIn: checkIn)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appCard)
                                    .cornerRadius(16)
                                    .listRowBackground(Color.appBackground)
                            }
                        }
                    }
                    
                case .bodyweight:
                    if appStore.bodyweightEntries.isEmpty {
                        Text("No bodyweight entries yet.")
                            .foregroundColor(.appTextSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appCard)
                            .cornerRadius(16)
                            .listRowBackground(Color.appBackground)
                    } else {
                        Section("Bodyweight") {
                            ForEach(appStore.bodyweightEntries, id: \.date) { entry in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(formattedDateTime(entry.date))
                                            .font(.headline)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(entry.weight, specifier: "%.1f") lb")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("History")
        }
    }
}
struct HistoryDetailView: View {
    let entry: WorkoutHistoryEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(entry.exercise)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.appTextPrimary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.details)
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                    
                    Text(formattedDateTime(entry.date))
                        .foregroundColor(.appTextSecondary)
                    
                    let isBodyweightStyle =
                    entry.sets.contains {
                        (Double($0.weight) ?? 0) == 0
                    }

                    Text(
                        isBodyweightStyle
                        ? "Total Reps: \(entry.totalReps)"
                        : "Total: \(entry.totalReps) reps, \(Int(entry.totalVolume)) lb volume"
                    )
                    .foregroundColor(.appTextSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appCard)
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {

                    Text("Logged Sets")
                        .font(.headline)
                        .foregroundColor(.appTextSecondary)

                    VStack(alignment: .leading, spacing: 10) {

                        ForEach(entry.sets) { set in

                            let weightValue = Double(set.weight) ?? 0

                            Text(
                                weightValue > 0
                                ? "Set \(set.setNumber): +\(Int(weightValue)) lb • \(set.reps) reps • RPE \(set.rpe)"
                                : "Set \(set.setNumber): Bodyweight • \(set.reps) reps • RPE \(set.rpe)"
                            )
                            .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("History Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExercisesView: View {
    @Bindable var appStore: AppStore
    
    var body: some View {
        NavigationStack {
            List(appStore.todaysExercises) { exercise in
                NavigationLink {
                    EditExerciseView(
                        appStore: appStore,
                        exercise: exercise
                    )
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                        Text(exercise.details)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Exercises")
        }
    }
}

struct ExerciseLibraryDetailView: View {
    var exercise: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exercise)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Category")
                .font(.headline)
            
            Text("Strength")
                .foregroundColor(.secondary)
            
            Text("Coaching Notes")
                .font(.headline)
            
            Text("This is where your exercise cues, setup notes, and technique reminders will go.")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle(exercise)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView: View {
    @Bindable var appStore: AppStore
    @State private var showClearConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("App controls and reset options.")
                    .foregroundColor(.secondary)
                
                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    Text("Clear All History")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .alert("Clear all saved data?", isPresented: $showClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    appStore.clearAllData()
                }
            } message: {
                Text("This will remove all exercise logs and completed workouts.")
            }
        }
    }
}
struct WorkoutRow: View {
    var exercise: String
    var details: String
    var groupLabel: String = ""
    var targetRepRange: String = ""
    var restSeconds: Int = 90
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise)
                .font(.headline)
            
            Text(details)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if !groupLabel.isEmpty {
                Text("Group \(groupLabel)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            if !targetRepRange.isEmpty {
                Text("Target: \(targetRepRange) reps")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("Rest: \(restSeconds) sec")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
struct SetEntryView: View {
    var setNumber: Int
    @Binding var weight: String
    @Binding var reps: String
    @Binding var rpe: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set \(setNumber)")
                .font(.headline)
            
            TextField("Weight", text: $weight)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            
            TextField("Reps", text: $reps)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
            TextField("RPE", text: $rpe)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
struct DynamicSetEntryView: View {
    @Binding var set: EditableSetLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set \(set.setNumber)")
                .font(.headline)
            
            TextField("Weight", text: $set.weight)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            
            TextField("Reps", text: $set.reps)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
            TextField("RPE", text: $set.rpe)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
struct ExerciseDetailView: View {
    var exerciseItem: ExerciseItem
    @Bindable var appStore: AppStore
    
    @State private var setLogs: [EditableSetLog] = []
    @State private var showSavedMessage = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(exerciseItem.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(exerciseItem.details)
                    .font(.title3)
                    .foregroundColor(.gray)
                
                if !exerciseItem.notes.isEmpty {
                    Text(exerciseItem.notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Text("Log Your Sets")
                    .font(.headline)
                
                ForEach($setLogs) { $set in
                    DynamicSetEntryView(set: $set)
                }
                
                Button(action: {
                    let savedSets = setLogs.map { set in
                        WorkoutSetEntry(
                            id: UUID(),
                            setNumber: set.setNumber,
                            weight: set.weight,
                            reps: set.reps,
                            rpe: set.rpe
                        )
                    }
                    
                    let entry = WorkoutHistoryEntry(
                        id: UUID(),
                        workoutTitle: appStore.todaysWorkoutTitle,
                        date: Date(),
                        exercise: exerciseItem.name,
                        details: exerciseItem.details,
                        sets: savedSets
                    )
                    
                    appStore.historyEntries.insert(entry, at: 0)
                    showSavedMessage = true
                }) {
                    Text("Save Exercise Log")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
                
                if showSavedMessage {
                    Text("Exercise log saved.")
                        .foregroundColor(.green)
                        .font(.subheadline)
                }
            }
            .padding()
        }
        .navigationTitle(exerciseItem.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if setLogs.isEmpty {
                setLogs = (1...exerciseItem.setCount).map { number in
                    EditableSetLog(setNumber: number)
                }
            }
        }
    }
}
struct AddExerciseView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName = ""
    @State private var exerciseDetails = ""
    @State private var exerciseNotes = ""
    @State private var setCount = 3
    @State private var groupLabel = ""
    @State private var category: ExerciseCategory = .accessory
    @State private var targetRepRange = "8-12"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Info") {
                    TextField("Exercise Name", text: $exerciseName)
                    TextField("Details (example: 4 x 5 @ 275)", text: $exerciseDetails)
                    TextField("Notes (optional)", text: $exerciseNotes)
                    Stepper("Sets: \(setCount)", value: $setCount, in: 1...10)
                    TextField("Group Label (optional: A, B, C)", text: $groupLabel)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                    TextField("Target Rep Range", text: $targetRepRange)
                }
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.addExercise(
                            name: exerciseName,
                            details: exerciseDetails,
                            notes: exerciseNotes,
                            setCount: setCount,
                            groupLabel: groupLabel.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                            category: category,
                            targetRepRange: targetRepRange
                        )
                        dismiss()
                    }
                    .disabled(exerciseName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
struct EditExerciseView: View {
    @Bindable var appStore: AppStore
    let exercise: ExerciseItem
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName: String
    @State private var exerciseDetails: String
    @State private var exerciseNotes: String
    @State private var setCount: Int
    @State private var groupLabel: String
    @State private var category: ExerciseCategory
    @State private var targetRepRange: String
    @State private var restSeconds: Int
    
    init(appStore: AppStore, exercise: ExerciseItem) {
        self.appStore = appStore
        self.exercise = exercise
        _exerciseName = State(initialValue: exercise.name)
        _exerciseDetails = State(initialValue: exercise.details)
        _exerciseNotes = State(initialValue: exercise.notes)
        _setCount = State(initialValue: exercise.setCount)
        _groupLabel = State(initialValue: exercise.groupLabel)
        _category = State(initialValue: exercise.category)
        _targetRepRange = State(initialValue: exercise.targetRepRange)
        _restSeconds = State(initialValue: exercise.restSeconds)
    }
    
    var body: some View {
        Form {
            Section("Exercise Info") {
                TextField("Exercise Name", text: $exerciseName)
                TextField("Details", text: $exerciseDetails)
                TextField("Notes", text: $exerciseNotes, axis: .vertical)
                TextField("Group Label (optional: A, B, C)", text: $groupLabel)
                TextField("Target Rep Range", text: $targetRepRange)
                Stepper("Rest: \(restSeconds) sec", value: $restSeconds, in: 30...300, step: 15)
            }
        }
        .navigationTitle("Edit Exercise")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Duplicate") {
                    appStore.duplicateExercise(id: exercise.id)
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    appStore.updateExercise(
                        id: exercise.id,
                        name: exerciseName,
                        details: exerciseDetails,
                        notes: exerciseNotes,
                        setCount: setCount,
                        groupLabel: groupLabel.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                        category: category,
                        targetRepRange: targetRepRange,
                        restSeconds: restSeconds
                    )
                    dismiss()
                }
            }
        }
    }
}
struct EditWorkoutTitleView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var notes: String
    
    init(appStore: AppStore) {
        self.appStore = appStore
        _title = State(initialValue: appStore.todaysWorkoutTitle)
        _notes = State(initialValue: appStore.todaysWorkoutNotes)}
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Title") {
                    TextField("Title", text: $title)
                }
                Section("Workout Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                }
            }
            .navigationTitle("Edit Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.todaysWorkoutTitle = title
                        dismiss ()
                        appStore.todaysWorkoutNotes = notes
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
struct ExerciseProgressDetailView: View {
    let exerciseName: String
    @Bindable var appStore: AppStore

    var entries: [WorkoutHistoryEntry] {
        appStore.historyEntries
            .filter { $0.exercise == exerciseName }
            .sorted { $0.date > $1.date }
    }

    var chartPoints: [(date: Date, value: Double)] {
        entries
            .map { entry in
                let bestSetValue = entry.sets
                    .compactMap { set -> Double? in
                        if bestWeight > 0 {
                            return Double(set.weight)
                        } else {
                            return Double(set.reps)
                        }
                    }
                    .max() ?? 0

                return (
                    date: entry.date,
                    value: bestSetValue
                )
            }
            .sorted { $0.date < $1.date }
    }

    var bestWeight: Double {
        entries
            .flatMap { $0.sets }
            .compactMap { Double($0.weight) }
            .max() ?? 0
    }

    var bestReps: Int {
        entries
            .flatMap { $0.sets }
            .compactMap { Int($0.reps) }
            .max() ?? 0
    }

    var sessionCount: Int {
        entries.count
    }

    var lastPerformed: Date? {
        entries.first?.date
    }

    var firstPerformed: Date? {
        entries.last?.date
    }

    var topSet: WorkoutSetEntry? {
        entries
            .flatMap { $0.sets }
            .max {
                let lhsWeight = Double($0.weight) ?? 0
                let rhsWeight = Double($1.weight) ?? 0

                if lhsWeight == rhsWeight {
                    return (Int($0.reps) ?? 0) < (Int($1.reps) ?? 0)
                }

                return lhsWeight < rhsWeight
            }
    }
    var firstChartValue: Double? {
        chartPoints.first?.value
    }

    var latestChartValue: Double? {
        chartPoints.last?.value
    }

    var trendDifference: Double {
        guard let first = firstChartValue,
              let latest = latestChartValue else {
            return 0
        }

        return latest - first
    }

    var trendLabel: String {
        if trendDifference > 0 {
            return "Trending Up"
        } else if trendDifference < 0 {
            return "Trending Down"
        } else {
            return "Stable"
        }
    }

    var trendDetail: String {
        guard chartPoints.count >= 2 else {
            return "More sessions needed."
        }

        let unit = bestWeight > 0 ? "lb" : "reps"

        if trendDifference > 0 {
            return "+\(Int(trendDifference)) \(unit) since first logged"
        } else if trendDifference < 0 {
            return "\(Int(trendDifference)) \(unit) since first logged"
        } else {
            return "No major change yet."
        }
    }
    var daysSinceLastPerformed: Int {
        guard let lastPerformed else {
            return 0
        }

        return Calendar.current.dateComponents(
            [.day],
            from: lastPerformed,
            to: Date()
        ).day ?? 0
    }

    var trainingStatus: String {
        if sessionCount < 3 {
            return "New Exercise"
        }

        if daysSinceLastPerformed >= 21 {
            return "Detraining Risk"
        }

        if daysSinceLastPerformed >= 10 {
            return "Needs Attention"
        }

        return "Consistent"
    }

    var trainingStatusDetail: String {
        if sessionCount < 3 {
            return "\(sessionCount) sessions logged."
        }

        if daysSinceLastPerformed >= 21 {
            return "Last trained \(daysSinceLastPerformed) days ago."
        }

        if daysSinceLastPerformed >= 10 {
            return "Last trained \(daysSinceLastPerformed) days ago. Consider getting this back in rotation."
        }

        if daysSinceLastPerformed == 0 {
            return "Trained today."
        }

        return "Last trained \(daysSinceLastPerformed) days ago."
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(exerciseName)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.appTextPrimary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Best")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)

                    if bestWeight > 0 {
                        Text("\(Int(bestWeight)) lb")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)
                    } else {
                        Text("\(bestReps) reps")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appCard)
                .cornerRadius(16)

                if let topSet {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Top Set")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)

                        let weightValue = Double(topSet.weight) ?? 0

                        Text(
                            weightValue > 0
                            ? "\(Int(weightValue)) lb x \(topSet.reps)"
                            : "Bodyweight x \(topSet.reps)"
                        )
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)

                        Text("RPE \(topSet.rpe)")
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(16)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Stats")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)

                    Text("\(sessionCount) Sessions Logged")
                        .foregroundColor(.appTextPrimary)

                    if let lastPerformed {
                        Text("Last Performed: \(formattedDateTime(lastPerformed))")
                            .foregroundColor(.appTextSecondary)
                    }

                    if let firstPerformed {
                        Text("First Logged: \(formattedDateTime(firstPerformed))")
                            .foregroundColor(.appTextSecondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appCard)
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.appTextSecondary)

                    Text(trainingStatus)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appTextPrimary)

                    Text(trainingStatusDetail)
                        .foregroundColor(.appTextSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appCard)
                .cornerRadius(16)

                if chartPoints.count >= 2 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trend")
                            .font(.caption)
                            .foregroundColor(.appTextSecondary)
                        
                        Text(trendLabel)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appTextPrimary)

                        Text(trendDetail)
                            .foregroundColor(.appTextSecondary)

                        Chart(chartPoints, id: \.date) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Value", point.value)
                            )

                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Value", point.value)
                            )
                        }
                        .chartYAxis(.hidden)
                        .chartXAxis(.hidden)
                        .frame(height: 140)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(16)
                }

                Text("Recent Sessions")
                    .font(.headline)
                    .foregroundColor(.appTextSecondary)

                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formattedDateTime(entry.date))
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)

                        ForEach(entry.sets) { set in
                            let weightValue = Double(set.weight) ?? 0

                            Text(
                                weightValue > 0
                                ? "Set \(set.setNumber): \(Int(weightValue)) lb x \(set.reps) • RPE \(set.rpe)"
                                : "Set \(set.setNumber): Bodyweight x \(set.reps) • RPE \(set.rpe)"
                            )
                            .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Progress Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct TrainingProgressView: View {
    @Bindable var appStore: AppStore
    @State private var selectedCategory: ExerciseCategory = .mainLift
    @State private var showAddBodyweightSheet = false
    
    var filteredPRs: [ExercisePR] {
        appStore.exercisePRs.filter { $0.category == selectedCategory }
    }
    var body: some View {
        NavigationStack {
            List {
                if let latest = appStore.latestBodyweight {
                    Section("Bodyweight") {
                        HStack {
                            Text("Latest")
                            Spacer()
                            Text("\(latest, specifier: "%.1f") lbs")
                                .font(.headline)
                        }
                        
                        if let average = appStore.averageBodyweight {
                            HStack {
                                Text("Average")
                                Spacer()
                                Text("\(average, specifier: "%.1f") lbs")
                                    .foregroundColor(.secondary)
                            }
                        }
                        if let difference = appStore.bodyweightDifferenceFromAverage {
                            HStack {
                                Text("Vs. Average")
                                Spacer()
                                Text("\(difference >= 0 ? "+" : "")\(difference, specifier: "%.1f") lbs")
                                    .foregroundColor(.secondary)
                            }
                        }
                        if appStore.bodyweightEntries.count >= 2 {
                            Chart(appStore.bodyweightEntries.reversed(), id: \.date) { entry in
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Weight", entry.weight)
                                )
                                
                                PointMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Weight", entry.weight)
                                )
                            }
                            .chartYScale(domain: appStore.minimumBodyweight...appStore.maximumBodyweight)
                            .frame(height: 160)
                        }
                        }
                        Button {
                            showAddBodyweightSheet = true
                        } label: {
                            Text("Add Bodyweight")
                        }
                        NavigationLink {
                            BodyweightHistoryView(appStore: appStore)
                        } label: {
                            Text("View Bodyweight History")
                        }
                    }
                if let latestReadiness = appStore.latestReadiness {
                    Section("Readiness") {
                        HStack {
                            Text("Latest")
                            Spacer()
                            Text("\(latestReadiness, specifier: "%.1f")/10")
                                .font(.headline)
                        }
                        
                        if appStore.readinessEntries.count >= 2 {
                            Chart(appStore.readinessEntries, id: \.date) { entry in
                                LineMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Readiness", entry.readiness)
                                )
                                
                                PointMark(
                                    x: .value("Date", entry.date),
                                    y: .value("Readiness", entry.readiness)
                                )
                            }
                            .chartYScale(domain: 1...10)
                            .frame(height: 160)
                        }
                    }
                }
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if filteredPRs.isEmpty {
                    Text("No progress data for \(selectedCategory.rawValue.lowercased()) yet.")
                        .foregroundColor(.secondary)
                } else {
                    Section(selectedCategory.rawValue) {
                        ForEach(filteredPRs) { pr in
                            NavigationLink {
                                ExerciseProgressDetailView(
                                    exerciseName: pr.exercise,
                                    appStore: appStore
                                )
                            } label: {
                                HStack {
                                    Text(pr.exercise)
                                        .font(.headline)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Spacer()
                                    
                                    Text(pr.displayValue)
                                        .font(.headline)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(.appTextSecondary)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.appCard)
                                .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.appBackground)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Progress")
            .sheet(isPresented: $showAddBodyweightSheet) {
                AddBodyweightView(appStore: appStore)
            }
        }
    }
}
struct ActiveWorkoutView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStepIndex = 0
    @State private var weight = ""
    @State private var reps = ""
    @State private var rpe = ""
    @State private var completedSets: [WorkoutSetEntry] = []
    @State private var showRestTimer = false
    @State private var restTimeRemaining = 90
    @State private var showWorkoutCheckOut = false
    @State private var lastWeightByExerciseID: [UUID: String] = [:]
    @State private var weightSuggestion = ""
    @State private var suggestedNextWeight = ""
    @State private var showSuggestionCard = false
    @State private var suggestionNeedsChoice = true
    @State private var showWorkoutBrief = false
    @State private var completedWorkoutSets: [WorkoutSetEntry] = []
    @State private var completedWorkoutSetsByExercise: [String: [WorkoutSetEntry]] = [:]
    
    let onFinish: () -> Void
    
    var workoutSteps: [ActiveWorkoutStep] {
        let exercises = appStore.todaysExercises
        var steps: [ActiveWorkoutStep] = []
        var usedGroupedExerciseIDs = Set<UUID>()
        
        for exercise in exercises {
            if exercise.groupLabel.isEmpty {
                for setNumber in 1...exercise.setCount {
                    steps.append(ActiveWorkoutStep(exercise: exercise, setNumber: setNumber))
                }
            } else if !usedGroupedExerciseIDs.contains(exercise.id) {
                let groupExercises = exercises.filter { $0.groupLabel == exercise.groupLabel }
                let maxSets = groupExercises.map { $0.setCount }.max() ?? 0
                
                for setNumber in 1...maxSets {
                    for groupExercise in groupExercises {
                        if setNumber <= groupExercise.setCount {
                            steps.append(ActiveWorkoutStep(exercise: groupExercise, setNumber: setNumber))
                        }
                    }
                }
                
                for groupExercise in groupExercises {
                    usedGroupedExerciseIDs.insert(groupExercise.id)
                }
            }
        }
        
        return steps
    }
    
    var currentStep: ActiveWorkoutStep? {
        guard workoutSteps.indices.contains(currentStepIndex) else { return nil }
        return workoutSteps[currentStepIndex]
    }
    
    var isLastStep: Bool {
        currentStepIndex == workoutSteps.count - 1
    }
    var totalWorkoutSets: Int {
        completedWorkoutSets.count
    }
    
    var totalWorkoutReps: Int {
        completedWorkoutSets
            .compactMap { Int($0.reps) }
            .reduce(0, +)
    }
    
    var totalWorkoutVolume: Int {
        completedWorkoutSets.reduce(0) { total, set in
            let weight = Int(set.weight) ?? 0
            let reps = Int(set.reps) ?? 0
            return total + (weight * reps)
        }
    }
    
    var averageWorkoutRPE: Double {
        let rpes = completedWorkoutSets.compactMap { Double($0.rpe) }
        guard !rpes.isEmpty else { return 0 }
        return rpes.reduce(0, +) / Double(rpes.count)
    }
    func loadLastWeightForExercise(_ exercise: ExerciseItem) -> String {
        let matchingEntries = appStore.historyEntries
            .filter { $0.exercise == exercise.name }
            .sorted { $0.date > $1.date }
        
        guard let latest = matchingEntries.first,
              let lastSet = latest.sets.last else {
            return ""
        }
        
        return lastSet.weight
    }
    func latestReadinessScore() -> Double? {
        appStore.checkIns
            .sorted { $0.date > $1.date }
            .first?
            .readinessAverage
    }
    func readinessRecommendationText() -> String {
        guard let readiness = latestReadinessScore() else {
            return "No readiness data yet."
        }
        
        if readiness >= 8 {
            return "Readiness is high today. Get after it."
        } else if readiness >= 5 {
            return "Typical day. Stay the course. Don't chase PRs."
        } else {
            return "Way to show up when you aren't feeling it. Reduce load today and stack quality reps."
        }
    }
    func suggestedStartWeightFromHistory(_ exercise: ExerciseItem) -> String {
        let matchingEntries = appStore.historyEntries
            .filter { $0.exercise == exercise.name }
            .sorted { $0.date > $1.date }
        
        guard let latest = matchingEntries.first,
              let lastSet = latest.sets.last else {
            return ""
        }
        
        guard let weight = Double(lastSet.weight),
              let reps = Int(lastSet.reps),
              let rpe = Double(lastSet.rpe) else {
            return lastSet.weight
        }
        
        let rangeParts = exercise.targetRepRange
            .split(separator: "-")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        
        guard rangeParts.count == 2 else {
            return lastSet.weight
        }
        
        let low = rangeParts[0]
        let high = rangeParts[1]
        
        if reps >= high && rpe <= 6 {
            return "\(Int(weight + 10))"
        } else if reps < low && rpe >= 9 {
            return "\(Int(weight - 10))"
        } else {
            return "\(Int(weight))"
        }
    }
    func readinessAdjustedSuggestion(
        previous: String,
        suggested: String
    ) -> String {
        guard let readiness = latestReadinessScore(),
              let previousWeight = Double(previous),
              let suggestedWeight = Double(suggested) else {
            return suggested
        }
        
        if readiness < 5 {
            return "\(Int(previousWeight))"
        }
        
        return "\(Int(suggestedWeight))"
    }
    
    func workoutBriefItems() -> [WorkoutBriefItem] {
        appStore.todaysExercises.map { exercise in
            
            let previous = loadLastWeightForExercise(exercise)
            let suggestedRaw = suggestedStartWeightFromHistory(exercise)
            
            let suggested: String
            let recommendation: String
            let reason: String
            let showReason: Bool
            
            if exercise.category == .bodyweight {
                let matchingEntries = appStore.historyEntries
                    .filter { $0.exercise == exercise.name }
                    .sorted { $0.date > $1.date }
                
                let lastReps = matchingEntries.first?.sets.last?.reps ?? ""
                
                let rangeParts = exercise.targetRepRange
                    .split(separator: "-")
                    .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                
                let lastRepNumber = Int(lastReps) ?? 0
                
                let goal = rangeParts.last ?? (
                    lastRepNumber > 0 ? lastRepNumber + 1 : 5
                )
                
                suggested = "Goal: \(goal) reps"
                
                if let last = Int(lastReps), last < goal {
                    recommendation = "+1 rep recommended"
                    reason = "Last: \(last) reps"
                    showReason = true
                } else {
                    recommendation = ""
                    reason = lastReps.isEmpty ? "" : "Last: \(lastReps) reps"
                    showReason = !lastReps.isEmpty
                }
                
            } else {
                let readinessAdjusted =
                readinessAdjustedSuggestion(
                    previous: previous,
                    suggested: suggestedRaw
                )
                
                suggested = suggestedRaw.isEmpty ? "No history" : readinessAdjusted
                
                let changed = previous != suggested && !previous.isEmpty
                
                recommendation = changed ? "\(suggested) recommended" : ""
                
                if changed {
                    let matchingEntries = appStore.historyEntries
                        .filter { $0.exercise == exercise.name }
                        .sorted { $0.date > $1.date }
                    
                    let lastSet = matchingEntries.first?.sets.last
                    let lastRPE = Double(lastSet?.rpe ?? "") ?? 0
                    
                    if suggestedRaw > previous {
                        reason = """
                        Top of rep range
                        Low effort (RPE \(Int(lastRPE)))
                        """
                    } else {
                        reason = """
                        Below target reps
                        High effort (RPE \(Int(lastRPE)))
                        """
                    }
                } else {
                    reason = ""
                }
                
                showReason = changed
            }
            
            return WorkoutBriefItem(
                exercise: exercise,
                suggestedWeight: suggested,
                previousWeight: previous,
                recommendation: recommendation,
                showReason: showReason,
                reason: reason
            )
        }
    }
    func saveCurrentSet() {
        guard let step = currentStep else { return }
        
        let set = WorkoutSetEntry(
            id: UUID(),
            setNumber: step.setNumber,
            weight: weight,
            reps: reps,
            rpe: rpe
        )
        
        completedSets.append(set)
        completedWorkoutSets.append(set)
        completedWorkoutSetsByExercise[
            step.exercise.name,
            default: []
        ].append(set)
        lastWeightByExerciseID[step.exercise.id] = weight
        
        if step.setNumber == step.exercise.setCount {
            let entry = WorkoutHistoryEntry(
                id: UUID(),
                workoutTitle: appStore.todaysWorkoutTitle,
                date: Date(),
                exercise: step.exercise.name,
                details: step.exercise.details,
                sets: completedSets
            )
            
            appStore.historyEntries.insert(entry, at: 0)
            completedSets.removeAll()
        }
    }
    
    func continueAfterSuggestion() {
        showSuggestionCard = false
        
        if isLastStep {
            advanceWorkout()
        } else if shouldShowRestAfterCurrentStep() {
            restTimeRemaining = currentStep?.exercise.restSeconds ?? 90
            showRestTimer = true
        } else {
            advanceWorkout()
        }
    }
    
    func updateWeightSuggestion(
        exercise: ExerciseItem,
        repsText: String,
        rpeText: String,
        weightText: String
    ) {
        if exercise.category == .bodyweight {
            weightSuggestion = ""
            suggestedNextWeight = ""
            suggestionNeedsChoice = false
            return
        }
        guard let reps = Int(repsText),
              let rpe = Double(rpeText),
              let weight = Double(weightText) else {
            weightSuggestion = ""
            suggestedNextWeight = ""
            suggestionNeedsChoice = false
            return
        }
        
        let rangeParts = exercise.targetRepRange
            .split(separator: "-")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        
        guard rangeParts.count == 2 else {
            weightSuggestion = ""
            suggestedNextWeight = ""
            suggestionNeedsChoice = false
            return
        }
        
        let low = rangeParts[0]
        let high = rangeParts[1]
        
        if reps >= high && rpe <= 6 {
            if let readiness = latestReadinessScore(),
               readiness < 5 {
                suggestedNextWeight = ""
                suggestionNeedsChoice = false
                weightSuggestion = ""
                return
            }
            
            let suggested = Int(weight + 10)
            suggestedNextWeight = "\(suggested)"
            suggestionNeedsChoice = true
            weightSuggestion = "This looked easy. Increase to \(suggested) next set."
            
        } else if reps >= low && reps <= high && rpe >= 7 && rpe <= 8 {
            suggestedNextWeight = "\(Int(weight))"
            suggestionNeedsChoice = false
            weightSuggestion = "Good working weight. Keep it here!"
        } else if reps < low && rpe >= 9 {
            let suggested = Int(weight - 10)
            suggestedNextWeight = "\(suggested)"
            suggestionNeedsChoice = true
            weightSuggestion = "Too heavy for today. Reduce weight to \(suggested) next set."
        } else {
            suggestedNextWeight = ""
            suggestionNeedsChoice = false
            weightSuggestion = "Log the next set based on feel."
        }
    }
    func workoutPRs() -> [WorkoutPR] {
        var prs: [WorkoutPR] = []
        var seenPRs = Set<String>()
        
        for entry in appStore.historyEntries {
            guard let exercise = appStore.todaysExercises.first(
                where: { $0.name == entry.exercise }
            ) else {
                continue
            }
            
            let exerciseSets =
            completedWorkoutSetsByExercise[
                entry.exercise
            ] ?? []
            
            guard !exerciseSets.isEmpty else {
                continue
            }
            
            switch exercise.category {
            case .mainLift:
                let currentBestWeight =
                exerciseSets
                    .compactMap { Double($0.weight) }
                    .max() ?? 0
                
                let previousBestWeight =
                entry.sets
                    .compactMap { Double($0.weight) }
                    .max() ?? 0
                
                if currentBestWeight > previousBestWeight {
                    let key = "\(entry.exercise)-Weight"
                    
                    if !seenPRs.contains(key) {
                        prs.append(
                            WorkoutPR(
                                exercise: entry.exercise,
                                type: "Weight PR",
                                value: "\(Int(currentBestWeight)) lb"
                            )
                        )
                        
                        seenPRs.insert(key)
                    }
                }
                
            case .accessory:
                let currentVolume =
                exerciseSets.reduce(0) { total, set in
                    let weight = Double(set.weight) ?? 0
                    let reps = Double(set.reps) ?? 0
                    return total + (weight * reps)
                }
                
                let previousVolume =
                entry.sets.reduce(0) { total, set in
                    let weight = Double(set.weight) ?? 0
                    let reps = Double(set.reps) ?? 0
                    return total + (weight * reps)
                }
                
                if currentVolume > previousVolume {
                    let key = "\(entry.exercise)-Volume"
                    
                    if !seenPRs.contains(key) {
                        prs.append(
                            WorkoutPR(
                                exercise: entry.exercise,
                                type: "Volume PR",
                                value: "\(Int(currentVolume)) lb volume"
                            )
                        )
                        
                        seenPRs.insert(key)
                    }
                }
                
            case .bodyweight:
                let currentBestReps =
                exerciseSets
                    .compactMap { Int($0.reps) }
                    .max() ?? 0
                
                let previousBestReps =
                entry.sets
                    .compactMap { Int($0.reps) }
                    .max() ?? 0
                
                if currentBestReps > previousBestReps {
                    let key = "\(entry.exercise)-Rep"
                    
                    if !seenPRs.contains(key) {
                        prs.append(
                            WorkoutPR(
                                exercise: entry.exercise,
                                type: "Rep PR",
                                value: "\(currentBestReps) reps"
                            )
                        )
                        
                        seenPRs.insert(key)
                    }
                }
                
            case .conditioning:
                continue
            }
        }
        
        return prs
    }
    func clearInputs() {
        if let nextStep = currentStep {
            reps = defaultRepStart(for: nextStep.exercise)
        } else {
            reps = ""
        }
        rpe = ""
        
        if let nextStep = currentStep {
            if let remembered = lastWeightByExerciseID[nextStep.exercise.id] {
                weight = remembered
            } else if nextStep.setNumber == 1 {
                weight = suggestedStartWeightFromHistory(nextStep.exercise)
            } else {
                weight = ""
            }
        } else {
            weight = ""
        }
    }
    func defaultRepStart(for exercise: ExerciseItem) -> String {

        if exercise.category == .bodyweight {

            let matchingEntries = appStore.historyEntries
                .filter {
                    $0.exercise == exercise.name
                }
                .sorted {
                    $0.date > $1.date
                }

            let lastReps =
            Int(
                matchingEntries
                    .first?
                    .sets
                    .last?
                    .reps ?? ""
            ) ?? 0

            if lastReps > 0 {
                return "\(lastReps + 1)"
            }
        }

        let rangeParts = exercise.targetRepRange
            .split(separator: "-")
            .compactMap {
                Int(
                    $0.trimmingCharacters(
                        in: .whitespaces
                    )
                )
            }

        if let low = rangeParts.first {
            return "\(low)"
        }

        return ""
    }
    
    func advanceWorkout() {
        if isLastStep {
            let workout = WorkoutCompleteEntry(
                id: UUID(),
                title: appStore.todaysWorkoutTitle,
                date: Date()
            )
            
            appStore.completedWorkouts.insert(workout, at: 0)
            showWorkoutCheckOut = true
        } else {
            currentStepIndex += 1
            clearInputs()
        }
    }
    
    func shouldShowRestAfterCurrentStep() -> Bool {
        guard let current = currentStep else { return false }
        if isLastStep { return false }
        guard workoutSteps.indices.contains(currentStepIndex + 1) else { return false }
        
        let next = workoutSteps[currentStepIndex + 1]
        
        if current.exercise.groupLabel.isEmpty {
            return true
        }
        
        return current.exercise.groupLabel != next.exercise.groupLabel ||
        current.setNumber != next.setNumber
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if let step = currentStep {
                    Text(appStore.todaysWorkoutTitle)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Step \(currentStepIndex + 1) of \(workoutSteps.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(step.exercise.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Set \(step.setNumber) of \(step.exercise.setCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if !step.exercise.groupLabel.isEmpty {
                        Text("Group \(step.exercise.groupLabel)")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Text(step.exercise.details)
                        .foregroundColor(.secondary)
                    
                    if !step.exercise.notes.isEmpty {
                        Text(step.exercise.notes)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Target: \(step.exercise.targetRepRange) reps")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Rest: \(step.exercise.restSeconds) sec")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Log This Set")
                            .font(.headline)
                        
                        TextField(
                            step.exercise.category == .bodyweight ? "Added/Assisted Weight" : "Weight",
                            text: $weight
                        )
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reps")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)

                            HStack {
                                Button {
                                    let current = Int(reps) ?? 0
                                    reps = "\(max(0, current - 1))"
                                } label: {
                                    Text("-")
                                        .font(.title2)
                                        .frame(width: 56, height: 44)
                                        .background(Color.appCardSecondary)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }

                                Text(reps.isEmpty ? "0" : reps)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.appTextPrimary)

                                Button {
                                    let current = Int(reps) ?? 0
                                    reps = "\(current + 1)"
                                } label: {
                                    Text("+")
                                        .font(.title2)
                                        .frame(width: 56, height: 44)
                                        .background(Color.appPrimary)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("RPE")
                                .font(.headline)
                                .foregroundColor(.appTextPrimary)

                            HStack {
                                ForEach(5...10, id: \.self) { value in

                                    Button {
                                        rpe = "\(value)"
                                    } label: {
                                        Text("\(value)")
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                rpe == "\(value)"
                                                ? Color.appPrimary
                                                : Color.appCardSecondary
                                            )
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        if !weightSuggestion.isEmpty {
                            Text(weightSuggestion)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.appCard)
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    HStack {
                        Button {
                            if currentStepIndex > 0 {
                                currentStepIndex -= 1
                                clearInputs()
                            }
                        } label: {
                            Text("Previous")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                        .disabled(currentStepIndex == 0)
                        
                        Button {
                            saveCurrentSet()
                            
                            if let step = currentStep {
                                updateWeightSuggestion(
                                    exercise: step.exercise,
                                    repsText: reps,
                                    rpeText: rpe,
                                    weightText: weight
                                )
                            }
                            
                            if isLastStep {
                                advanceWorkout()
                            } else if suggestionNeedsChoice &&
                                        !suggestedNextWeight
                                .trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                    .isEmpty {
                                
                                showSuggestionCard = true
                                
                            } else {
                                
                                continueAfterSuggestion()
                            }
                            
                        } label: {
                            Text(isLastStep ? "Finish Workout" : "Save & Next")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isLastStep ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    Text("No exercises in today’s workout.")
                        .foregroundColor(.secondary)
                    
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .padding()
            .navigationTitle("Active Workout")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showRestTimer) {
                RestTimerView(
                    secondsRemaining: $restTimeRemaining,
                    onComplete: {
                        showRestTimer = false
                        advanceWorkout()
                    }
                )
            }
            .sheet(isPresented: $showWorkoutCheckOut) {
                WorkoutCheckOutView(
                    appStore: appStore,
                    totalSets: totalWorkoutSets,
                    totalReps: totalWorkoutReps,
                    totalVolume: totalWorkoutVolume,
                    averageRPE: averageWorkoutRPE,
                    prs: workoutPRs(),
                    onFinish: {
                        dismiss()
                        onFinish()
                    }
                )
            }
            .sheet(isPresented: $showSuggestionCard) {
                NavigationStack {
                    VStack(spacing: 24) {
                        Text("Suggested Next Weight")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if !suggestedNextWeight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("\(suggestedNextWeight) lb")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                        }
                        
                        Text(weightSuggestion)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if suggestionNeedsChoice {
                            Button {
                                if let step = currentStep {
                                    lastWeightByExerciseID[step.exercise.id] = suggestedNextWeight
                                }
                                
                                weight = suggestedNextWeight
                                continueAfterSuggestion()
                            } label: {
                                Text("Apply")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.appPrimary)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                continueAfterSuggestion()
                            } label: {
                                Text("Keep Current")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        if !suggestionNeedsChoice {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                continueAfterSuggestion()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showWorkoutBrief) {
                NavigationStack {
                    ZStack {
                        Color.appBackground
                            .ignoresSafeArea()
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                
                                Text("Workout Brief")
                                    .font(.system(size: 44, weight: .bold))
                                    .fontWeight(.bold)
                                    .foregroundColor(.appTextPrimary)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    if let readiness = latestReadinessScore() {
                                        Text("Readiness: \(readiness, specifier: "%.1f")/10")
                                            .font(.headline)
                                            .foregroundColor(.appTextPrimary)
                                        
                                        Text(readinessRecommendationText())
                                            .foregroundColor(.appTextSecondary)
                                    }
                                }
                                .padding()
                                .background(Color.appCard)
                                .cornerRadius(12)
                                
                                ForEach(workoutBriefItems()) { item in
                                    VStack(alignment: .leading, spacing: 8) {
                                        
                                        Text(item.exercise.name)
                                            .font(.headline)
                                            .foregroundColor(.appTextPrimary)
                                        
                                        VStack(alignment: .leading, spacing: 4) {

                                            Text("Suggested")
                                                .font(.caption)
                                                .foregroundColor(.appTextSecondary)

                                            Text(item.suggestedWeight)
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.appTextPrimary)

                                            if !item.previousWeight.isEmpty {

                                                Text("Last")
                                                    .font(.caption)
                                                    .foregroundColor(.appTextSecondary)

                                                Text(item.previousWeight)
                                                    .foregroundColor(.appTextPrimary)
                                            }
                                        }
                                        
                                        if !item.recommendation.isEmpty {
                                            Text(item.recommendation)
                                                .foregroundColor(.appTextPrimary)
                                        }
                                        
                                        if item.showReason {
                                            Text(item.reason)
                                                .font(.caption)
                                                .foregroundColor(.appTextSecondary)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appCard)
                                    .cornerRadius(16)
                                }
                                
                                Button("Let's Train.") {
                                    showWorkoutBrief = false
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .onAppear {
                if let step = currentStep,
                   step.setNumber == 1 {

                    if weight.isEmpty {
                        weight = suggestedStartWeightFromHistory(
                            step.exercise
                        )
                    }

                    if reps.isEmpty {
                        reps = defaultRepStart(
                            for: step.exercise
                        )
                    }
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.3
                ) {
                    showWorkoutBrief = true
                }
            }
        }
    }
}
struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.headline)
        }
        .padding()
        .background(Color.appCard)
        .cornerRadius(12)
    }
}
struct RestTimerView: View {
    @Binding var secondsRemaining: Int
    var onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Rest")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(secondsRemaining)")
                    .font(.system(size: 80, weight: .bold))
                    .monospacedDigit()
                
                Button {
                    dismiss()
                    onComplete()
                } label: {
                    Text("Skip Rest")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .onReceive(timer) { _ in
                if secondsRemaining > 0 {
                    secondsRemaining -= 1
                } else {
                    dismiss()
                    onComplete()
                }
            }
        }
    }
}
struct WorkoutCheckInView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var sleep = 5
    @State private var stress = 5
    @State private var recovery = 5
    @State private var motivation = 5
    @State private var energy = 5
    @State private var mood = 5
    @State private var bodyweight = ""
    
    @State private var showActiveWorkout = false
    
    let onFinish: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Readiness Check-In") {
                    RatingChipSelector(title: "Sleep", value: $sleep)
                    ReadinessSlider(title: "Stress", value: $stress)
                    ReadinessSlider(title: "Recovery", value: $recovery)
                    ReadinessSlider(title: "Motivation", value: $motivation)
                    ReadinessSlider(title: "Energy", value: $energy)
                    ReadinessSlider(title: "Mood", value: $mood)
                }
                
                Section("Bodyweight") {
                    TextField("Bodyweight", text: $bodyweight)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Workout Check-In")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Begin") {
                        appStore.addCheckIn(
                            sleep: sleep,
                            stress: stress,
                            recovery: recovery,
                            motivation: motivation,
                            energy: energy,
                            mood: mood,
                            bodyweight: bodyweight
                        )
                        showActiveWorkout = true
                    }
                }
            }
            .sheet(isPresented: $showActiveWorkout) {
                ActiveWorkoutView(
                    appStore: appStore,
                    onFinish: {
                        dismiss()
                        onFinish()
                    }
                )
            }
            
        }
        var readinessAverage: Double {
            let total = sleep + recovery + motivation + energy + mood + (6 - stress)
            return Double(total) / 6.0
        }
    }
}
struct ReadinessSlider: View {
    let title: String
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(value)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0.rounded()) }
                ),
                in: 1...10,
                step: 1
            )
            
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("10")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
struct WorkoutCheckOutView: View {
    @Bindable var appStore: AppStore
    
    let totalSets: Int
    let totalReps: Int
    let totalVolume: Int
    let averageRPE: Double
    let prs: [WorkoutPR]
    let onFinish: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var sessionRPE = 7
    @State private var injuryNotes = ""
    @State private var showWorkoutSummary = false
    @State private var completedWorkoutPRs: [WorkoutPR] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Session Difficulty") {
                    ReadinessSlider(
                        title: "Session RPE",
                        value: $sessionRPE
                    )
                }
                
                Section("Pain / Injury Notes") {
                    TextField(
                        "Any pain, soreness, tweaks, etc.",
                        text: $injuryNotes,
                        axis: .vertical
                    )
                }
                if !prs.isEmpty {

                    Section("PRs Hit") {

                        ForEach(prs) { pr in

                            HStack {

                                Text(pr.exercise)

                                Spacer()

                                Text(pr.type)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                Section("Workout Summary") {
        
                    HStack {
                        Text("Sets Completed")
                        Spacer()
                        Text("\(totalSets)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Reps")
                        Spacer()
                        Text("\(totalReps)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Volume")
                        Spacer()
                        Text("\(totalVolume) lb")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Average RPE")
                        Spacer()
                        Text(String(format: "%.1f", averageRPE))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Workout Check-Out")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Session") {
                        
                        completedWorkoutPRs = prs
                        
                        appStore.addCheckOut(
                            sessionRPE: sessionRPE,
                            injuryNotes: injuryNotes
                        )
                        for pr in prs {
                            let entry = PRHistoryEntry(
                                id: UUID(),
                                date: Date(),
                                exercise: pr.exercise,
                                type: pr.type,
                                value: pr.value,
                                workoutTitle: appStore.todaysWorkoutTitle
                            )

                            appStore.prHistoryEntries.insert(entry, at: 0)
                        }
                        
                        showWorkoutSummary = true
                    }
                }
            }
            .sheet(isPresented: $showWorkoutSummary) {

                VStack(spacing: 24) {

                    Text("Workout Complete")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(appStore.todaysWorkoutTitle)
                        .font(.title2)

                    Text("\(completedWorkoutPRs.count) PRs Earned")

                    ForEach(completedWorkoutPRs) { pr in
                        VStack {
                            Text(pr.type)
                                .font(.caption)

                            Text(pr.exercise)

                            Text(pr.value)
                                .fontWeight(.bold)
                        }
                    }

                    Button("Done") {
                        showWorkoutSummary = false
                        dismiss()
                        onFinish()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}
struct BodyweightHistoryView: View {
    @Bindable var appStore: AppStore
    
    var body: some View {
        List {
            if appStore.bodyweightEntries.isEmpty {
                Text("No bodyweight data yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(appStore.bodyweightEntries, id: \.date) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(formattedDateTime(entry.date))
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text("\(entry.weight, specifier: "%.1f") lbs")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Bodyweight")
    }
}
struct AddBodyweightView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var bodyweight = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Bodyweight") {
                    TextField("Bodyweight", text: $bodyweight)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Bodyweight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.addBodyweightEntry(weight: bodyweight)
                        dismiss()
                    }
                    .disabled(bodyweight.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
enum ActiveBJJSheet: Identifiable {
    case beltRank
    case logSession
    
    var id: String {
        switch self {
        case .beltRank:
            return "beltRank"
        case .logSession:
            return "logSession"
        }
    }
}
struct MetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.appTextPrimary)

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundColor(.appTextPrimary)
        }
    }
}
struct BJJView: View {
    @Bindable var appStore: AppStore
    @State private var activeBJJSheet: ActiveBJJSheet?
    @State private var selectedRange: BJJAnalyticsRange = .allTime
    @State private var showRecentSessions = true
    
    var totalRounds: Int {
        appStore.bjjSessions.reduce(0) { $0 + $1.totalRounds }
    }
    
    var totalLiveMinutes: Int {
        appStore.bjjSessions.reduce(0) { $0 + $1.totalLiveMinutes }
    }
    func submissionSummary(_ submissions: [SubmissionCount]) -> String {
        submissions
            .filter { $0.count > 0 }
            .sorted { $0.submission.rawValue < $1.submission.rawValue }
            .map { "\($0.submission.rawValue) x\($0.count)" }
            .joined(separator: ", ")
    }
    var filteredHardRounds: Int {
        filteredSessions
            .flatMap { $0.rounds }
            .filter { $0.roundRPE >= 8 }
            .count
    }
    var filteredAverageRoundRPE: Double {
        let allRounds = filteredSessions.flatMap { $0.rounds }
        guard !allRounds.isEmpty else { return 0 }
        
        let total = allRounds.reduce(0) { $0 + $1.roundRPE }
        return Double(total) / Double(allRounds.count)
    }
    var filteredSessions: [BJJSession] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedRange {
        case .thisWeek:
            return appStore.bjjSessions.filter { session in
                calendar.isDate(session.date, equalTo: now, toGranularity: .weekOfYear)
            }
            
        case .thisMonth:
            return appStore.bjjSessions.filter { session in
                calendar.isDate(session.date, equalTo: now, toGranularity: .month)
            }
            
        case .currentBelt:
            let currentBelt = appStore.beltRank(for: Date())
            return appStore.bjjSessions.filter { session in
                appStore.beltRank(for: session.date) == currentBelt
            }
            
        case .allTime:
            return appStore.bjjSessions
        }
    }
    var filteredTotalRounds: Int {
        filteredSessions.reduce(0) { $0 + $1.totalRounds }
    }
    
    var filteredTotalLiveMinutes: Int {
        filteredSessions.reduce(0) { $0 + $1.totalLiveMinutes }
    }
    var filteredHardLiveMinutes: Int {
        filteredSessions
            .flatMap { $0.rounds }
            .filter { $0.roundRPE >= 8 }
            .reduce(0) { $0 + $1.durationMinutes }
    }
    
    var filteredAverageSessionRPE: Double {
        guard !filteredSessions.isEmpty else { return 0 }
        let total = filteredSessions.reduce(0) { $0 + $1.sessionRPE }
        return Double(total) / Double(filteredSessions.count)
    }
    var filteredAverageReadiness: Double {
        guard !filteredSessions.isEmpty else { return 0 }
        let total = filteredSessions.reduce(0) { $0 + $1.readinessAverage }
        return total / Double(filteredSessions.count)
    }
    var lowReadinessSessions: [BJJSession] {
        filteredSessions.filter { $0.readinessAverage < 3.0 }
    }
    var highOutputLowReadinessSessions: [BJJSession] {
        filteredSessions.filter {
            $0.readinessAverage < 3.0 &&
            (
                $0.sessionRPE >= 8 ||
                $0.rounds.filter { $0.roundRPE >= 8 }.count >= 3
            )
        }
    }
    func submissionTotalsFinished() -> [(submission: SubmissionType, count: Int)] {
        var totals: [SubmissionType: Int] = [:]
        
        for session in filteredSessions {
            for item in session.submissionsFinished {
                totals[item.submission, default: 0] += item.count
            }
        }
        
        return totals
            .filter { $0.value > 0 }
            .map { (submission: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    func submissionTotalsReceived() -> [(submission: SubmissionType, count: Int)] {
        var totals: [SubmissionType: Int] = [:]
        
        for session in filteredSessions {
            for item in session.submissionsReceived {
                totals[item.submission, default: 0] += item.count
            }
        }
        
        return totals
            .filter { $0.value > 0 }
            .map { (submission: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    func roundsByPartnerBelt() -> [(belt: BeltLevel, count: Int)] {
        var totals: [BeltLevel: Int] = [:]
        
        for session in filteredSessions {
            for round in session.rounds {
                totals[round.beltLevel, default: 0] += 1
            }
        }
        
        return totals
            .filter { $0.value > 0 }
            .map { (belt: $0.key, count: $0.value) }
            .sorted { $0.belt.rawValue < $1.belt.rawValue }
    }
    var totalSubmissionsFinished: Int {
        submissionTotalsFinished().reduce(0) { $0 + $1.count }
    }
    
    var totalSubmissionsReceived: Int {
        submissionTotalsReceived().reduce(0) { $0 + $1.count }
    }
    func liveMinutesByPartnerBelt() -> [(belt: BeltLevel, minutes: Int)] {
        var totals: [BeltLevel: Int] = [:]
        
        for session in filteredSessions {
            for round in session.rounds {
                totals[round.beltLevel, default: 0] += round.durationMinutes
            }
        }
        
        return totals
            .filter { $0.value > 0 }
            .map { (belt: $0.key, minutes: $0.value) }
            .sorted { $0.belt.rawValue < $1.belt.rawValue }
    }
    var partnerBeltChartData: [(belt: BeltLevel, minutes: Int)] {
        var totals: [BeltLevel: Int] = [:]
        
        for session in filteredSessions {
            for round in session.rounds {
                totals[round.beltLevel, default: 0] += round.durationMinutes
            }
        }
        
        return totals
            .filter { $0.value > 0 }
            .map { (belt: $0.key, minutes: $0.value) }
            .sorted { $0.minutes > $1.minutes }
    }
    var bjjFatigueScore: Int {
        let liveMinutesScore = filteredTotalLiveMinutes
        let hardMinutesScore = filteredHardLiveMinutes * 2
        let hardRoundsScore = filteredHardRounds * 5
        let rpeScore = Int(filteredAverageSessionRPE * 5)
        
        return liveMinutesScore + hardMinutesScore + hardRoundsScore + rpeScore
    }
    var bjjFatigueLabel: String {
        switch bjjFatigueScore {
        case 0:
            return "No Load"
        case 1...50:
            return "Low"
        case 51...100:
            return "Moderate"
        case 101...160:
            return "High"
        default:
            return "Very High"
        }
    }
    var insightSummary: String {
        if highOutputLowReadinessSessions.count >= 3 {
            return "You frequently perform well despite lower readiness. Monitor cumulative fatigue carefully."
        }
        
        if lowReadinessSessions.count >= filteredSessions.count / 2 && filteredSessions.count >= 4 {
            return "Recent training has frequently started with lower readiness scores."
        }
        
        return "Readiness and session performance are trending normally."
    }
    var readinessChartData: [(date: Date, readiness: Double)] {
        filteredSessions
            .sorted { $0.date < $1.date }
            .map {
                (
                    date: $0.date,
                    readiness: $0.readinessAverage
                )
            }
    }
    var bjjLoadChartData: [(date: Date, load: Int)] {
        filteredSessions
            .sorted { $0.date < $1.date }
            .map { session in
                let liveMinutesScore = session.totalLiveMinutes
                
                let hardMinutes = session.rounds
                    .filter { $0.roundRPE >= 8 }
                    .reduce(0) { $0 + $1.durationMinutes }
                
                let hardRounds = session.rounds
                    .filter { $0.roundRPE >= 8 }
                    .count
                
                let rpeScore = session.sessionRPE * 5
                
                let load = liveMinutesScore + (hardMinutes * 2) + (hardRounds * 5) + rpeScore
                
                return (date: session.date, load: load)
            }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("BJJ")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                            
                            Spacer()
                            
                            Button("Update Belt") {
                                activeBJJSheet = .beltRank
                            }
                            .font(.subheadline)
                            .foregroundColor(.appPrimary)
                        }
                        
                        Button {
                            activeBJJSheet = .logSession
                        } label: {
                            Text("Log BJJ Session")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.appPrimary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overview")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        Menu {
                            ForEach(BJJAnalyticsRange.allCases, id: \.self) { range in
                                Button {
                                    selectedRange = range
                                } label: {
                                    Text(range.rawValue)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedRange.rawValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appTextPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        MetricRow(title: "Sessions", value: "\(filteredSessions.count)")
                        MetricRow(title: "Avg Readiness", value: String(format: "%.1f", filteredAverageReadiness))
                        
                        HStack {
                            Text("Current Belt")
                                .foregroundColor(.appTextPrimary)
                            
                            Spacer()
                            
                            Text(appStore.beltRank(for: Date()).rawValue)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(beltColor(appStore.beltRank(for: Date())))
                        }
                        
                        Divider()
                            .background(Color.appTextSecondary)
                        
                        MetricRow(title: "Live Rounds", value: "\(filteredTotalRounds)")
                        MetricRow(title: "Live Minutes", value: "\(filteredTotalLiveMinutes)")
                        MetricRow(title: "Avg Session RPE", value: String(format: "%.1f", filteredAverageSessionRPE))
                        MetricRow(title: "Avg Round RPE", value: String(format: "%.1f", filteredAverageRoundRPE))
                        MetricRow(title: "Hard Rounds", value: "\(filteredHardRounds)")
                        MetricRow(title: "Hard Live Minutes", value: "\(filteredHardLiveMinutes)")
                        MetricRow(title: "BJJ Load", value: "\(bjjFatigueScore) — \(bjjFatigueLabel)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Insights")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        MetricRow(
                            title: "Low Readiness Sessions",
                            value: "\(lowReadinessSessions.count)"
                        )
                        
                        MetricRow(
                            title: "High Output Despite Low Readiness",
                            value: "\(highOutputLowReadinessSessions.count)"
                        )
                        
                        if !filteredSessions.isEmpty {
                            Text(insightSummary)
                                .font(.subheadline)
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Readiness Trend")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        if readinessChartData.count < 2 {
                            Text("Not enough readiness data yet.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            Chart(readinessChartData, id: \.date) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Readiness", item.readiness)
                                )
                                
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Readiness", item.readiness)
                                )
                            }
                            .chartYScale(domain: 1...10)
                            .chartYAxis(.hidden)
                            .chartXAxis(.hidden)
                            .frame(height: 140)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("BJJ Load Trend")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        if bjjLoadChartData.count < 2 {
                            Text("Not enough load data yet.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            Chart(bjjLoadChartData, id: \.date) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Load", item.load)
                                )
                                
                                PointMark(
                                    x: .value("Date", item.date),
                                    y: .value("Load", item.load)
                                )
                            }
                            .chartYAxis(.hidden)
                            .chartXAxis(.hidden)
                            .frame(height: 140)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Partner Belt Distribution")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        if partnerBeltChartData.isEmpty {
                            Text("No live rounds in this range.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ZStack {
                                Chart(partnerBeltChartData, id: \.belt) { item in
                                    SectorMark(
                                        angle: .value("Minutes", item.minutes),
                                        innerRadius: .ratio(0.6)
                                    )
                                    .foregroundStyle(by: .value("Belt", item.belt.rawValue))
                                }
                                .frame(height: 220)
                                
                                VStack(spacing: 4) {
                                    Text("\(filteredTotalLiveMinutes)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Text("Live Min")
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Submission Finishes")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        let finishedTotals = submissionTotalsFinished()
                        
                        if finishedTotals.isEmpty {
                            Text("No submissions finished in this range.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ZStack {
                                Chart(finishedTotals, id: \.submission) { item in
                                    SectorMark(
                                        angle: .value("Count", item.count),
                                        innerRadius: .ratio(0.6)
                                    )
                                    .foregroundStyle(by: .value("Submission", item.submission.rawValue))
                                }
                                .frame(height: 220)
                                
                                VStack(spacing: 4) {
                                    Text("\(totalSubmissionsFinished)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Text("Finishes")
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Submitted By")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        let receivedTotals = submissionTotalsReceived()
                        
                        if receivedTotals.isEmpty {
                            Text("No submissions received in this range.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ZStack {
                                Chart(receivedTotals, id: \.submission) { item in
                                    SectorMark(
                                        angle: .value("Count", item.count),
                                        innerRadius: .ratio(0.6)
                                    )
                                    .foregroundStyle(by: .value("Submission", item.submission.rawValue))
                                }
                                .frame(height: 220)
                                
                                VStack(spacing: 4) {
                                    Text("\(totalSubmissionsReceived)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Text("Received")
                                        .foregroundColor(.appTextSecondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rounds by Partner Belt")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        let beltTotals = roundsByPartnerBelt()
                        
                        if beltTotals.isEmpty {
                            Text("No live rounds in this range.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ForEach(beltTotals, id: \.belt) { item in
                                MetricRow(
                                    title: item.belt.rawValue,
                                    value: "\(item.count)"
                                )
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Live Minutes by Partner Belt")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        let beltMinutes = liveMinutesByPartnerBelt()
                        
                        if beltMinutes.isEmpty {
                            Text("No live minutes in this range.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ForEach(beltMinutes, id: \.belt) { item in
                                MetricRow(
                                    title: item.belt.rawValue,
                                    value: "\(item.minutes) min"
                                )
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Submissions Finished")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        let finishedTotals = submissionTotalsFinished()
                        
                        if finishedTotals.isEmpty {
                            Text("No submissions finished in this range.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ForEach(finishedTotals, id: \.submission) { item in
                                MetricRow(
                                    title: item.submission.rawValue,
                                    value: "\(item.count)"
                                )
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Submitted By")
                            .font(.headline)
                            .foregroundColor(.appTextSecondary)
                        
                        let receivedTotals = submissionTotalsReceived()
                        
                        if receivedTotals.isEmpty {
                            Text("No submissions received in this range.")
                                .foregroundColor(.appTextSecondary)
                        } else {
                            ForEach(receivedTotals, id: \.submission) { item in
                                MetricRow(
                                    title: item.submission.rawValue,
                                    value: "\(item.count)"
                                )
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Button {
                            withAnimation {
                                showRecentSessions.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Recent Sessions")
                                    .font(.headline)
                                    .foregroundColor(.appTextSecondary)
                                
                                Spacer()
                                
                                Image(systemName: showRecentSessions ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        if filteredSessions.isEmpty {
                            Text("No BJJ sessions logged yet.")
                                .foregroundColor(.appTextSecondary)
                        } else if showRecentSessions {
                            ForEach(filteredSessions) { session in
                                NavigationLink {
                                    BJJSessionDetailView(
                                        appStore: appStore,
                                        session: session
                                    )
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(session.sessionType.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.appTextPrimary)
                                        
                                        Text(formattedDateTime(session.date))
                                            .font(.caption)
                                            .foregroundColor(.appTextSecondary)
                                        
                                        Text("\(session.totalRounds) rounds • \(session.totalLiveMinutes) live min")
                                            .foregroundColor(.appTextSecondary)
                                        
                                        Text("Session RPE: \(session.sessionRPE)/10")
                                            .foregroundColor(.appTextSecondary)
                                        
                                        Text("Readiness: \(session.readinessAverage, specifier: "%.1f")/5")
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appCardSecondary)
                                    .cornerRadius(14)
                                }
                                .buttonStyle(.plain)
                            }
                            .onDelete { offsets in
                                for offset in offsets {
                                    let session = filteredSessions[offset]
                                    appStore.deleteBJJSession(id: session.id)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appCard)
                    .cornerRadius(18)
                }
                .listRowBackground(Color.appBackground)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $activeBJJSheet) { sheet in
                switch sheet {
                case .beltRank:
                    BeltRankChangeView(appStore: appStore)
                case .logSession:
                    LogBJJSessionView(appStore: appStore)
                }
            }
        }
    }
}
struct BeltRankChangeView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBelt: BeltLevel = .blue
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Belt Rank") {
                    Picker("Rank", selection: $selectedBelt) {
                        ForEach(BeltLevel.allCases, id: \.self) { belt in
                            Text(belt.rawValue)
                        }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Update Belt Rank")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.addBeltRankChange(
                            beltLevel: selectedBelt,
                            date: selectedDate
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
struct LogBJJSessionView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 1

    @State private var sleep = 5
    @State private var stress = 5
    @State private var recovery = 5
    @State private var motivation = 5
    @State private var energy = 5
    @State private var mood = 5

    @State private var sessionType: BJJSessionType = .gi
    @State private var totalDurationMinutes = 60
    @State private var sessionRPE = 6
    @State private var notes = ""
    @State private var didLiveRounds = true

    @State private var rounds: [BJJRounds] = []

    @State private var partnerBelt: BeltLevel = .blue
    @State private var roundDurationMinutes = 5
    @State private var roundRPE = 7
    @State private var roundNotes = ""

    @State private var submissionsFinished: [SubmissionType: Int] = [:]
    @State private var submissionsReceived: [SubmissionType: Int] = [:]
    @State private var didFinishSubmissions = false
    @State private var didGetSubmitted = false

    var stepTitle: String {
        switch currentStep {
        case 1:
            return "Readiness"
        case 2:
            return "Session Details"
        case 3:
            return "Live Rolls"
        case 4:
            return "Submissions"
        default:
            return "Log BJJ Session"
        }
    }
    func roundEffortLabel(_ rpe: Int) -> String {
        switch rpe {
        case 5:
            return "Flow Roll"
        case 6:
            return "Technical Roll"
        case 7:
            return "Typical Roll"
        case 8:
            return "Hard Roll"
        case 9:
            return "Competition Style"
        case 10:
            return "Max Effort"
        default:
            return "Roll"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                
                Section {
                    ProgressView(value: Double(currentStep), total: 4)
                        .tint(.appPrimary)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 38, bottom: 8, trailing: 38))

                if currentStep == 1 {
                    Section {
                        RatingChipSelector(title: "Sleep", value: $sleep)
                        RatingChipSelector(title: "Stress", value: $stress)
                        RatingChipSelector(title: "Recovery", value: $recovery)
                        RatingChipSelector(title: "Motivation", value: $motivation)
                        RatingChipSelector(title: "Energy", value: $energy)
                        RatingChipSelector(title: "Mood", value: $mood)
                    } header: {
                        Text("Pre-Session Readiness")
                            .font(.headline)
                            .foregroundColor(.appTextPrimary)
                    }
                    .listRowBackground(Color.appCard)
                }

                if currentStep == 2 {
                    Section {
                        
                        SessionTypeChipSelector(selectedType: $sessionType)
                        DurationChipSelector(duration: $totalDurationMinutes)
                        
                        LabeledChipSelector(
                            title: "Session Effort",
                            value: $sessionRPE,
                            options: [
                                ("LIGHT DRILLING", 1),
                                ("MODERATE", 2),
                                ("HARD", 3),
                                ("VERY HARD", 4),
                                ("COMPETITION STYLE", 5)
                            ]
                        )
                        YesNoChipSelector(
                            title: "Live Rounds",
                            value: $didLiveRounds
                        )
                        
                        TextField(
                            "",
                            text: $notes,
                            prompt: Text("Session Notes")
                                .foregroundColor(.white.opacity(0.6))
                        )
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(3...8)
                    }
                    .listRowBackground(Color.appCard)
                }

                if currentStep == 3 {

                    Section {

                        BeltChipSelector(
                            title: "Opponent Belt",
                            selectedBelt: $partnerBelt
                        )

                        DurationStepperControl(
                            title: "Round Duration",
                            value: $roundDurationMinutes,
                            range: 1...30
                        )

                        LabeledChipSelector(
                            title: "Round Effort",
                            value: $roundRPE,
                            options: [
                                ("VERY EASY", 5),
                                ("EASY", 6),
                                ("MEDIUM", 7),
                                ("HARD", 8),
                                ("VERY HARD", 9),
                                ("MAX EFFORT", 10)
                            ]
                        )

                        TextField(
                            "",
                            text: $roundNotes,
                            prompt: Text("Round Notes")
                                .foregroundColor(.white.opacity(0.6)),
                            axis: .vertical
                        )
                        .foregroundColor(.appTextPrimary)
                        .lineLimit(1...2)

                        Button {
                            let round = BJJRounds(
                                id: UUID(),
                                beltLevel: partnerBelt,
                                durationMinutes: roundDurationMinutes,
                                roundRPE: roundRPE,
                                notes: roundNotes
                            )

                            rounds.append(round)
                            roundNotes = ""
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")

                                Text("Add Roll")
                                    .fontWeight(.semibold)

                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowBackground(Color.appCard)
                    .tint(.appPrimary)

                    if !rounds.isEmpty {
                        Section {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Logged Rolls (\(rounds.count))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appTextPrimary)

                                ForEach(Array(rounds.reversed())) { round in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("\(round.beltLevel.rawValue) Belt")
                                                .font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(round.beltLevel.displayColor)

                                            Spacer()

                                            Text("\(round.durationMinutes) min")
                                                .font(.subheadline)
                                                .foregroundColor(.appTextSecondary)
                                        }

                                        Text(roundEffortLabel(round.roundRPE))
                                            .font(.subheadline)
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    .padding()
                                    .background(Color.appCardSecondary)
                                    .cornerRadius(14)
                                }
                            }
                        }
                        .listRowBackground(Color.appCard)
                    }
                }

                if currentStep == 4 {

                    Section {
                        YesNoChipSelector(
                            title: "Finished Submissions?",
                            value: $didFinishSubmissions
                        )

                        if didFinishSubmissions {
                            SubmissionSelectionSection(
                                title: "Submissions Finished",
                                submissionCounts: $submissionsFinished
                            )
                        }

                        YesNoChipSelector(
                            title: "Got Submitted?",
                            value: $didGetSubmitted
                        )

                        if didGetSubmitted {
                            SubmissionSelectionSection(
                                title: "Submitted By",
                                submissionCounts: $submissionsReceived
                            )
                        }
                    }
                    .listRowBackground(Color.appCard)
                }
            }
            .listRowBackground(Color.appCard)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .confirmationAction) {
                    Button(currentStep == 4 ? "Save" : "Next") {

                        if currentStep == 2 && !didLiveRounds {
                            appStore.addBJJSession(
                                sessionType: sessionType,
                                totalDurationMinutes: totalDurationMinutes,
                                sleep: sleep,
                                stress: stress,
                                recovery: recovery,
                                motivation: motivation,
                                energy: energy,
                                mood: mood,
                                sessionRPE: sessionRPE,
                                notes: notes,
                                rounds: [],
                                submissionsFinished: [],
                                submissionsReceived: []
                            )

                            dismiss()

                        } else if currentStep < 4 {
                            currentStep += 1

                        } else {
                            appStore.addBJJSession(
                                sessionType: sessionType,
                                totalDurationMinutes: totalDurationMinutes,
                                sleep: sleep,
                                stress: stress,
                                recovery: recovery,
                                motivation: motivation,
                                energy: energy,
                                mood: mood,
                                sessionRPE: sessionRPE,
                                notes: notes,
                                rounds: rounds,
                                submissionsFinished: submissionsFinished.map {
                                    SubmissionCount(
                                        id: UUID(),
                                        submission: $0.key,
                                        count: $0.value
                                    )
                                },
                                submissionsReceived: submissionsReceived.map {
                                    SubmissionCount(
                                        id: UUID(),
                                        submission: $0.key,
                                        count: $0.value
                                    )
                                }
                            )

                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    if currentStep > 1 {
                        Button("Back") {
                            currentStep -= 1
                        }
                        .foregroundColor(.appPrimary)
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.appPrimary)
                    }
                }
            }
        }
    }
}
extension BeltLevel {
    var displayColor: Color {
        switch self {
        case .white:
            return .white

        case .blue:
            return .blue

        case .purple:
            return .purple

        case .brown:
            return .brown

        case .black:
            return .red

        case .unknown:
            return .appTextSecondary
        }
    }
}
struct RatingChipSelector: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...5

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible()),
                    count: 5
                ),
                spacing: 8
            ) {
                ForEach(Array(range), id: \.self) { number in
                    Button {
                        value = number
                    } label: {
                        Text("\(number)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                value == number
                                ? .white
                                : .appTextSecondary
                            )
                            .frame(height: 38)
                            .frame(maxWidth: .infinity)
                            .background(
                                value == number
                                ? Color.appPrimary
                                : Color.appCardSecondary
                            )
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
struct LabeledChipSelector: View {
    let title: String
    @Binding var value: Int
    let options: [(label: String, value: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            VStack(spacing: 4) {
                ForEach(options, id: \.value) { option in
                    Button {
                        value = option.value
                    } label: {
                        Text(option.label)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(value == option.value ? .white : .appTextSecondary)
                            .frame(height: 38)
                            .frame(maxWidth: .infinity)
                            .background(value == option.value ? Color.appPrimary : Color.appCardSecondary)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
struct YesNoChipSelector: View {
    let title: String
    @Binding var value: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            HStack(spacing: 8) {
                Button {
                    value = true
                } label: {
                    Text("Yes")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(value ? .white : .appTextSecondary)
                        .frame(height: 42)
                        .frame(maxWidth: .infinity)
                        .background(value ? Color.appPrimary : Color.appCardSecondary)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Button {
                    value = false
                } label: {
                    Text("No")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(!value ? .white : .appTextSecondary)
                        .frame(height: 42)
                        .frame(maxWidth: .infinity)
                        .background(!value ? Color.appPrimary : Color.appCardSecondary)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
struct SessionTypeChipSelector: View {
    @Binding var selectedType: BJJSessionType

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Training Type")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            HStack(spacing: 8) {
                ForEach(BJJSessionType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                    } label: {
                        Text(type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                selectedType == type ? .white : .appTextSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(
                                selectedType == type
                                ? Color.appPrimary
                                : Color.appCardSecondary
                            )
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
struct DurationChipSelector: View {
    @Binding var duration: Int

    let options = [60, 75, 90, 120]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Duration")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        duration = option
                    } label: {
                        Text("\(option)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(duration == option ? .white : .appTextSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(duration == option ? Color.appPrimary : Color.appCardSecondary)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
struct BeltChipSelector: View {
    let title: String
    @Binding var selectedBelt: BeltLevel

    let belts: [BeltLevel] = [.white, .blue, .purple, .brown, .black]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            HStack(spacing: 8) {
                ForEach(belts, id: \.self) { belt in
                    Button {
                        selectedBelt = belt
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(belt.displayColor)
                            .frame(height: 42)
                            .overlay {
                                if selectedBelt == belt {
                                    Image(systemName: "checkmark")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.clear, lineWidth: 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
struct DurationStepperControl: View {
    let title: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...30

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            HStack {
                Button {
                    if value > range.lowerBound {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                        .frame(width: 44, height: 42)
                        .background(Color.appCardSecondary)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(value) min")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.appTextPrimary)

                Spacer()

                Button {
                    if value < range.upperBound {
                        value += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundColor(.appTextPrimary)
                        .frame(width: 44, height: 42)
                        .background(Color.appCardSecondary)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
struct SubmissionSelectionSection: View {
    let title: String
    @Binding var submissionCounts: [SubmissionType: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.appTextPrimary)

            ForEach(SubmissionType.allCases, id: \.self) { submission in
                HStack {
                    Text(submission.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.appTextPrimary)

                    Spacer()

                    Button {
                        let current = submissionCounts[submission] ?? 0
                        if current > 0 {
                            submissionCounts[submission] = current - 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundColor(
                                (submissionCounts[submission] ?? 0) == 0
                                ? .appTextSecondary.opacity(0.35)
                                : .appTextSecondary
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled((submissionCounts[submission] ?? 0) == 0)

                    Text("\(submissionCounts[submission] ?? 0)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.appTextPrimary)
                        .frame(width: 32)
                        .monospacedDigit()

                    Button {
                        let current = submissionCounts[submission] ?? 0
                        submissionCounts[submission] = current + 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(.appPrimary)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(Color.appCardSecondary)
                .cornerRadius(12)
            }
        }
        .padding(.vertical, 2)
    }
}
struct BJJSessionDetailView: View {
    @Bindable var appStore: AppStore
    var session: BJJSession
    
    @State private var showEditSheet = false
    @State private var showEditRoundsSheet = false
    @State private var showEditSubmissionsSheet = false
    
    func submissionSummary(_ submissions: [SubmissionCount]) -> String {
        submissions
            .filter { $0.count > 0 }
            .sorted { $0.submission.rawValue < $1.submission.rawValue }
            .map { "\($0.submission.rawValue) x\($0.count)" }
            .joined(separator: ", ")
    }
    
    var body: some View {
        List {
            Section("Session") {
                HStack {
                    Text("Type")
                    Spacer()
                    Text(session.sessionType.rawValue)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Date")
                    Spacer()
                    Text(formattedDateTime(session.date))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Duration")
                    Spacer()
                    Text("\(session.totalDurationMinutes) min")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Session RPE")
                    Spacer()
                    Text("\(session.sessionRPE)/10")
                        .foregroundColor(.secondary)
                }
                
                if !session.notes.isEmpty {
                    Text(session.notes)
                        .foregroundColor(.secondary)
                }
            }
            Section("Pre-Session Readiness") {
                HStack {
                    Text("Sleep")
                    Spacer()
                    Text("\(session.sleep)/10")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Stress")
                    Spacer()
                    Text("\(session.stress)/10")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Recovery")
                    Spacer()
                    Text("\(session.recovery)/10")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Motivation")
                    Spacer()
                    Text("\(session.motivation)/10")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Energy")
                    Spacer()
                    Text("\(session.energy)/10")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Mood")
                    Spacer()
                    Text("\(session.mood)/10")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Average")
                    Spacer()
                    Text("\(session.readinessAverage, specifier: "%.1f")/5")
                        .font(.headline)
                }
            }
            Section("Live Rolls") {
                if session.rounds.isEmpty {
                    Text("No live rolls logged.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(session.rounds) { round in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(round.durationMinutes) min vs \(round.beltLevel.rawValue)")
                                .font(.headline)
                            
                            Text("Round RPE: \(round.roundRPE)/10")
                                .foregroundColor(.secondary)
                            
                            if !round.notes.isEmpty {
                                Text(round.notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Section("Submissions Finished") {
                if session.submissionsFinished.filter({ $0.count > 0 }).isEmpty {
                    Text("None logged.")
                        .foregroundColor(.secondary)
                } else {
                    Text(submissionSummary(session.submissionsFinished))
                }
            }
            
            Section("Submitted By") {
                if session.submissionsReceived.filter({ $0.count > 0 }).isEmpty {
                    Text("None logged.")
                        .foregroundColor(.secondary)
                } else {
                    Text(submissionSummary(session.submissionsReceived))
                }
            }
        }
        .navigationTitle("BJJ Session")
        
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Edit Rolls") {
                    showEditRoundsSheet = true
                }
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit Subs") {
                    showEditSubmissionsSheet = true
                }
                
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        
        .sheet(isPresented: $showEditSheet) {
            EditBJJSessionView(
                appStore: appStore,
                session: session
            )
        }
        
        .sheet(isPresented: $showEditRoundsSheet) {
            EditBJJRoundsView(
                appStore: appStore,
                session: session
            )
        }
        .sheet(isPresented: $showEditSubmissionsSheet) {
            EditBJJSubmissionsView(
                appStore: appStore,
                session: session
            )
        }
    }
}
struct EditBJJSessionView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    let originalSession: BJJSession
    
    @State private var sessionType: BJJSessionType
    @State private var totalDurationMinutes: Int
    @State private var sessionRPE: Int
    @State private var notes: String
    
    init(appStore: AppStore, session: BJJSession) {
        self.appStore = appStore
        self.originalSession = session
        
        _sessionType = State(initialValue: session.sessionType)
        _totalDurationMinutes = State(initialValue: session.totalDurationMinutes)
        _sessionRPE = State(initialValue: session.sessionRPE)
        _notes = State(initialValue: session.notes)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Session Details") {
                    SessionTypeChipSelector(selectedType: $sessionType)
                    DurationChipSelector(duration: $totalDurationMinutes)
                    
                    RatingChipSelector(
                        title: "Session RPE",
                        value: $sessionRPE,
                        range: 1...10
                    )
                    
                    TextField(
                        "Session Notes",
                        text: $notes,
                        axis: .vertical
                    )
                }
            }
            .navigationTitle("Edit Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedSession = BJJSession(
                            id: originalSession.id,
                            date: originalSession.date,
                            sessionType: sessionType,
                            totalDurationMinutes: totalDurationMinutes,
                            sleep: originalSession.sleep,
                            stress: originalSession.stress,
                            recovery: originalSession.recovery,
                            motivation: originalSession.motivation,
                            energy: originalSession.energy,
                            mood: originalSession.mood,
                            sessionRPE: sessionRPE,
                            notes: notes,
                            rounds: originalSession.rounds,
                            submissionsFinished: originalSession.submissionsFinished,
                            submissionsReceived: originalSession.submissionsReceived
                        )
                        
                        appStore.updateBJJSession(updatedSession)
                        dismiss()
                    }
                }
            }
        }
    }
}
struct EditBJJRoundsView: View {
    @Bindable var appStore: AppStore
    let session: BJJSession
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var editableRounds: [BJJRounds]
    
    init(appStore: AppStore, session: BJJSession) {
        self.appStore = appStore
        self.session = session
        _editableRounds = State(initialValue: session.rounds)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if editableRounds.isEmpty {
                    Text("No live rolls logged.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach($editableRounds) { $round in
                        Section("Roll") {
                            Picker("Partner Belt", selection: $round.beltLevel) {
                                ForEach(BeltLevel.allCases, id: \.self) { belt in
                                    Text(belt.rawValue)
                                }
                            }
                            
                            Stepper(
                                "Duration: \(round.durationMinutes) min",
                                value: $round.durationMinutes,
                                in: 1...30
                            )
                            
                            ReadinessSlider(
                                title: "Round RPE",
                                value: $round.roundRPE
                            )
                            
                            TextField(
                                "Notes",
                                text: $round.notes,
                                axis: .vertical
                            )
                        }
                    }
                    .onDelete { offsets in
                        editableRounds.remove(atOffsets: offsets)
                    }
                }
            }
            .navigationTitle("Edit Rolls")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.updateBJJSessionRounds(
                            sessionID: session.id,
                            rounds: editableRounds
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}
struct EditBJJSubmissionsView: View {
    @Bindable var appStore: AppStore
    let session: BJJSession
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var finishedCounts: [SubmissionType: Int]
    @State private var receivedCounts: [SubmissionType: Int]
    
    init(appStore: AppStore, session: BJJSession) {
        self.appStore = appStore
        self.session = session
        
        var finished: [SubmissionType: Int] = [:]
        for item in session.submissionsFinished {
            finished[item.submission] = item.count
        }
        
        var received: [SubmissionType: Int] = [:]
        for item in session.submissionsReceived {
            received[item.submission] = item.count
        }
        
        _finishedCounts = State(initialValue: finished)
        _receivedCounts = State(initialValue: received)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                SubmissionSelectionSection(
                    title: "Submissions Finished",
                    submissionCounts: $finishedCounts
                )
                
                SubmissionSelectionSection(
                    title: "Submitted By",
                    submissionCounts: $receivedCounts
                )
            }
            .navigationTitle("Edit Submissions")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finished = finishedCounts.map {
                            SubmissionCount(
                                id: UUID(),
                                submission: $0.key,
                                count: $0.value
                            )
                        }
                        
                        let received = receivedCounts.map {
                            SubmissionCount(
                                id: UUID(),
                                submission: $0.key,
                                count: $0.value
                            )
                        }
                        
                        appStore.updateBJJSessionSubmissions(
                            sessionID: session.id,
                            submissionsFinished: finished,
                            submissionsReceived: received
                        )
                        
                        dismiss()
                    }
                }
            }
        }
    }
}
struct SaveTemplateView: View {
    @Bindable var appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateName = ""
    @State private var category: WorkoutTemplateCategory = .strength
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Template Name") {
                    TextField("Example: Lower Strength", text: $templateName)
                }
            }
            Picker("Category", selection: $category) {
                ForEach(WorkoutTemplateCategory.allCases, id: \.self) { category in
                    Text(category.rawValue)
                }
            }
            .navigationTitle("Save Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.saveWorkoutTemplate(
                            name: templateName,
                            category: category,
                            exercises: appStore.todaysExercises
                        )
                        dismiss()
                    }
                    .disabled(templateName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
struct TemplatesView: View {
    @Bindable var appStore: AppStore
    
    var body: some View {
        NavigationStack {
            List {
                if appStore.workoutTemplates.isEmpty {
                    Text("No saved templates yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(appStore.workoutTemplates) { template in
                        Section(template.category.rawValue) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(template.name)
                                    .font(.headline)
                                
                                Text("\(template.exercises.count) exercises")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Button("Load to Today") {
                                    appStore.loadWorkoutTemplate(template)
                                }
                                
                                NavigationLink {
                                    EditWorkoutTemplateView(
                                        appStore: appStore,
                                        template: template
                                    )
                                } label: {
                                    Text("Edit Template")
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing) {
                                
                                Button("Duplicate") {
                                    appStore.duplicateWorkoutTemplate(
                                        id: template.id
                                    )
                                }
                                
                                Button(role: .destructive) {
                                    if let index = appStore.workoutTemplates.firstIndex(
                                        where: { $0.id == template.id }
                                    ) {
                                        appStore.deleteWorkoutTemplate(
                                            id: appStore.workoutTemplates[index].id
                                        )
                                    }
                                } label: {
                                    Text("Delete")
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        for offset in offsets {
                            let template = appStore.workoutTemplates[offset]
                            appStore.deleteWorkoutTemplate(id: template.id)
                        }
                    }
                }
            }
            .navigationTitle("Templates")
        }
    }
}
struct EditWorkoutTemplateView: View {
    @Bindable var appStore: AppStore
    let template: WorkoutTemplate
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var templateName: String
    @State private var category: WorkoutTemplateCategory
    @State private var showAddTemplateExerciseSheet = false
    
    
    init(appStore: AppStore, template: WorkoutTemplate) {
        self.appStore = appStore
        self.template = template
        _templateName = State(initialValue: template.name)
        _category = State(initialValue: template.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Template Info") {
                    TextField("Template Name", text: $templateName)
                    
                    Picker("Category", selection: $category) {
                        ForEach(WorkoutTemplateCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                    Button("Reset Rep Ranges") {
                        appStore.resetTemplateRepRanges(
                            templateID: template.id
                        )
                    }
                    .foregroundColor(.orange)
                }
                Section("Exercises") {
                    if template.exercises.isEmpty {
                        Text("No exercises in template.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(template.exercises) { exercise in
                            NavigationLink {
                                EditTemplateExerciseView(
                                    appStore: appStore,
                                    templateID: template.id,
                                    exercise: exercise
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.headline)
                                    
                                    Text(exercise.details)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Target: \(exercise.targetRepRange) reps")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Rest: \(exercise.restSeconds) sec")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete { offsets in
                            appStore.deleteExerciseFromTemplate(
                                templateID: template.id,
                                offsets: offsets
                            )
                        }
                        .onMove { source, destination in
                            appStore.moveExerciseInTemplate(
                                templateID: template.id,
                                from: source,
                                to: destination
                            )
                        }
                    }
                }
            }
            .navigationTitle("Edit Template")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.updateWorkoutTemplate(
                            id: template.id,
                            name: templateName,
                            category: category
                        )
                        
                        dismiss()
                    }
                    .disabled(templateName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddTemplateExerciseSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTemplateExerciseSheet) {
                AddTemplateExerciseView(
                    appStore: appStore,
                    templateID: template.id
                )
            }
        }
    }
}
struct AddTemplateExerciseView: View {
    @Bindable var appStore: AppStore
    let templateID: UUID
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName = ""
    @State private var exerciseDetails = ""
    @State private var exerciseNotes = ""
    @State private var setCount = 3
    @State private var groupLabel = ""
    @State private var category: ExerciseCategory = .accessory
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Info") {
                    TextField("Exercise Name", text: $exerciseName)
                    TextField("Details", text: $exerciseDetails)
                    TextField("Notes", text: $exerciseNotes, axis: .vertical)
                    Stepper("Sets: \(setCount)", value: $setCount, in: 1...10)
                    TextField("Group Label", text: $groupLabel)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.addExerciseToTemplate(
                            templateID: templateID,
                            name: exerciseName,
                            details: exerciseDetails,
                            notes: exerciseNotes,
                            setCount: setCount,
                            groupLabel: groupLabel.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                            category: category
                        )
                        dismiss()
                    }
                    .disabled(exerciseName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
struct EditTemplateExerciseView: View {
    @Bindable var appStore: AppStore
    
    let templateID: UUID
    let exercise: ExerciseItem
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName: String
    @State private var exerciseDetails: String
    @State private var exerciseNotes: String
    @State private var setCount: Int
    @State private var groupLabel: String
    @State private var category: ExerciseCategory
    @State private var targetRepRange: String
    @State private var restSeconds: Int
    
    init(
        appStore: AppStore,
        templateID: UUID,
        exercise: ExerciseItem
    ) {
        self.appStore = appStore
        self.templateID = templateID
        self.exercise = exercise
        
        _exerciseName = State(initialValue: exercise.name)
        _exerciseDetails = State(initialValue: exercise.details)
        _exerciseNotes = State(initialValue: exercise.notes)
        _setCount = State(initialValue: exercise.setCount)
        _groupLabel = State(initialValue: exercise.groupLabel)
        _category = State(initialValue: exercise.category)
        _targetRepRange = State(initialValue: exercise.targetRepRange)
        _restSeconds = State(initialValue: exercise.restSeconds)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Info") {
                    TextField("Exercise Name", text: $exerciseName)
                    
                    TextField("Details", text: $exerciseDetails)
                    
                    TextField("Target Rep Range", text: $targetRepRange)
                    
                    Stepper(
                        "Rest: \(restSeconds) sec",
                        value: $restSeconds,
                        in: 30...300,
                        step: 15
                    )
                    
                    TextField(
                        "Notes",
                        text: $exerciseNotes,
                        axis: .vertical
                    )
                    
                    Stepper(
                        "Sets: \(setCount)",
                        value: $setCount,
                        in: 1...10
                    )
                    
                    TextField(
                        "Group Label",
                        text: $groupLabel
                    )
                    
                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Edit Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appStore.updateExerciseInTemplate(
                            templateID: templateID,
                            exerciseID: exercise.id,
                            name: exerciseName,
                            details: exerciseDetails,
                            notes: exerciseNotes,
                            setCount: setCount,
                            groupLabel: groupLabel.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                            category: category,
                            targetRepRange: targetRepRange,
                            restSeconds: restSeconds
                        )
                        
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview {
    ContentView()
    
}
extension Array where Element: Hashable {
func removingDuplicates() -> [Element] {
var seen = Set<Element>()
return filter { seen.insert($0).inserted }
}
}

