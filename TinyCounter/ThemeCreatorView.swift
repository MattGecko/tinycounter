//
//  ThemeCreatorView.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


import SwiftUI

struct ThemeCreatorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var primaryColor = Color.blue
    @State private var backgroundColor = Color.white
    @State private var textColor = Color.primary

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Theme name", text: $name)
                }

                Section(header: Text("Colors")) {
                    ColorPicker("Primary", selection: $primaryColor)
                    ColorPicker("Background", selection: $backgroundColor)
                    ColorPicker("Text", selection: $textColor)
                }

                Section(header: Text("Preview")) {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(primaryColor)
                            .frame(width: 50, height: 50)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                            .frame(width: 50, height: 50)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(textColor)
                            .frame(width: 50, height: 50)
                    }
                }

                Button("Save Theme") {
                    let new = AppTheme(
                        id: UUID(),
                        name: name,
                        isPremium: false,
                        primary: ColorData(primaryColor),
                        background: ColorData(backgroundColor),
                        text: ColorData(textColor)
                    )
                    themeManager.addCustomTheme(new)
                    themeManager.selectTheme(new)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle("New Theme")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
