import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        Group {
            if store.currentUser != nil { MainView() } else { LoginView() }
        }
        .tint(Color(red: 0.67, green: 0.48, blue: 1.0))
    }
}

struct LoginView: View {
    @EnvironmentObject private var store: AppStore
    @State private var phone = "+12281488"
    @State private var code = "1488"

    var body: some View {
        ZStack {
            Color(red: 0.055, green: 0.06, blue: 0.09).ignoresSafeArea()
            VStack(spacing: 22) {
                Spacer()
                Image(systemName: "gift.fill").font(.system(size: 48)).foregroundStyle(.purple)
                Text("ANTAGRAM").font(.system(size: 32, weight: .black, design: .rounded)).tracking(3)
                Text("Тестовая платформа подарков").foregroundStyle(.secondary)
                VStack(spacing: 12) {
                    TextField("Номер", text: $phone).keyboardType(.phonePad).textContentType(.telephoneNumber).padding().background(.white.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 14))
                    SecureField("Тестовый код", text: $code).keyboardType(.numberPad).padding().background(.white.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 14))
                    if let error = store.loginError { Text(error).font(.footnote).foregroundStyle(.red).frame(maxWidth: .infinity, alignment: .leading) }
                    Button { store.login(phone: phone, code: code) } label: {
                        Text("Войти").fontWeight(.semibold).frame(maxWidth: .infinity).padding().background(.purple).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20)
                .background(.white.opacity(0.045))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                Text("Демо-доступ: +12281488 / 1488").font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("Только тестовые балансы и подарки — не активы Telegram.").font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        TabView {
            ProfileView().tabItem { Label("Профиль", systemImage: "person.crop.circle") }
            if store.isAdmin {
                AdminView().tabItem { Label("Админ", systemImage: "slider.horizontal.3") }
                LedgerView().tabItem { Label("Операции", systemImage: "list.bullet.rectangle") }
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    private var user: AntagramUser { store.currentUser! }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ТВОЙ ПРОФИЛЬ").font(.caption).tracking(2).foregroundStyle(.secondary)
                        Text(user.phone).font(.title2.bold())
                        if user.isAdmin { Text("АДМИНИСТРАТОР").font(.caption2.bold()).padding(.horizontal, 10).padding(.vertical, 5).background(.purple.opacity(0.25)).clipShape(Capsule()) }
                    }
                    HStack(spacing: 12) {
                        BalanceCard(title: "STARS", value: user.stars, symbol: "star.fill", color: .yellow)
                        BalanceCard(title: "GRAM", value: user.gram, symbol: "diamond.fill", color: .cyan)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Мои подарки").font(.headline)
                        if user.gifts.isEmpty { Text("Пока нет подарков").foregroundStyle(.secondary).frame(maxWidth: .infinity, minHeight: 90) }
                        else { ForEach(user.gifts.indices, id: \\.self) { index in Label(user.gifts[index], systemImage: "gift.fill").padding(12).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 12)) } }
                    }
                    Button("Выйти из аккаунта", role: .destructive) { store.logout() }.frame(maxWidth: .infinity).padding(.top, 12)
                }.padding()
            }
            .background(Color(red: 0.055, green: 0.06, blue: 0.09))
            .navigationTitle("Antagram")
        }
    }
}

struct BalanceCard: View {
    let title: String
    let value: Int
    let symbol: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol).foregroundStyle(color).font(.title2)
            Text(value.formatted()).font(.system(size: 28, weight: .bold, design: .rounded))
            Text(title).font(.caption.bold()).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(.white.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
