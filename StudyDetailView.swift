import SwiftUI

struct StudyDetailView: View {
    let category: String

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text(category)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                FlashcardView(
                    front: "What is the capital of France?",
                    back: "Paris"
                )

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
