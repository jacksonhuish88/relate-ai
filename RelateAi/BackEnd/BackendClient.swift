import Foundation
import Supabase
import Realtime

// MARK: - Models

struct Room: Identifiable, Codable {
    let id: UUID
    let code: String
    let created_at: String?
}

struct MessageDTO: Identifiable, Codable {
    let id: UUID
    let room_id: UUID
    let sender_type: String
    let text: String
    let created_at: String?
}

// MARK: - Backend Client

final class BackendClient {
    static let shared = BackendClient()

    let client: SupabaseClient

    private init() {
        // 🔥 YOUR REAL VALUES
        let supabaseURL = URL(string: "https://ifraeqsniimxvhurpxba.supabase.co")!
        let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmcmFlcXNuaWlteHZodXJweGJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1ODkxMzgsImV4cCI6MjA3OTE2NTEzOH0.SOUYx762Pk0qHINDRYa6deNbgKPJ8DhypCxlCPuXgq8"

        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )
    }

    // MARK: - Create Room

    func createRoom() async throws -> Room {
        let code = Self.generateRoomCode()

        struct NewRoom: Encodable { let code: String }

        // Insert, select the created row, return as Room
        let room: Room = try await client
            .from("rooms")
            .insert(NewRoom(code: code))
            .select()
            .single()
            .execute()
            .value

        return room
    }

    // MARK: - Join Room

    func joinRoom(code: String) async throws -> Room {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        let room: Room = try await client
            .from("rooms")
            .select()
            .eq("code", value: normalized)
            .single()
            .execute()
            .value

        return room
    }

    // MARK: - Send Message

    func sendMessage(roomId: UUID, senderType: String, text: String) async throws {
        struct NewMessage: Encodable {
            let room_id: UUID
            let sender_type: String
            let text: String
        }

        try await client
            .from("messages")
            .insert(
                NewMessage(
                    room_id: roomId,
                    sender_type: senderType,
                    text: text
                )
            )
            .execute()
    }

    // MARK: - Listen for Messages (Realtime)

    func listenForMessages(
        roomId: UUID,
        onMessage: @escaping (MessageDTO) -> Void
    ) -> RealtimeChannel {
        let channel = client.channel("room_\(roomId.uuidString)")

        // Listen to INSERTs on the messages table
        let _ = channel.onPostgresChange(
            InsertAction.self,
            schema: "public",
            table: "messages"
        ) { insert in
            do {
                // Decode JSON payload into our MessageDTO model
                let message = try insert.decodeRecord(as: MessageDTO.self,decoder: JSONDecoder())

                // Only forward messages for this room
                if message.room_id == roomId {
                    onMessage(message)
                }
            } catch {
                print("❌ Failed to decode MessageDTO from realtime insert:", error)
            }
        }

        // Subscribe to the channel
        Task {
            do {
                try await channel.subscribeWithError()
                print("✅ Subscribed to room \(roomId)")
            } catch {
                print("❌ Failed to subscribe to room \(roomId): \(error)")
            }
        }

        return channel
    }

    // MARK: - Fetch Messages

    func fetchMessages(roomId: UUID) async throws -> [MessageDTO] {
        let messages: [MessageDTO] = try await client
            .from("messages")
            .select()
            .eq("room_id", value: roomId)
            .order("created_at", ascending: true)
            .execute()
            .value

        return messages
    }

    // MARK: - Helper

    private static func generateRoomCode() -> String {
        let chars = Array("ABCDEFGHJKMNPQRSTUVWXYZ23456789")
        return String((0..<6).map { _ in chars.randomElement()! })
    }
}
