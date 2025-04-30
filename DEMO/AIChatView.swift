import SwiftUI

struct Message: Identifiable, Equatable {
    let id = UUID()
    let isUser: Bool
    var text: String
}

struct AIChatView: View {
    @State private var messages: [Message] = [
        Message(isUser: false, text: "Hi! Upload your study notes and ask me anything.")
    ]
    @State private var inputText: String = ""
    @State private var isLoading = false
    @State private var showTypingIndicator = false

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(messages) { message in
                            HStack(alignment: .bottom, spacing: 8) {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(20)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                } else {
                                    Image(systemName: "brain.head.profile")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.black)
                                    Text(cleanMarkdown(message.text))
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .shadow(radius: 1)
                                        .frame(maxWidth: 250, alignment: .leading)
                                    Spacer()
                                }
                            }
                            .id(message.id)
                            .padding(.horizontal)
                        }

                        if showTypingIndicator {
                            HStack(spacing: 8) {
                                Image(systemName: "brain.head.profile")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                                TypingIndicatorView()
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                .background(Color(UIColor.systemGray6))
                .onChange(of: messages.count) { _ in
                    if let lastID = messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack {
                Button(action: {
                    // Placeholder for upload action
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18))
                }

                TextField("Ask something...", text: $inputText)
                    .padding(12)
                    .background(Color(.systemGray5))
                    .cornerRadius(16)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 18, weight: .bold))
                        .padding(10)
                }
                .disabled(inputText.isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("AI Study Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
    }

    // MARK: - Typing Bubble
    struct TypingIndicatorView: View {
        @State private var scale: CGFloat = 0.8
        @State private var opacity: Double = 0.4

        var body: some View {
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: scale
                        )
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(20)
            .onAppear {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    // MARK: - Message Sending Logic
    private func sendMessage() {
        let userMessage = Message(isUser: true, text: inputText)
        messages.append(userMessage)

        inputText = ""
        showTypingIndicator = true

        let url = URL(string: "https://your-service-name.onrender.com/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let body: [String: Any] = ["message": userMessage.text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error:", error?.localizedDescription ?? "Unknown error")
                DispatchQueue.main.async {
                    showTypingIndicator = false
                }
                return
            }

            if let jsonText = String(data: data, encoding: .utf8) {
                let clean = cleanStreamingResponse(jsonText)
                let aiMessage = Message(isUser: false, text: clean)
                DispatchQueue.main.async {
                    self.messages.append(aiMessage)
                    self.showTypingIndicator = false
                }
            }
        }.resume()
    }

    // MARK: - Strip markdown from response
    func cleanMarkdown(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "#", with: "")
    }

    // MARK: - Parse streamed JSON response into readable text
    func cleanStreamingResponse(_ raw: String) -> String {
        var result = ""
        let lines = raw.components(separatedBy: "\n")
        for line in lines {
            if line.contains("\"content\"") {
                if let range = line.range(of: "\"content\":\"") {
                    let rest = line[range.upperBound...]
                    if let endRange = rest.range(of: "\"") {
                        let content = rest[..<endRange.lowerBound]
                        result += content.replacingOccurrences(of: "\\n", with: "\n")
                    }
                }
            }
        }
        return cleanMarkdown(result)
    }
}
