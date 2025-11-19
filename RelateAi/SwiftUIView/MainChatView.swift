import SwiftUI

// MARK: - Simple models (we can move these out later)

enum SenderType {
    case me
    case partner
    case ai
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let sender: SenderType
    let text: String
    let timestamp: Date
}

// MARK: - MainChatView

struct MainChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(sender: .ai,
                    text: "Welcome to your relationship room. I’m here to help both of you be heard clearly.",
                    timestamp: Date()),
        ChatMessage(sender: .partner,
                    text: "Hey, I’m still at work but wanted to check in.",
                    timestamp: Date()),
        ChatMessage(sender: .me,
                    text: "All good, just trying out this app 👀",
                    timestamp: Date())
    ]
    
    @State private var draft: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Relationship Room")
                        .font(.headline)
                    Text("You • Partner • AI Mediator")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                Text("AI Online")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.thinMaterial)
            
            Divider()
            
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: messages.count) {
                    if let lastId = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Input bar
            HStack(spacing: 8) {
                TextField("Type a message…", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                        .background(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newMessage = ChatMessage(sender: .me,
                                     text: trimmed,
                                     timestamp: Date())
        messages.append(newMessage)
        draft = ""
        
        // Fake AI reply for now (later: call backend / OpenAI)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let aiReply = ChatMessage(sender: .ai,
                                      text: "Here’s how I might reframe that so it lands well with your partner: “\(trimmed)”",
                                      timestamp: Date())
            messages.append(aiReply)
        }
    }
}

// MARK: - Bubble view

struct MessageBubble: View {
    let message: ChatMessage
    
    private var isFromMe: Bool { message.sender == .me }
    private var isFromAI: Bool { message.sender == .ai }
    
    var body: some View {
        HStack {
            if isFromMe { Spacer() }
            
            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                
                if isFromAI {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text("AI Mediator")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.secondary)
                }
                
                Text(message.text)
                    .padding(10)
                    .background(bubbleColor)
                    .foregroundColor(isFromMe ? .white : .primary)
                    .cornerRadius(16, corners: bubbleCorners)
                    .containerRelativeFrame(.horizontal, count: 10, span: 7, spacing: <#CGFloat#>)  // 70% width
                
            }
            
            if !isFromMe { Spacer() }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    private var bubbleColor: Color {
        if isFromAI { return Color(.systemYellow).opacity(0.2) }
        if isFromMe { return Color.accentColor }
        return Color(.secondarySystemBackground)
    }
    
    private var bubbleCorners: UIRectCorner {
        if isFromAI { return [.allCorners] }
        return isFromMe
            ? [.topLeft, .topRight, .bottomLeft]
            : [.topLeft, .topRight, .bottomRight]
    }
}



// MARK: - Corner radius helper

struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MainChatView()
    }
}

