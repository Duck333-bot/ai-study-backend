import SwiftUI

struct StudyCategory: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let background: LinearGradient
}

let categories: [StudyCategory] = [
    StudyCategory(
        title: "History",
        icon: "globe.europe.africa",
        color: .white,
        background: LinearGradient(
            colors: [Color(red: 255/255, green: 230/255, blue: 200/255), Color(red: 250/255, green: 210/255, blue: 170/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    ),
    StudyCategory(
        title: "Science",
        icon: "atom",
        color: .white,
        background: LinearGradient(
            colors: [Color(red: 200/255, green: 240/255, blue: 255/255), Color(red: 150/255, green: 210/255, blue: 255/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    ),
    StudyCategory(
        title: "Art",
        icon: "paintbrush.pointed.fill",
        color: .white,
        background: LinearGradient(
            colors: [Color(red: 255/255, green: 220/255, blue: 240/255), Color(red: 255/255, green: 190/255, blue: 230/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    ),
    StudyCategory(
        title: "Literature",
        icon: "books.vertical.fill",
        color: .white,
        background: LinearGradient(
            colors: [Color(red: 230/255, green: 255/255, blue: 200/255), Color(red: 200/255, green: 240/255, blue: 150/255)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    ),
    StudyCategory(
        title: "Ask AI",
        icon: "message.fill",
        color: .white,
        background: LinearGradient(
            colors: [Color.purple.opacity(0.3), Color.indigo.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    )
]

struct ContentView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Study Dashboard")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(categories) { category in
                            NavigationLink(destination: destinationView(for: category.title)) {
                                ZStack {
                                    category.background
                                        .cornerRadius(20)
                                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

                                    VStack(spacing: 12) {
                                        Image(systemName: category.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(category.color)

                                        Text(category.title)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(category.color)
                                    }
                                    .padding()
                                }
                                .frame(height: 140)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }

    func destinationView(for title: String) -> some View {
        if title == "Ask AI" {
            return AnyView(AIChatView())
        } else {
            return AnyView(StudyDetailView(category: title))
        }
    }
}
