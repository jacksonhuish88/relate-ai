import Foundation

// What the ViewModels depend on
protocol RoomService {
    func createRoom(displayName: String) async throws -> Room
    func joinRoom(code: String, displayName: String) async throws -> Room
}

// Concrete implementation using your BackendClient
final class SupabaseRoomService: RoomService {
    static let shared = SupabaseRoomService(backend: .shared)

    private let backend: BackendClient

    init(backend: BackendClient) {
        self.backend = backend
    }
    
    func createRoom(displayName: String) async throws -> Room {
        // TODO: Call Supabase via backend to create a room row and return Room
        // Example shape (you wire up actual DB call):
        //
        // let response = try await backend.createRoom(displayName: displayName)
        // return response.toRoom()
        throw NSError(domain: "NotImplemented", code: -1)
    }

    func joinRoom(code: String, displayName: String) async throws -> Room {
        // TODO: Call Supabase to find room by code, maybe create user/participant
        //
        // let response = try await backend.joinRoom(code: code, displayName: displayName)
        // return response.toRoom()
        throw NSError(domain: "NotImplemented", code: -1)
    }
}
