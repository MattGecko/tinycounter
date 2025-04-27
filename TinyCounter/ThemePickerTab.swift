//
//  ThemePickerTab.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//



// ThemePickerTab.swift
import SwiftUI


struct ThemePickerTab: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingCreator = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Free Themes")) {
                    ForEach(themeManager.allThemes.filter { !$0.isPremium }) { theme in
                        themeRow(theme)
                    }
                }

                Section(header: Text("Premium Themes")) {
                    ForEach(themeManager.allThemes.filter { $0.isPremium }) { theme in
                        themeRow(theme)
                    }
                }

                if store.isPremium {
                    Section(header: Text("Your Custom Themes")) {
                        ForEach(themeManager.customThemes) { theme in
                            themeRow(theme)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { themeManager.deleteCustomTheme(themeManager.customThemes[$0]) }
                        }
                    }

                    Button("Create New Theme") {
                        showingCreator = true
                    }
                } else {
                    Section {
                        Button("Create New Theme (Premium)") {
                            NotificationCenter.default.post(name: .showPaywall, object: nil)
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Choose Theme")
            .sheet(isPresented: $showingCreator) {
                ThemeCreatorView()
            }
        }
    }

    @ViewBuilder
    func themeRow(_ theme: AppTheme) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(theme.name)
                    .foregroundColor(themeManager.selectedTheme.id == theme.id ? .blue : .primary)
                if theme.isPremium && !store.isPremium {
                    Text("Premium")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Circle()
                .fill(theme.primary.swiftUIColor)
                .frame(width: 20, height: 20)
            Circle()
                .fill(theme.background.swiftUIColor)
                .frame(width: 20, height: 20)
            Circle()
                .fill(theme.text.swiftUIColor)
                .frame(width: 20, height: 20)

            if theme.isPremium && !store.isPremium {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            } else if themeManager.selectedTheme.id == theme.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if theme.isPremium && !store.isPremium {
                NotificationCenter.default.post(name: .showPaywall, object: nil)
            } else {
                themeManager.selectTheme(theme)
            }
        }
        .opacity(theme.isPremium && !store.isPremium ? 0.5 : 1.0)
    }
}