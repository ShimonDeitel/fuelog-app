import Foundation

struct FuelogEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var vehicleName: String
    var amount: Double
    var note: String
    var date: Date
    var status: EntryStatus = .open

    enum EntryStatus: String, Codable, CaseIterable {
        case open
        case closed
    }
}
