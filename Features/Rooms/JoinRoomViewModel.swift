import Foundation
import Combine

@MainActor
final class JoinRoomViewModel: ObservableObject {
    // Input
    let displayName: String

    // User’s typed code
    @Published var roomCode: String = ""

    // State for UI
    @Published var isJoining: Bool = false
    @Published var errorMessage: String?
    @Published var joinedRoom: Room?

    private let roomService: RoomService

    init(displayName: String, roomService: RoomService? = nil)
        {
            self.displayName = displayName
            // 👍 This line runs inside the @MainActor context, so it's allowed
            self.roomService = roomService ?? SupabaseRoomService.shared
        }

    func joinRoom() {
        let trimmed = roomCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a room code."
            return
        }
        guard !isJoining else { return }

        isJoining = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let room = try await roomService.joinRoom(code: trimmed,
                                                          displayName: displayName)
                self.joinedRoom = room
                self.isJoining = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isJoining = false
            }
        }
    }
}
