import Foundation
import Combine

@MainActor
final class CreateRoomViewModel: ObservableObject {
    // Input
    let displayName: String

    // State for the UI
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var createdRoom: Room?

    private let roomService: RoomService

    init(displayName: String, roomService: RoomService? = nil)
        {
            self.displayName = displayName
            // 👍 This line runs inside the @MainActor context, so it's allowed
            self.roomService = roomService ?? SupabaseRoomService.shared
        }

    func createRoom() {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let room = try await roomService.createRoom(displayName: displayName)
                self.createdRoom = room
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
