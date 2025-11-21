//
//  ContentView.swift
//  RelateAi
//
//  Created by Jackson Huish on 11/19/25.
//

import SwiftUI
import Realtime

struct ContentView: View {
    @State private var roomCode: String = ""
    @State private var room: Room?
    @State private var messages: [MessageDTO] = []
    @State private var draft: String = ""
    @State private var statusMessage: String?
    @State private var messageChannel: RealtimeChannel?
    @State private var isWorking: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                roomHeader
                Divider()
                messageList
                messageComposer
            }
            .padding()
            .navigationTitle("Relationship Room")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { unsubscribe() }
            .alert(
                "Error",
                isPresented: Binding<Bool>(
                    get: { statusMessage != nil },
                    set: { if !$0 { statusMessage = nil } }
                )
            ) {
                Button("OK") { statusMessage = nil }
            } message: {
                if let statusMessage { Text(statusMessage) }
            }
        }
    }

    private var roomHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Enter room code", text: $roomCode)
                    .textInputAutocapitalization(.characters)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)

                Button("Join") { joinRoom() }
                    .buttonStyle(.borderedProminent)
                    .disabled(isWorking || roomCode.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Button {
                createRoom()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create new room")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isWorking)

            if let room {
                HStack {
                    Text("Active room:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(room.code)
                        .font(.headline)
                        .monospaced()
                }
            } else {
                Text("No room joined yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            if message.sender_type == "user" { Spacer() }
                            VStack(alignment: message.sender_type == "user" ? .trailing : .leading, spacing: 4) {
                                Text(message.sender_type.capitalized)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(message.text)
                                    .padding(10)
                                    .background(message.sender_type == "user" ? Color.accentColor : Color(.secondarySystemBackground))
                                    .foregroundColor(message.sender_type == "user" ? .white : .primary)
                                    .cornerRadius(12)
                            }
                            if message.sender_type != "user" { Spacer() }
                        }
                        .id(message.id)
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _ in
                if let last = messages.last?.id {
                    withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                }
            }
        }
    }

    private var messageComposer: some View {
        HStack(spacing: 8) {
            TextField("Type a message…", text: $draft, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .disabled(room == nil)

            Button {
                Task { await sendMessage() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(10)
                    .background(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || room == nil ? Color.gray.opacity(0.3) : Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || room == nil)
        }
    }

    private func createRoom() {
        Task {
            isWorking = true
            defer { isWorking = false }

            do {
                let newRoom = try await BackendClient.shared.createRoom()
                await handleJoined(room: newRoom)
            } catch {
                statusMessage = error.localizedDescription
            }
        }
    }

    private func joinRoom() {
        Task {
            isWorking = true
            defer { isWorking = false }

            do {
                let joined = try await BackendClient.shared.joinRoom(code: roomCode)
                await handleJoined(room: joined)
            } catch {
                statusMessage = error.localizedDescription
            }
        }
    }

    @MainActor
    private func handleJoined(room: Room) async {
        unsubscribe()
        self.room = room

        do {
            messages = try await BackendClient.shared.fetchMessages(roomId: room.id)
        } catch {
            statusMessage = error.localizedDescription
        }

        messageChannel = BackendClient.shared.listenForMessages(roomId: room.id) { message in
            Task { @MainActor in
                if messages.contains(where: { $0.id == message.id }) == false {
                    messages.append(message)
                }
            }
        }
    }

    private func unsubscribe() {
        guard let channel = messageChannel else { return }
        messageChannel = nil

        Task {
            try? await channel.unsubscribe()
        }
    }

    private func sendMessage() async {
        guard let room else { return }
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        draft = ""

        do {
            try await BackendClient.shared.sendMessage(
                roomId: room.id,
                senderType: "user",
                text: trimmed
            )
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
