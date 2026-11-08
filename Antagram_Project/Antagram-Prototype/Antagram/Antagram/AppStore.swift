import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var users: [AntagramUser] = []
    @Published private(set) var ledger: [LedgerEntry] = []
    @Published var currentPhone: String?
    @Published var loginError: String?

    private let usersKey = "antagram.users.v1"
    private let ledgerKey = "antagram.ledger.v1"

    init() { load() }

    var currentUser: AntagramUser? { users.first { $0.phone == currentPhone } }
    var isAdmin: Bool { currentUser?.isAdmin == true }

    func login(phone: String, code: String) {
        loginError = nil
        guard let user = users.first(where: { $0.phone == phone && $0.code == code }) else {
            loginError = "Неверный номер или тестовый код."
            return
        }
        guard !user.isBlocked else {
            loginError = "Этот аккаунт заблокирован администратором."
            return
        }
        currentPhone = phone
    }

    func logout() { currentPhone = nil }

    func adjust(phone: String, currency: String, amount: Int) {
        guard isAdmin, let index = users.firstIndex(where: { $0.phone == phone }), amount != 0 else { return }
        if currency == "Stars" {
            users[index].stars = max(0, users[index].stars + amount)
        } else {
            users[index].gram = max(0, users[index].gram + amount)
        }
        ledger.insert(LedgerEntry(phone: phone, action: amount > 0 ? "Начисление" : "Списание", amount: amount, currency: currency), at: 0)
        save()
    }

    func addGift(phone: String, name: String) {
        guard isAdmin, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let index = users.firstIndex(where: { $0.phone == phone }) else { return }
        users[index].gifts.append(name)
        ledger.insert(LedgerEntry(phone: phone, action: "Добавлен подарок: \\(name)", amount: 1, currency: "Gift"), at: 0)
        save()
    }

    func removeGift(phone: String, at giftIndex: Int) {
        guard isAdmin, let index = users.firstIndex(where: { $0.phone == phone }), users[index].gifts.indices.contains(giftIndex) else { return }
        let name = users[index].gifts.remove(at: giftIndex)
        ledger.insert(LedgerEntry(phone: phone, action: "Удалён подарок: \\(name)", amount: 1, currency: "Gift"), at: 0)
        save()
    }

    func toggleBlocked(phone: String) {
        guard isAdmin, let index = users.firstIndex(where: { $0.phone == phone }), !users[index].isAdmin else { return }
        users[index].isBlocked.toggle()
        ledger.insert(LedgerEntry(phone: phone, action: users[index].isBlocked ? "Блокировка" : "Разблокировка", amount: 0, currency: "Account"), at: 0)
        save()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decoded = try? JSONDecoder().decode([AntagramUser].self, from: data) {
            users = decoded
        } else {
            users = [
                AntagramUser(phone: "+12281488", code: "1488", stars: 1000, gram: 10, gifts: [], isBlocked: false, isAdmin: true),
                AntagramUser(phone: "+12281489", code: "1489", stars: 1000, gram: 10, gifts: [], isBlocked: false, isAdmin: false),
                AntagramUser(phone: "+12281490", code: "1490", stars: 1000, gram: 10, gifts: [], isBlocked: false, isAdmin: false),
                AntagramUser(phone: "+12281491", code: "1491", stars: 1000, gram: 10, gifts: [], isBlocked: false, isAdmin: false),
                AntagramUser(phone: "+12281492", code: "1492", stars: 1000, gram: 10, gifts: [], isBlocked: false, isAdmin: false)
            ]
            save()
        }
        if let data = UserDefaults.standard.data(forKey: ledgerKey),
           let decoded = try? JSONDecoder().decode([LedgerEntry].self, from: data) { ledger = decoded }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(users) { UserDefaults.standard.set(data, forKey: usersKey) }
        if let data = try? JSONEncoder().encode(ledger) { UserDefaults.standard.set(data, forKey: ledgerKey) }
    }
}
