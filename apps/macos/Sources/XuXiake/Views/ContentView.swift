import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppErrorState.self) private var errorState
    @Query(sort: \Trip.startDate) private var trips: [Trip]
    @SceneStorage("selectedTripID") private var selectedTripID: String?
    @State private var editingTrip: Trip?
    @State private var tripPendingDeletion: Trip?
    @State private var renamingTripID: UUID?

    private var selectedTrip: Trip? {
        guard let selectedTripID else { return trips.first }
        return trips.first { $0.id.uuidString == selectedTripID } ?? trips.first
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(selection: $selectedTripID) {
                    Section {
                        ForEach(trips) { trip in
                            TripSidebarRow(
                                trip: trip,
                                isRenaming: renamingTripID == trip.id,
                                onBeginRenaming: {
                                    selectedTripID = trip.id.uuidString
                                    renamingTripID = trip.id
                                },
                                onSaveTitle: { title in renameTrip(trip, to: title) },
                                onFinishRenaming: { renamingTripID = nil }
                            )
                                .tag(trip.id.uuidString)
                                .contextMenu {
                                    Button("编辑旅行…", systemImage: "pencil") {
                                        editingTrip = trip
                                    }
                                    Divider()
                                    Button("删除旅行", role: .destructive) { tripPendingDeletion = trip }
                                }
                        }
                    } header: {
                        HStack(spacing: 8) {
                            Text("旅行")
                            Spacer()
                            Button(action: createTrip) {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.borderless)
                            .help("新建旅行")
                            .accessibilityLabel("新建旅行")
                        }
                    }
                }
                .listStyle(.sidebar)
                .contextMenu {
                    Button("新建旅行", systemImage: "plus", action: createTrip)
                }
                Divider()
                SettingsLink {
                    Label("配置", systemImage: "gearshape")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .help("打开配置")
                .accessibilityLabel("打开配置")
            }
            .navigationTitle("徐霞客")
        } detail: {
            Group {
                if let selectedTrip {
                    TripWorkspaceView(trip: selectedTrip)
                        .id(selectedTrip.id)
                } else {
                    ContentUnavailableView {
                        Label("开始规划旅行", systemImage: "map")
                    } description: {
                        Text("创建一次旅行，然后添加想做和必须做的事项。")
                    } actions: {
                        Button("新建旅行", action: createTrip)
                            .accessibilityLabel("新建旅行")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            if selectedTripID == nil {
                selectedTripID = trips.first?.id.uuidString
            }
        }
        .focusedSceneValue(\.newTripAction, NewTripAction(perform: createTrip))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Text(AppVersionInfo.displayString)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .help("应用版本信息")
                    .accessibilityLabel("应用版本 \(AppVersionInfo.displayString)")
            }
        }
        .sheet(item: $editingTrip) { trip in
            TripEditorView(trip: trip)
        }
        .confirmationDialog(
            "删除“\(tripPendingDeletion?.title ?? "此旅行")”？",
            isPresented: Binding(
                get: { tripPendingDeletion != nil },
                set: { if !$0 { tripPendingDeletion = nil } }
            )
        ) {
            Button("删除旅行", role: .destructive) {
                if let tripPendingDeletion { deleteTrip(tripPendingDeletion) }
                tripPendingDeletion = nil
            }
            Button("取消", role: .cancel) { tripPendingDeletion = nil }
        } message: {
            Text("旅行中的全部事项、时间、费用和备注都会删除，此操作无法撤销。")
        }
        .alert(
            errorState.title,
            isPresented: Binding(
                get: { errorState.message != nil },
                set: { if !$0 { errorState.message = nil } }
            )
        ) {
            Button("好") { errorState.message = nil }
        } message: {
            Text(errorState.message ?? "")
        }
    }

    private func createTrip() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.date(byAdding: .day, value: 4, to: start) ?? start
        let trip = Trip(title: "未命名旅行", destination: "", startDate: start, endDate: end)
        modelContext.insert(trip)
        errorState.save(modelContext, operation: "新建旅行")
        selectedTripID = trip.id.uuidString
    }

    private func deleteTrip(_ trip: Trip) {
        modelContext.delete(trip)
        errorState.save(modelContext, operation: "删除旅行")
        selectedTripID = trips.first(where: { $0.id != trip.id })?.id.uuidString
    }

    private func renameTrip(_ trip: Trip, to title: String) {
        trip.title = title
        errorState.save(modelContext, operation: "重命名旅行")
    }
}

private struct TripSidebarRow: View {
    let trip: Trip
    let isRenaming: Bool
    let onBeginRenaming: () -> Void
    let onSaveTitle: (String) -> Void
    let onFinishRenaming: () -> Void

    @State private var titleDraft: String
    @FocusState private var titleIsFocused: Bool

    init(
        trip: Trip,
        isRenaming: Bool,
        onBeginRenaming: @escaping () -> Void,
        onSaveTitle: @escaping (String) -> Void,
        onFinishRenaming: @escaping () -> Void
    ) {
        self.trip = trip
        self.isRenaming = isRenaming
        self.onBeginRenaming = onBeginRenaming
        self.onSaveTitle = onSaveTitle
        self.onFinishRenaming = onFinishRenaming
        _titleDraft = State(initialValue: trip.title)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "map")
                .foregroundStyle(.secondary)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                if isRenaming {
                    TextField("旅行名称", text: $titleDraft)
                        .textFieldStyle(.plain)
                        .focused($titleIsFocused)
                        .onSubmit(saveTitle)
                        .onChange(of: titleIsFocused) { wasFocused, isFocused in
                            if wasFocused && !isFocused {
                                saveTitle()
                            }
                        }
                        .onAppear {
                            titleDraft = trip.title
                            titleIsFocused = true
                        }
                } else {
                    Text(trip.title).lineLimit(1)
                }
                Text(trip.destination.isEmpty ? "尚未设置目的地" : trip.destination)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            if !isRenaming {
                onBeginRenaming()
            }
        }
        .accessibilityAction(named: "重命名") {
            if !isRenaming {
                onBeginRenaming()
            }
        }
    }

    private func saveTitle() {
        let trimmedTitle = titleDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty, trimmedTitle != trip.title {
            onSaveTitle(trimmedTitle)
        } else if trimmedTitle.isEmpty {
            titleDraft = trip.title
        }
        onFinishRenaming()
    }
}
