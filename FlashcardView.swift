import SwiftUI

struct FlashcardView: View {
    let front: String
    let back: String

    @State private var isFlipped = false
    @State private var rotation = 0.0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)

            Group {
                if isFlipped {
                    Text(back)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding()
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // fixes mirror
                } else {
                    Text(front)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding()
                }
            }
        }
        .frame(height: 220)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring()) {
                rotation += 180
                isFlipped.toggle()
            }
        }
        .padding(.horizontal)
    }
}
