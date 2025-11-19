import SwiftUI

struct CreateRoomView: View {
    let displayName: String   // passed in from onboarding
    @State private var roomCode: String = "H7K9QF" // placeholder for now

    var body: some View {
        VStack(spacing: 24) {
            Text("Your Relationship Room")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)

            Text("Share this code with your partner so only the two of you can join.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Big room code
            Text(roomCode)
                .font(.system(size: 40, weight: .heavy, design: .monospaced))
                .padding(.vertical, 16)
                .padding(.horizontal, 32)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)

            VStack(spacing: 12) {
                Button {
                    UIPasteboard.general.string = roomCode
                } label: {
                    Text("Copy Code")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    // later: present native share sheet
                    print("[CreateRoom] Share invite tapped")
                } label: {
                    Text("Share Invite")
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
            }
            .padding(.horizontal, 24)

            Spacer()

            Text("Created by \(displayName). Once your partner joins, the AI will start helping you both communicate more clearly.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
        }
        .navigationTitle("Create Room")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CreateRoomView(displayName: "Jackson")
    }
}

