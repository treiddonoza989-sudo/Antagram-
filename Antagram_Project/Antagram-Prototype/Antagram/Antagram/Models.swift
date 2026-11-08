import Foundation

struct AntagramUser: Identifiable, Codable, Equatable {
    var id: String { phone }
    let phone: String
    let code: String
    var stars: Int
    var gram: Int
    var gifts: [String]
    var isBlocked: Bool
    var isAdmin: Bool
}

struct LedgerEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let phone: String
    let action: String
    let amount: Int
    let currency: String

    init(phone: String, action: String, amount: Int, currency: String) {
        self.id = UUID()
        self.date = Date()
        self.phone = phone
        self.action = action
        self.amount = amount
        self.currency = currency
    }
}
