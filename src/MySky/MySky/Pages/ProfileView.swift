//
//  ProfileView.swift
//  MySky
//
//  Created by Lika Nozadze on 19/10/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

struct ProfileView: View {
    @Query(sort: \ReleasedLantern.releasedAt, order: .reverse)
    private var lanterns: [ReleasedLantern]

    @AppStorage("profileName") private var name = ""
    @AppStorage("ritualMinutes") private var ritualMinutes = 20 * 60
    @AppStorage("remindersOn") private var remindersOn = false

    @State private var isEditingName = false
    @State private var draftName = ""


    private var topType: LanternType? {
        Dictionary(grouping: lanterns, by: \.type)
            .max { $0.value.count < $1.value.count }?.key
    }

    private var streak: Int {
        let cal = Calendar.current
        let days = Set(lanterns.map { cal.startOfDay(for: $0.releasedAt) })
        var day = cal.startOfDay(for: .now)
        if !days.contains(day) { day = cal.date(byAdding: .day, value: -1, to: day)! }
        var count = 0
        while days.contains(day) {
            count += 1
            day = cal.date(byAdding: .day, value: -1, to: day)!
        }
        return count
    }

    private var ritualTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: ritualMinutes / 60,
                                      minute: ritualMinutes % 60,
                                      second: 0, of: .now) ?? .now
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                ritualMinutes = (c.hour ?? 20) * 60 + (c.minute ?? 0)
            }
        )
    }


    var body: some View {
        ZStack {
            SkyBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                  
                    header
                    
                    statsCard

                    sectionTitle("Your intentions")
                    
                    intentionsCard

                    sectionTitle("Settings")
                    
                    settingsCard
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                
                .padding(.bottom, 40)
            }
            .safeAreaPadding(.top, 80)
        }

        
        .alert("Your name", isPresented: $isEditingName) {
            TextField("Your Name", text: $draftName)
            Button("Save") { name = draftName.trimmingCharacters(in: .whitespaces) }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: remindersOn) { _, _ in updateReminders() }
        .onChange(of: ritualMinutes) { _, _ in if remindersOn { updateReminders() } }
    }


    private var header: some View {
        HStack(spacing: 20) {
            Lantern(type: topType ?? .lanternYellow, width: 44)
                .frame(width: 96, height: 96)
                .overlay(Circle().stroke(.orange, lineWidth: 3))

            VStack(alignment: .leading, spacing: 12) {
                Text(name.isEmpty ? "Your Name" : name)
                    .font(.system(size: 24, weight: .bold))

                Button("Edit Profile") {
                    draftName = name
                    isEditingName = true
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: Capsule())
            }
        }
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            stat(value: "\(lanterns.count)", label: "Lanterns released")
            Divider().frame(height: 40).overlay(.white.opacity(0.3))
            stat(value: "\(streak)", label: "Day streak")
            Divider().frame(height: 40).overlay(.white.opacity(0.3))
            stat(value: topType?.title ?? "–", label: "Top intention")
        }
        .padding(.vertical, 18)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }


    private var intentionsCard: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(LanternType.allCases, id: \.self) { type in
                let count = lanterns.filter { $0.type == type }.count
                VStack(spacing: 8) {
                    Lantern(type: type, width: 52)
                    Text(type.title)
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(count) released")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Daily ritual time")
                Spacer()
                DatePicker("", selection: ritualTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            .padding(.vertical, 12)

            Divider().overlay(.white.opacity(0.2))

            Toggle("Reminders", isOn: $remindersOn)
                .tint(.orange)
                .padding(.vertical, 8)

            Divider().overlay(.white.opacity(0.2))

            NavigationLink {
                AboutRitualView()
            } label: {
                HStack {
                    Text("About ritual")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text).font(.system(size: 18, weight: .semibold))
    }


    private func updateReminders() {
        Task {
            let ok = await ReminderScheduler.update(enabled: remindersOn, minutes: ritualMinutes)
            if !ok { remindersOn = false }
        }
    }
}



enum ReminderScheduler {
    private static let id = "dailyRitual"


    static func update(enabled: Bool, minutes: Int) async -> Bool {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id])
        guard enabled else { return true }

        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        guard granted else { return false }

        let content = UNMutableNotificationContent()
        content.title = "Time for your ritual"
        content.body = "Write a wish and light it up"
        content.sound = .default

        var time = DateComponents()
        time.hour = minutes / 60
        time.minute = minutes % 60
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)

        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        return true
    }
}

struct AboutRitualView: View {
    private let steps = [
        ("Write", "Put it into words what you are holding onto."),
        ("Light", "Strike a match to ignite your intention."),
        ("Release", "Watch your lantern drift into the sky.")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("About the ritual")
                    .font(.system(size: 30, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Lantern(type: .lanternYellow, width: 70, glowRadius: 20)

                Text("For centuries, sky lanterns have carried wishes and worries into the night. In China they are called Kongming lanterns, released during the Lantern Festival as a sign of hope and of letting go.")
                    .font(.system(size: 15))
                    .lineSpacing(4)
                    .foregroundStyle(.white.opacity(0.9))

                Text("How it works")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                    ForEach(steps.indices, id: \.self) { i in
                        HStack(spacing: 14) {
                            Text("\(i + 1)")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(width: 30, height: 30)
                                .overlay(Circle().stroke(.orange, lineWidth: 2))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(steps[i].0)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(steps[i].1)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            Spacer()
                        }
                        .padding(.vertical, 14)

                        if i < steps.count - 1 {
                            Divider().overlay(.white.opacity(0.2))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(SkyBackground())
        .toolbar(.hidden, for: .tabBar)

    }
}

extension LanternType {
    var title: String {
        switch self {
        case .lanternRed: "Health"
        case .lanternYellow: "Success"
        case .lanternPink: "Love"
        case .lanternBlue: "Clarity"
        }
    }
}
