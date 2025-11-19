import SwiftUI

struct JoinRoomView: View {
    let displayName: String   // passed in from onboarding
    @State private var roomCode: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Join Relationship Room")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Enter the room code your partner shared with you.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            TextField("H7K9QF", text: $roomCode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textCase(.uppercase)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .keyboardType(.asciiCapable)
                .padding(.horizontal, 32)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                handleJoin()
            } label: {
                Text("Join Room")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Text("Joining as \(displayName). Your messages will be private between you, your partner, and the AI mediator.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
        }
        .navigationTitle("Join Room")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleJoin() {
        let trimmed = roomCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter the room code your partner sent you."
            return
        }
        
        // Later: call backend to validate this code.
        print("[JoinRoom] \(displayName) tried to join room \(trimmed)")
        
        // Fake validation for now:
        if trimmed.count < 5 {
            errorMessage = "That doesn’t look like a valid room code. Double-check and try again."
        } else {
            errorMessage = nil
            // later: navigate to chat
        }
    }
}

#Preview {
    NavigationStack {
        JoinRoomView(displayName: "Gianna")
    }
}

