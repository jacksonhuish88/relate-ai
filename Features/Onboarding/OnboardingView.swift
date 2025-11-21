import SwiftUI

struct OnboardingView: View {
    @State private var displayName: String = ""
    @State private var relationshipCode: String = ""
    @State private var isCreatingRoom: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(.systemIndigo),
                    Color(.systemPurple)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                // App title
                VStack(spacing: 8) {
                    Text("RelateAi")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("AI that helps you say what you meant, not just what you said.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 40)

                // Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Let’s set things up")
                        .font(.headline)

                    // Name field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your name")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Jackson", text: $displayName)
                            .textInputAutocapitalization(.words)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    // Relationship code field
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Relationship code (if your partner already created one)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("e.g. H7K9QF", text: $relationshipCode)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(12)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    // Buttons
                    VStack(spacing: 12) {
                        NavigationLink {
                            CreateRoomView(displayName: displayName.isEmpty ? "You" : displayName)
                        } label: {
                            Text("Create New Relationship Room")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(displayName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)

                        NavigationLink {
                            JoinRoomView(displayName: displayName.isEmpty ? "You" : displayName)
                        } label: {
                            Text("Join Existing Room")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemBackground))
                                .foregroundColor(.accentColor)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
                                )
                        }
                        .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(displayName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                    }

                    .padding(.top, 8)

                    Text("You’ll be able to invite your partner and let the AI help you mediate your conversations.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .padding(.horizontal, 24)
                .shadow(radius: 18, y: 8)

                Spacer()
            }
        }
    }

    // MARK: - Actions

    private func handleCreateRoom() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter your name so your partner knows who you are."
            showingAlert = true
            return
        }

        isCreatingRoom = true
        alertMessage = "We’ll create a new relationship room for \(displayName).\n\n(Next step: call backend to actually create it.)"
        showingAlert = true

        print("[Onboarding] Create room tapped by \(displayName)")
    }

    private func handleJoinRoom() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Please enter your name first."
            showingAlert = true
            return
        }

        guard !relationshipCode.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Enter the relationship code your partner sent you."
            showingAlert = true
            return
        }

        isCreatingRoom = false
        alertMessage = "We’ll try to join room \(relationshipCode) for \(displayName).\n\n(Next step: call backend to validate the code.)"
        showingAlert = true

        print("[Onboarding] Join room tapped by \(displayName) with code \(relationshipCode)")
    }
}

#Preview {
    OnboardingView()
}

