import SwiftUI

struct AdminView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        NavigationStack {
            List {
                Section("Пользователи · \(store.users.count)") {
                    ForEach(store.users) { user in
                        NavigationLink { UserManagementView(phone: user.phone) } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.phone).fontWeight(.semibold)
                                    Text("⭐️ \(user.stars)  ·  ◈ \(user.gram) GRAM").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if user.isAdmin { Text("ADMIN").font(.caption2.bold()).foregroundStyle(.purple) }
                                else if user.isBlocked { Text("ЗАБЛОКИРОВАН").font(.caption2.bold()).foregroundStyle(.red) }
                            }
                        }
                    }
                }
                Section {
                    Text("Все балансы и подарки здесь демонстрационные и хранятся локально на этом устройстве.").font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Админ-панель")
        }
    }
}

struct UserManagementView: View {
    @EnvironmentObject private var store: AppStore
    let phone: String
    @State private var amount = "100"
    @State private var currency = "Stars"
    @State private var giftName = ""
    private var user: AntagramUser? { store.users.first { $0.phone == phone } }

    var body: some View {
        Form {
            if let user {
                Section("Аккаунт") {
                    LabeledContent("Номер", value: user.phone)
                    LabeledContent("Stars", value: user.stars.formatted())
                    LabeledContent("GRAM", value: user.gram.formatted())
                    if !user.isAdmin {
                        Button(user.isBlocked ? "Разблокировать" : "Заблокировать", role: user.isBlocked ? nil : .destructive) { store.toggleBlocked(phone: phone) }
                    }
                }
                Section("Изменить баланс") {
                    Picker("Валюта", selection: $currency) {
                        Text("Stars").tag("Stars")
                        Text("GRAM").tag("GRAM")
                    }
                    TextField("Количество (минус для списания)", text: $amount).keyboardType(.numbersAndPunctuation)
                    Button("Применить") {
                        if let value = Int(amount) { store.adjust(phone: phone, currency: currency, amount: value) }
                    }
                }
                Section("Подарки") {
                    HStack {
                        TextField("Название подарка", text: $giftName)
                        Button("Добавить") { store.addGift(phone: phone, name: giftName); giftName = "" }.disabled(giftName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    if user.gifts.isEmpty { Text("Подарков нет").foregroundStyle(.secondary) }
                    ForEach(user.gifts.indices, id: \.self) { index in
                        HStack {
                            Label(user.gifts[index], systemImage: "gift.fill")
                            Spacer()
                            Button(role: .destructive) { store.removeGift(phone: phone, at: index) } label: { Image(systemName: "trash") }
                        }
                    }
                }
            }
        }
        .navigationTitle("Управление")
    }
}

struct LedgerView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        NavigationStack {
            List {
                if store.ledger.isEmpty { Text("Операций пока нет").foregroundStyle(.secondary) }
                ForEach(store.ledger) { item in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.action).fontWeight(.medium)
                        Text("\(item.phone) · \(item.currency) · \(item.amount)").font(.caption).foregroundStyle(.secondary)
                        Text(item.date.formatted(date: .numeric, time: .shortened)).font(.caption2).foregroundStyle(.tertiary)
                    }.padding(.vertical, 3)
                }
            }.navigationTitle("История операций")
        }
    }
}
