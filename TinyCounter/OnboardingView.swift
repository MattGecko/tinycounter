//
//  OnboardingView.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//


// OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        TabView {
            OnboardingPage(title: "Welcome to Tiny Counter!", subtitle: "A beautiful way to count anything.", image: "1.circle.fill")
            OnboardingPage(title: "Themes & Presets", subtitle: "Customize your counters and choose from helpful presets.", image: "paintpalette.fill")
            OnboardingPage(title: "Go Premium", subtitle: "Unlock themes, remove ads, and support development.", image: "star.fill") {
                hasSeenOnboarding = true
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let image: String
    var onContinue: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.title)
                .bold()
            Text(subtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button(action: {
                onContinue?()
            }) {
                Text("Continue")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .opacity(onContinue != nil ? 1 : 0)
            Spacer()
        }
    }
}