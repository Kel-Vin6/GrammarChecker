//
//  ContentView.swift
//  GrammarChecker
//
//  Created by Kelvin Wallace on 27/06/2026.
//

// GrammarCheckerApp.swift
// Production-ready Grammar Checker for iOS/macOS
// Single-file SwiftUI implementation — Swift 5.9+, iOS 17+


import SwiftUI
import NaturalLanguage
import Combine
import UIKit
import RevenueCat
import RevenueCatUI


// MARK: - Splash Screen

struct SplashScreenView: View {
    let onFinish: () -> Void

    // Master phase: 0 = idle, 1 = animating, 2 = done
    @State private var phase: Int = 0

    // Logo elements
    @State private var logoScale: CGFloat       = 0.35
    @State private var logoOpacity: Double      = 0
    @State private var logoRotation: Double     = -18
    @State private var ringScale: CGFloat       = 0.3
    @State private var ringOpacity: Double      = 0
    @State private var glowOpacity: Double      = 0

    // Orbiting particles
    @State private var particleAngles: [Double] = [0, 72, 144, 216, 288]
    @State private var particleOpacity: Double  = 0
    @State private var particleScale: CGFloat   = 0

    // Text reveal
    @State private var titleOpacity: Double     = 0
    @State private var titleOffset: CGFloat     = 24
    @State private var taglineOpacity: Double   = 0
    @State private var taglineOffset: CGFloat   = 16

    // Typewriter effect
    @State private var typedChars: Int          = 0
    private let tagline = "Write without limits."

    // Word pills
    @State private var pillOpacities: [Double]  = [0, 0, 0, 0, 0]
    private let pills: [(String, Color)] = [
        ("grammar", .blue),
        ("spelling", .orange),
        ("clarity", .purple),
        ("style", .teal),
        ("voice", .pink)
    ]

    // Exit burst
    @State private var burstScale: CGFloat      = 1
    @State private var burstOpacity: Double     = 0
    @State private var exitScale: CGFloat       = 1
    @State private var exitOpacity: Double      = 1

    // Continuous orbit timer
    @State private var orbitAngle: Double       = 0
    private let orbitTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background — deep ink gradient feel
            backgroundLayer

            // Burst flash on exit
            Circle()
                .fill(.white)
                .frame(width: 600, height: 600)
                .scaleEffect(burstScale)
                .opacity(burstOpacity)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                // ── Logo cluster ──
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#5E9FFF"), Color(hex: "#A78BFA"), Color(hex: "#5E9FFF")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Secondary shimmer ring
                    Circle()
                        .stroke(Color(hex: "#A78BFA").opacity(0.25), lineWidth: 0.5)
                        .frame(width: 148, height: 148)
                        .scaleEffect(ringScale * 0.92)
                        .opacity(ringOpacity * 0.6)

                    // Glow blob
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#5E9FFF").opacity(0.35), .clear],
                                center: .center, startRadius: 0, endRadius: 70
                            )
                        )
                        .frame(width: 140, height: 140)
                        .opacity(glowOpacity)
                        .blur(radius: 12)

                    // Orbiting particles
                    ForEach(0..<5, id: \.self) { i in
                        orbitParticle(index: i)
                    }

                    // Logo mark — stylised "G✓" pen nib icon
                    logoMark
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .rotationEffect(.degrees(logoRotation))
                }
                .frame(width: 180, height: 180)

                Spacer().frame(height: 40)

                // ── App name ──
                Text("GrammarCheck")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#E8F0FF"), Color(hex: "#A78BFA")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                Spacer().frame(height: 10)

                // ── Typewriter tagline ──
                HStack(spacing: 0) {
                    Text(String(tagline.prefix(typedChars)))
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(hex: "#8BA3CC"))
                    // Blinking cursor
                    if typedChars < tagline.count {
                        BlinkingCursor()
                    }
                }
                .frame(height: 22)
                .opacity(taglineOpacity)
                .offset(y: taglineOffset)

                Spacer().frame(height: 40)

                // ── Feature pills ──
                HStack(spacing: 8) {
                    ForEach(Array(pills.enumerated()), id: \.offset) { idx, pill in
                        Text(pill.0)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(pill.1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(pill.1.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(pill.1.opacity(0.3), lineWidth: 0.5))
                            .opacity(pillOpacities[idx])
                            .scaleEffect(pillOpacities[idx] == 1 ? 1 : 0.7)
                    }
                }

                Spacer()

                // ── Bottom tagline ──
                VStack(spacing: 4) {
                    Text("by")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "#3D5470"))
                    Text("Precision Writing Co.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#5A7A9F"))
                }
                .opacity(taglineOpacity)
                .padding(.bottom, 44)
            }
        }
        .scaleEffect(exitScale)
        .opacity(exitOpacity)
        .ignoresSafeArea()
        .onAppear { runSequence() }
        .onReceive(orbitTimer) { _ in
            guard phase == 1 else { return }
            orbitAngle += 0.8
        }
    }

    // MARK: Logo mark

    private var logoMark: some View {
        ZStack {
            // Icon background
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1E3A5F"), Color(hex: "#0D1B2A")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#5E9FFF").opacity(0.6), Color(hex: "#A78BFA").opacity(0.4)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )

            // Pen + check
            ZStack {
                Image(systemName: "pencil.and.outline")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "#5E9FFF"), Color(hex: "#A78BFA")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#34D399"))
                    .offset(x: 14, y: 12)
                    .background(
                        Circle().fill(Color(hex: "#0D1B2A")).frame(width: 16, height: 16).offset(x: 14, y: 12)
                    )
            }
        }
    }

    // MARK: Orbit particle

    private func orbitParticle(index i: Int) -> some View {
        let baseAngle = particleAngles[i] + orbitAngle
        let radians = baseAngle * .pi / 180
        let radius: CGFloat = 72
        let x = radius * cos(radians)
        let y = radius * sin(radians)
        let size: CGFloat = i % 2 == 0 ? 5 : 3.5
        let colors: [Color] = [
            Color(hex: "#5E9FFF"),
            Color(hex: "#A78BFA"),
            Color(hex: "#34D399"),
            Color(hex: "#F472B6"),
            Color(hex: "#FBBF24")
        ]

        return Circle()
            .fill(colors[i])
            .frame(width: size, height: size)
            .shadow(color: colors[i].opacity(0.8), radius: 4)
            .offset(x: x, y: y)
            .opacity(particleOpacity)
            .scaleEffect(particleScale)
    }

    // MARK: Background

    private var backgroundLayer: some View {
        ZStack {
            Color(hex: "#060D18")

            // Top aurora
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#1A3A6B").opacity(0.6), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 300)
                .offset(x: 60, y: -320)
                .blur(radius: 40)

            // Bottom aurora
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#2D1B6B").opacity(0.5), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 350, height: 280)
                .offset(x: -80, y: 380)
                .blur(radius: 50)

            // Subtle grid dots
            GeometryReader { geo in
                Canvas { ctx, size in
                    let spacing: CGFloat = 32
                    let cols = Int(size.width / spacing) + 1
                    let rows = Int(size.height / spacing) + 1
                    for col in 0...cols {
                        for row in 0...rows {
                            let x = CGFloat(col) * spacing
                            let y = CGFloat(row) * spacing
                            let rect = CGRect(x: x - 1, y: y - 1, width: 2, height: 2)
                            ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.04)))
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: Animation sequence

    private func runSequence() {
        phase = 1

        // ── Step 1: Ring expands in (0.0s) ──
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            ringScale   = 1
            ringOpacity = 1
        }

        // ── Step 2: Logo bounces in (0.15s) ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.5)) {
                logoScale    = 1.08
                logoOpacity  = 1
                logoRotation = 0
            }
            // Settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    logoScale = 1.0
                }
            }
        }

        // ── Step 3: Glow + particles (0.4s) ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.5)) {
                glowOpacity    = 1
                particleOpacity = 1
                particleScale  = 1
            }
        }

        // ── Step 4: Title slides up (0.65s) ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                titleOpacity = 1
                titleOffset  = 0
            }
        }

        // ── Step 5: Tagline fades (0.85s) ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            withAnimation(.easeOut(duration: 0.4)) {
                taglineOpacity = 1
                taglineOffset  = 0
            }
            // Typewriter
            typeNextChar(delay: 0.1)
        }

        // ── Step 6: Pills stagger in (1.3s) ──
        for i in 0..<pills.count {
            let delay = 1.3 + Double(i) * 0.09
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                    pillOpacities[i] = 1
                }
            }
        }

        // ── Step 7: Hold then exit burst (2.8s) ──
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            phase = 2
            // White flash
            withAnimation(.easeOut(duration: 0.15)) {
                burstOpacity = 0.9
                burstScale   = 1
            }
            withAnimation(.easeIn(duration: 0.25).delay(0.1)) {
                burstOpacity = 0
                burstScale   = 2.5
            }
            // Whole screen scales up and fades — feels like zooming into the app
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.05)) {
                exitScale = 1.12
            }
            withAnimation(.easeIn(duration: 0.35).delay(0.15)) {
                exitOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                onFinish()
            }
        }
    }

    private func typeNextChar(delay: Double) {
        guard typedChars < tagline.count else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.none) { typedChars += 1 }
            let nextDelay = Double.random(in: 0.04...0.09)
            typeNextChar(delay: nextDelay)
        }
    }
}

// MARK: - Blinking Cursor

struct BlinkingCursor: View {
    @State private var visible = true
    var body: some View {
        Rectangle()
            .fill(Color(hex: "#5E9FFF"))
            .frame(width: 2, height: 15)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    visible = false
                }
            }
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 6: (a,r,g,b) = (255,(int>>16)&0xFF,(int>>8)&0xFF,int&0xFF)
        case 8: (a,r,g,b) = ((int>>24)&0xFF,(int>>16)&0xFF,(int>>8)&0xFF,int&0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB,red:Double(r)/255,green:Double(g)/255,blue:Double(b)/255,opacity:Double(a)/255)
    }
}

// MARK: - Onboarding

// Data model for each onboarding page
struct OnboardingPage {
    let id: Int
    let accentColor: Color
    let accentSecondary: Color
    let iconName: String
    let headline: String
    let subheadline: String
    let bodyText: String
    let demoLines: [DemoLine]
}

struct DemoLine: Identifiable {
    let id = UUID()
    let text: String
    let hasIssue: Bool
    let issueColor: Color
    let corrected: String
}

// MARK: - Onboarding Root

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating: Bool = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            accentColor: Color(hex: "#4F8EF7"),
            accentSecondary: Color(hex: "#A78BFA"),
            iconName: "text.magnifyingglass",
            headline: "Catch every mistake",
            subheadline: "8 layers of intelligent checks",
            bodyText: "From spelling slip-ups to passive voice, GrammarCheck scans your writing in real time — no button to press, no waiting.",
            demoLines: [
                DemoLine(text: "She don't know the answer.", hasIssue: true, issueColor: Color(hex: "#F87171"), corrected: "She doesn't know the answer."),
                DemoLine(text: "The report was submitted by the team.", hasIssue: true, issueColor: Color(hex: "#FB923C"), corrected: "The team submitted the report."),
                DemoLine(text: "The meeting starts at 9 AM.", hasIssue: false, issueColor: .clear, corrected: "")
            ]
        ),
        OnboardingPage(
            id: 1,
            accentColor: Color(hex: "#34D399"),
            accentSecondary: Color(hex: "#6EE7B7"),
            iconName: "wand.and.stars",
            headline: "Fix with one tap",
            subheadline: "Accept, dismiss, or fix all at once",
            bodyText: "Tap any underlined word to see a full explanation and a smart suggestion. Hit 'Fix all' to apply every correction instantly.",
            demoLines: [
                DemoLine(text: "in order to save time", hasIssue: true, issueColor: Color(hex: "#FBBF24"), corrected: "to save time"),
                DemoLine(text: "advance planning is key", hasIssue: true, issueColor: Color(hex: "#FBBF24"), corrected: "planning is key"),
                DemoLine(text: "The goal is clear.", hasIssue: false, issueColor: .clear, corrected: "")
            ]
        ),
        OnboardingPage(
            id: 2,
            accentColor: Color(hex: "#F472B6"),
            accentSecondary: Color(hex: "#E879F9"),
            iconName: "chart.bar.xaxis.ascending",
            headline: "Understand your writing",
            subheadline: "Readability · Vocabulary · Pace",
            bodyText: "The Insights tab breaks down your text into a Flesch readability score, sentence quality, passive voice percentage, and a live word-frequency cloud.",
            demoLines: [
                DemoLine(text: "Readability  A+", hasIssue: false, issueColor: .clear, corrected: ""),
                DemoLine(text: "Avg sentence  14 words ✓", hasIssue: false, issueColor: .clear, corrected: ""),
                DemoLine(text: "Passive voice  4% ✓", hasIssue: false, issueColor: .clear, corrected: "")
            ]
        ),
        OnboardingPage(
            id: 3,
            accentColor: Color(hex: "#FBBF24"),
            accentSecondary: Color(hex: "#FCD34D"),
            iconName: "slider.horizontal.3",
            headline: "Tuned to your voice",
            subheadline: "Professional · Academic · Creative · Casual",
            bodyText: "Choose your writing tone in Settings to tailor every suggestion to your context. Enable only the checks you care about — your setup, your rules.",
            demoLines: [
                DemoLine(text: "Professional mode active", hasIssue: false, issueColor: .clear, corrected: ""),
                DemoLine(text: "Style checks  ON", hasIssue: false, issueColor: .clear, corrected: ""),
                DemoLine(text: "Passive voice  ON", hasIssue: false, issueColor: .clear, corrected: "")
            ]
        )
    ]

    var body: some View {
        ZStack {
            // Background — this is the only layer allowed to bleed under the
            // status bar / home indicator. Content below stays safely inset,
            // which is what was missing before (text was stretching under the
            // notch/edges instead of wrapping inside the screen's safe area).
            OnboardingBackground(pageIndex: currentPage, accent: pages[currentPage].accentColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        advanceToEnd()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(pages[currentPage].accentColor.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .opacity(currentPage < pages.count - 1 ? 1 : 0)

                Spacer()

                // Page content — TabView(.page) cannot be trusted to size its own
                // pages consistently across size classes: on iPhone it was falling
                // back to each page's *ideal* (single-line, unwrapped) width instead
                // of the space it was actually given, which is why body text rendered
                // as one long line and got sheared off at both screen edges. The fix
                // is to stop depending on TabView's internal sizing altogether: we
                // measure the real available width once, right here, and hand that
                // fixed number straight to each page so it can force its own layout
                // regardless of whatever TabView does internally.
                GeometryReader { geo in

                    HStack(spacing: 0) {

                        ForEach(pages, id: \.id) { page in

                            OnboardingPageView(
                                page: page,
                                isActive: currentPage == page.id,
                                pageWidth: geo.size.width
                            )
                            .frame(width: geo.size.width)
                        }

                    }
                    .offset(x: -CGFloat(currentPage) * geo.size.width)
                    .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentPage)
                    .clipped()
                }

                Spacer()

                // Bottom controls
                VStack(spacing: 24) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            OnboardingDot(isActive: i == currentPage, color: pages[i].accentColor)
                        }
                    }

                    // CTA button
                    Button(action: handleCTA) {
                        OnboardingCTAButton(
                            label: currentPage < pages.count - 1 ? "Continue" : "Start writing",
                            color: pages[currentPage].accentColor,
                            isLast: currentPage == pages.count - 1
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 52)
            }
        }
    }

    private func handleCTA() {
        if currentPage < pages.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                currentPage += 1
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onFinish()
        }
    }

    private func advanceToEnd() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
            currentPage = pages.count - 1
        }
    }
}

// MARK: - Onboarding Background

struct OnboardingBackground: View {
    let pageIndex: Int
    let accent: Color

    var body: some View {
        ZStack {
            Color(hex: "#07101E").ignoresSafeArea()

            // Shifting aurora blob
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.28), .clear],
                        center: .center, startRadius: 0, endRadius: 260
                    )
                )
                .frame(width: 520, height: 420)
                .offset(x: auroraOffset(for: pageIndex).x, y: auroraOffset(for: pageIndex).y)
                .blur(radius: 60)
                .animation(.spring(response: 1.1, dampingFraction: 0.75), value: pageIndex)

            // Secondary aurora
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [accent.opacity(0.12), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 340, height: 280)
                .offset(x: -auroraOffset(for: pageIndex).x * 0.6, y: auroraOffset(for: pageIndex).y * 0.4 + 200)
                .blur(radius: 50)
                .animation(.spring(response: 1.3, dampingFraction: 0.7), value: pageIndex)

            // Fine dot grid
            GeometryReader { geo in
                Canvas { ctx, size in
                    let spacing: CGFloat = 28
                    let cols = Int(size.width / spacing) + 1
                    let rows = Int(size.height / spacing) + 1
                    for col in 0...cols {
                        for row in 0...rows {
                            let x = CGFloat(col) * spacing
                            let y = CGFloat(row) * spacing
                            ctx.fill(
                                Path(ellipseIn: CGRect(x: x-1, y: y-1, width: 2, height: 2)),
                                with: .color(.white.opacity(0.035))
                            )
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private func auroraOffset(for index: Int) -> CGPoint {
        switch index {
        case 0: return CGPoint(x: 80,  y: -280)
        case 1: return CGPoint(x: -90, y: -220)
        case 2: return CGPoint(x: 60,  y: -300)
        case 3: return CGPoint(x: -70, y: -240)
        default: return .zero
        }
    }
}

// MARK: - Single Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let pageWidth: CGFloat

    @State private var iconAppeared    = false
    @State private var headlineShown   = false
    @State private var bodyShown       = false
    @State private var demoShown       = false
    @State private var demoCorrections = [UUID: Bool]()
    @State private var ringPulse       = false

    private var contentMaxWidth: CGFloat {
        max(0, min(pageWidth - 48, 320))
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 20)

            // ── Icon cluster ──
            ZStack {
                // Pulsing outer ring
                Circle()
                    .stroke(page.accentColor.opacity(ringPulse ? 0.0 : 0.22), lineWidth: 1)
                    .frame(width: ringPulse ? 160 : 100, height: ringPulse ? 160 : 100)
                    .animation(
                        .easeOut(duration: 1.4).repeatForever(autoreverses: false),
                        value: ringPulse
                    )

                // Inner ring
                Circle()
                    .stroke(page.accentColor.opacity(0.18), lineWidth: 1)
                    .frame(width: 90, height: 90)

                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [page.accentColor.opacity(0.3), .clear],
                            center: .center, startRadius: 0, endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)

                // Icon card
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                page.accentColor.opacity(0.2),
                                page.accentSecondary.opacity(0.08)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(page.accentColor.opacity(0.35), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: page.iconName)
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [page.accentColor, page.accentSecondary],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            .scaleEffect(iconAppeared ? 1 : 0.5)
            .opacity(iconAppeared ? 1 : 0)
            .padding(.bottom, 36)

            // ── Headline + body copy ──
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    Text(page.headline)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: contentMaxWidth)

                    Text(page.subheadline)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(page.accentColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(page.accentColor.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(page.accentColor.opacity(0.25))
                        )
                }
                .frame(maxWidth: contentMaxWidth)

                Text(page.bodyText)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "#8BA3CC"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: contentMaxWidth)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: contentMaxWidth)
            .opacity(headlineShown ? 1 : 0)
            .offset(y: headlineShown ? 0 : 20)
            .padding(.bottom, 32)
            // ── Demo card ──
            OnboardingDemoCard(
                page: page,
                isVisible: demoShown,
                corrections: $demoCorrections
            )
            .frame(width: max(0, pageWidth - 56))

            Spacer()
        }
        .frame(width: pageWidth)
        // Belt-and-suspenders: no child (headline, body copy, demo card) can
        // render past this page's own bounds, so text can never spill past
        // the left/right edges of the screen even under animation.
        .clipped()
        .onChange(of: isActive) { _, active in
            if active { runEntrance() }
            else { resetState() }
        }
        .onAppear {
            if isActive { runEntrance() }
        }
    }

    private func runEntrance() {
        iconAppeared  = false
        headlineShown = false
        bodyShown     = false
        demoShown     = false
        ringPulse     = false
        demoCorrections = [:]

        withAnimation(.spring(response: 0.55, dampingFraction: 0.58).delay(0.05)) {
            iconAppeared = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            ringPulse = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.22)) {
            headlineShown = true
        }
        withAnimation(.easeOut(duration: 0.45).delay(0.38)) {
            bodyShown = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.52)) {
            demoShown = true
        }
        // Auto-demonstrate corrections
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            animateCorrections()
        }
    }

    private func animateCorrections() {
        let fixable = page.demoLines.filter { $0.hasIssue }
        for (i, line) in fixable.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.55) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    demoCorrections[line.id] = true
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                // Revert after 2s to loop
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        demoCorrections[line.id] = false
                    }
                }
            }
        }
    }

    private func resetState() {
        iconAppeared  = false
        headlineShown = false
        bodyShown     = false
        demoShown     = false
    }
}

// MARK: - Demo Card

struct OnboardingDemoCard: View {
    let page: OnboardingPage
    let isVisible: Bool
    @Binding var corrections: [UUID: Bool]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card title bar
            HStack(spacing: 8) {
                Circle().fill(Color(hex: "#FF5F56")).frame(width: 10, height: 10)
                Circle().fill(Color(hex: "#FFBD2E")).frame(width: 10, height: 10)
                Circle().fill(Color(hex: "#27C93F")).frame(width: 10, height: 10)
                Spacer()
                Text("editor")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color(hex: "#4A6480"))
                Spacer()
                Image(systemName: "pencil")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "#4A6480"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(hex: "#0D1B2A"))

            Divider().background(Color(hex: "#1A2D44"))

            // Lines
            VStack(alignment: .leading, spacing: 12) {
                ForEach(page.demoLines) { line in
                    DemoLineView(
                        line: line,
                        accentColor: page.accentColor,
                        isCorrected: corrections[line.id] ?? false
                    )
                }
            }
            .padding(16)
            .background(Color(hex: "#0A1628"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(page.accentColor.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: page.accentColor.opacity(0.15), radius: 20, x: 0, y: 8)
        .scaleEffect(isVisible ? 1 : 0.88)
        .opacity(isVisible ? 1 : 0)
    }
}

// MARK: - Demo Line

struct DemoLineView: View {
    let line: DemoLine
    let accentColor: Color
    let isCorrected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Status dot
            Circle()
                .fill(
                    line.hasIssue
                        ? (isCorrected ? Color(hex: "#34D399") : line.issueColor)
                        : Color(hex: "#34D399").opacity(0.6)
                )
                .frame(width: 6, height: 6)
                .animation(.easeInOut(duration: 0.25), value: isCorrected)

            if line.hasIssue && isCorrected && !line.corrected.isEmpty {
                // Corrected text with checkmark badge
                HStack(spacing: 6) {
                    Text(line.corrected)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color(hex: "#34D399"))
                        .strikethrough(false)
                        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .leading)))

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "#34D399"))
                        .transition(.scale.combined(with: .opacity))
                }
            } else {
                // Original text, possibly underlined
                ZStack(alignment: .bottomLeading) {
                    Text(line.text)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(line.hasIssue ? Color(hex: "#CBD5E1") : Color(hex: "#64748B"))

                    if line.hasIssue && !isCorrected {
                        // Animated wavy underline
                        WavyUnderline(color: line.issueColor)
                            .offset(y: 3)
                    }
                }
                .transition(.opacity)
            }

            Spacer()
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.72), value: isCorrected)
        .frame(minHeight: 22)
    }
}

// MARK: - Wavy Underline

struct WavyUnderline: View {
    let color: Color
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { ctx, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    var path = Path()
                    let amplitude: CGFloat = 1.8
                    let wavelength: CGFloat = 8
                    let speed: CGFloat = 20
                    path.move(to: CGPoint(x: 0, y: amplitude))
                    for x in stride(from: 0, through: size.width, by: 1) {
                        let y = amplitude * sin((x / wavelength + CGFloat(t) * speed * 0.05) * 2 * .pi / wavelength)
                        path.addLine(to: CGPoint(x: x, y: amplitude + y))
                    }
                    ctx.stroke(path, with: .color(color), lineWidth: 1.5)
                }
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Page Dot

struct OnboardingDot: View {
    let isActive: Bool
    let color: Color

    var body: some View {
        Capsule()
            .fill(isActive ? color : Color(hex: "#1E3A5F"))
            .frame(width: isActive ? 24 : 7, height: 7)
            .animation(.spring(response: 0.4, dampingFraction: 0.72), value: isActive)
            .overlay(
                Capsule()
                    .stroke(isActive ? color.opacity(0.4) : .clear, lineWidth: 0.5)
            )
    }
}

// MARK: - CTA Button

struct OnboardingCTAButton: View {
    let label: String
    let color: Color
    let isLast: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
            Image(systemName: isLast ? "checkmark" : "arrow.right")
                .font(.system(size: 15, weight: .semibold))
        }
        .foregroundStyle(Color(hex: "#07101E"))
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            ZStack {
                color
                LinearGradient(
                    colors: [.white.opacity(0.18), .clear, .white.opacity(0.06)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 999, style: .continuous))
        .shadow(color: color.opacity(0.45), radius: 18, x: 0, y: 8)
    }
}

// MARK: - Models



enum IssueType: String, CaseIterable {
    case grammar      = "Grammar"
    case spelling     = "Spelling"
    case punctuation  = "Punctuation"
    case style        = "Style"
    case clarity      = "Clarity"
    case wordChoice   = "Word Choice"
    case passive      = "Passive Voice"
    case redundancy   = "Redundancy"

    var color: Color {
        switch self {
        case .grammar:     return .red
        case .spelling:    return .orange
        case .punctuation: return .yellow
        case .style:       return .blue
        case .clarity:     return .purple
        case .wordChoice:  return .teal
        case .passive:     return .indigo
        case .redundancy:  return .pink
        }
    }

    var icon: String {
        switch self {
        case .grammar:     return "exclamationmark.triangle"
        case .spelling:    return "textformat.abc"
        case .punctuation: return "ellipsis"
        case .style:       return "paintbrush"
        case .clarity:     return "magnifyingglass"
        case .wordChoice:  return "text.word.spacing"
        case .passive:     return "arrow.left.arrow.right"
        case .redundancy:  return "arrow.2.circlepath"
        }
    }
}

enum WritingTone: String, CaseIterable {
    case professional = "Professional"
    case academic     = "Academic"
    case casual       = "Casual"
    case creative     = "Creative"
    case business     = "Business"

    var description: String {
        switch self {
        case .professional: return "Clear, formal, workplace-ready"
        case .academic:     return "Scholarly, precise, citation-aware"
        case .casual:       return "Friendly, relaxed, conversational"
        case .creative:     return "Expressive, vivid, flexible"
        case .business:     return "Concise, action-oriented, results-focused"
        }
    }
}

struct GrammarIssue: Identifiable {
    let id = UUID()
    let type: IssueType
    let range: Range<String.Index>
    let original: String
    let suggestion: String
    let explanation: String
    var isDismissed: Bool = false

    var displayRange: NSRange
}

struct TextStats {
    var wordCount: Int = 0
    var charCount: Int = 0
    var sentenceCount: Int = 0
    var paragraphCount: Int = 0
    var readabilityScore: Double = 0.0
    var readingTimeSeconds: Int = 0
    var avgWordsPerSentence: Double = 0.0
    var uniqueWordRatio: Double = 0.0
    var passiveVoicePercent: Double = 0.0
    var issueCount: Int = 0

    var readabilityLabel: String {
        switch readabilityScore {
        case 90...100: return "Very Easy"
        case 80..<90:  return "Easy"
        case 70..<80:  return "Fairly Easy"
        case 60..<70:  return "Standard"
        case 50..<60:  return "Fairly Difficult"
        case 30..<50:  return "Difficult"
        default:       return "Very Difficult"
        }
    }

    var readingTime: String {
        if readingTimeSeconds < 60 {
            return "\(readingTimeSeconds)s read"
        }
        return "\(readingTimeSeconds / 60)m read"
    }

    var scoreGrade: String {
        switch readabilityScore {
        case 90...100: return "A+"
        case 80..<90:  return "A"
        case 70..<80:  return "B"
        case 60..<70:  return "C"
        case 50..<60:  return "D"
        default:       return "F"
        }
    }

    var scoreColor: Color {
        switch readabilityScore {
        case 70...100: return .green
        case 50..<70:  return .orange
        default:       return .red
        }
    }
}

struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    let text: String
    let date: Date
    let issueCount: Int
    let wordCount: Int
    var title: String

    init(text: String, issueCount: Int, wordCount: Int) {
        self.id = UUID()
        self.text = text
        self.date = Date()
        self.issueCount = issueCount
        self.wordCount = wordCount
        self.title = text.components(separatedBy: .newlines).first
            .map { String($0.prefix(50)) } ?? "Untitled"
    }
}

struct WordFrequency: Identifiable {
    let id = UUID()
    let word: String
    let count: Int
}

// MARK: - Settings Store

class SettingsStore: ObservableObject {
    @AppStorage("enableGrammar")       var enableGrammar: Bool       = true
    @AppStorage("enableSpelling")      var enableSpelling: Bool      = true
    @AppStorage("enablePunctuation")   var enablePunctuation: Bool   = true
    @AppStorage("enableStyle")         var enableStyle: Bool         = true
    @AppStorage("enableClarity")       var enableClarity: Bool       = true
    @AppStorage("enableWordChoice")    var enableWordChoice: Bool    = true
    @AppStorage("enablePassive")       var enablePassive: Bool       = true
    @AppStorage("enableRedundancy")    var enableRedundancy: Bool    = true
    @AppStorage("checkAsYouType")      var checkAsYouType: Bool      = true
    @AppStorage("autoCorrect")         var autoCorrect: Bool         = false
    @AppStorage("showReadability")     var showReadability: Bool     = true
    @AppStorage("writingTone")         var writingToneRaw: String    = WritingTone.professional.rawValue
    @AppStorage("appearanceMode")      var appearanceMode: String    = "system"
    @AppStorage("highlightColor")      var highlightColorRaw: String = "yellow"
    @AppStorage("fontSize")            var fontSize: Double          = 16.0
    @AppStorage("hapticFeedback")      var hapticFeedback: Bool      = true

    var writingTone: WritingTone {
        get { WritingTone(rawValue: writingToneRaw) ?? .professional }
        set { writingToneRaw = newValue.rawValue }
    }

    var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    var enabledTypes: Set<IssueType> {
        var types = Set<IssueType>()
        if enableGrammar     { types.insert(.grammar) }
        if enableSpelling    { types.insert(.spelling) }
        if enablePunctuation { types.insert(.punctuation) }
        if enableStyle       { types.insert(.style) }
        if enableClarity     { types.insert(.clarity) }
        if enableWordChoice  { types.insert(.wordChoice) }
        if enablePassive     { types.insert(.passive) }
        if enableRedundancy  { types.insert(.redundancy) }
        return types
    }

    func toggle(_ type: IssueType) {
        switch type {
        case .grammar:     enableGrammar     = !enableGrammar
        case .spelling:    enableSpelling    = !enableSpelling
        case .punctuation: enablePunctuation = !enablePunctuation
        case .style:       enableStyle       = !enableStyle
        case .clarity:     enableClarity     = !enableClarity
        case .wordChoice:  enableWordChoice  = !enableWordChoice
        case .passive:     enablePassive     = !enablePassive
        case .redundancy:  enableRedundancy  = !enableRedundancy
        }
    }

    func isEnabled(_ type: IssueType) -> Bool {
        enabledTypes.contains(type)
    }
}

// MARK: - Grammar Engine

class GrammarEngine: ObservableObject {
    @Published var issues: [GrammarIssue] = []
    @Published var stats: TextStats = TextStats()
    @Published var isAnalyzing: Bool = false
    @Published var wordFrequencies: [WordFrequency] = []

    private var analysisTask: Task<Void, Never>?
    private let checker = UITextChecker()

    // Passive voice patterns
    private let passivePatterns: [(String, String)] = [
        ("was \\w+ed by", "Consider using active voice"),
        ("were \\w+ed by", "Consider using active voice"),
        ("is being \\w+ed", "Consider using active voice"),
        ("has been \\w+ed", "Consider using active voice"),
        ("had been \\w+ed", "Consider using active voice"),
        ("will be \\w+ed", "Consider using active voice"),
        ("being \\w+ed", "Consider using active voice")
    ]

    // Redundant phrases
    private let redundantPhrases: [(original: String, suggestion: String, explanation: String)] = [
        ("at this point in time", "now", "\"At this point in time\" is redundant — use \"now\""),
        ("due to the fact that", "because", "Replace the wordy phrase with \"because\""),
        ("in the event that", "if", "Simplify to \"if\""),
        ("in spite of the fact that", "although", "Use \"although\" instead"),
        ("on account of", "because", "Replace with \"because\""),
        ("as a matter of fact", "", "This phrase is usually unnecessary — remove it"),
        ("for the purpose of", "to", "Simplify to \"to\""),
        ("in order to", "to", "Drop \"in order\" — \"to\" is enough"),
        ("each and every", "each", "Remove \"and every\" — it's redundant"),
        ("first and foremost", "first", "Use \"first\" only"),
        ("in close proximity to", "near", "Replace with \"near\""),
        ("at the present time", "now", "Use \"now\""),
        ("during the course of", "during", "Simplify to \"during\""),
        ("for the reason that", "because", "Use \"because\""),
        ("in the near future", "soon", "Use \"soon\""),
        ("completely finished", "finished", "\"Finished\" already implies completeness"),
        ("end result", "result", "\"Result\" already implies an end"),
        ("completely unique", "unique", "\"Unique\" means one-of-a-kind — it can't be modified"),
        ("basic fundamentals", "fundamentals", "\"Fundamentals\" are by definition basic"),
        ("added bonus", "bonus", "\"Bonus\" already implies an addition"),
        ("advance planning", "planning", "All planning happens in advance"),
        ("personal opinion", "opinion", "Opinions are by definition personal"),
        ("future plans", "plans", "Plans are always about the future"),
        ("unexpected surprise", "surprise", "A surprise is always unexpected"),
        ("brief moment", "moment", "A moment is already brief")
    ]

    // Weak/vague word suggestions
    private let wordChoiceImprovements: [(original: String, suggestion: String, explanation: String)] = [
        ("very good", "excellent", "Replace vague intensifier with a precise word"),
        ("very bad", "terrible", "Replace vague intensifier with a precise word"),
        ("very big", "enormous", "Replace vague intensifier with a precise word"),
        ("very small", "tiny", "Replace vague intensifier with a precise word"),
        ("very fast", "rapid", "Replace vague intensifier with a precise word"),
        ("very slow", "sluggish", "Replace vague intensifier with a precise word"),
        ("very happy", "elated", "Replace vague intensifier with a precise word"),
        ("very sad", "devastated", "Replace vague intensifier with a precise word"),
        ("very tired", "exhausted", "Replace vague intensifier with a precise word"),
        ("very angry", "furious", "Replace vague intensifier with a precise word"),
        ("very surprised", "astonished", "Replace vague intensifier with a precise word"),
        ("a lot of", "many", "Use a more precise quantifier"),
        ("lots of", "numerous", "Use a more precise quantifier"),
        ("kind of", "somewhat", "Replace casual filler with a precise adverb"),
        ("sort of", "somewhat", "Replace casual filler with a precise adverb"),
        ("basically", "essentially", "Replace casual filler with a precise adverb"),
        ("literally", "", "Check if this is being used correctly — remove if figurative"),
        ("utilize", "use", "\"Use\" is simpler and clearer"),
        ("commence", "begin", "\"Begin\" is clearer"),
        ("terminate", "end", "\"End\" is clearer"),
        ("facilitate", "help", "\"Help\" is clearer"),
        ("endeavor", "try", "\"Try\" is clearer"),
        ("purchase", "buy", "\"Buy\" is clearer in most contexts"),
        ("obtain", "get", "\"Get\" is clearer in most contexts"),
        ("approximately", "about", "\"About\" is clearer and shorter"),
        ("numerous", "many", "\"Many\" is simpler"),
        ("sufficient", "enough", "\"Enough\" is clearer")
    ]

    // Grammar rules
    private let grammarRules: [(pattern: String, explanation: String, exampleFix: (String) -> String)] = [
        ("\\bI are\\b", "\"I\" takes \"am\", not \"are\"", { _ in "I am" }),
        ("\\bhe don't\\b", "\"He\" takes \"doesn't\"", { _ in "he doesn't" }),
        ("\\bshe don't\\b", "\"She\" takes \"doesn't\"", { _ in "she doesn't" }),
        ("\\bit don't\\b", "\"It\" takes \"doesn't\"", { _ in "it doesn't" }),
        ("\\bthey was\\b", "\"They\" takes \"were\"", { _ in "they were" }),
        ("\\bwe was\\b", "\"We\" takes \"were\"", { _ in "we were" }),
        ("\\byou was\\b", "\"You\" takes \"were\"", { _ in "you were" }),
        ("\\bI has\\b", "\"I\" takes \"have\"", { _ in "I have" }),
        ("\\bhe have\\b", "\"He\" takes \"has\"", { _ in "he has" }),
        ("\\bshe have\\b", "\"She\" takes \"has\"", { _ in "she has" }),
        ("\\bit have\\b", "\"It\" takes \"has\"", { _ in "it has" }),
        ("\\ba [aeiou]\\w+", "Use \"an\" before vowel sounds", { w in w.replacingOccurrences(of: "a ", with: "an ", range: w.range(of: "a ")) }),
        ("\\bto\\s+to\\b", "Duplicate word detected", { _ in "to" }),
        ("\\bthe\\s+the\\b", "Duplicate word detected", { _ in "the" }),
        ("\\bof\\s+of\\b", "Duplicate word detected", { _ in "of" }),
        ("\\band\\s+and\\b", "Duplicate word detected", { _ in "and" }),
        ("\\bwho\\s+which\\b", "Use \"who\" for people, \"which\" for things", { _ in "who" }),
        ("\\bthen\\b(?=.{0,20}\\bcompare)", "Use \"than\" for comparisons", { _ in "than" }),
        ("\\bless\\b(?=.{0,10}\\b(people|students|users|items|things)\\b)", "Use \"fewer\" for countable nouns", { _ in "fewer" }),
        ("\\bgood\\b(?=.{0,5}\\b(at|in|with)\\b)", "Consider \"well\" as an adverb here", { _ in "well" })
    ]

    // Punctuation issues
    private let punctuationRules: [(pattern: String, suggestion: String, explanation: String)] = [
        (",but", ", but", "Add a space after the comma"),
        (",and", ", and", "Add a space after the comma"),
        (",or", ", or", "Add a space after the comma"),
        ("  +", " ", "Multiple spaces detected"),
        ("\\.\\.(?!\\.)", "...", "Two periods used — use ellipsis (…) or three periods (...)"),
        ("!!", "!", "Multiple exclamation marks — use one"),
        ("\\?\\?", "?", "Multiple question marks — use one"),
        (",\\.", ".", "Remove the comma before the period")
    ]

    // Common style suggestions for tone
    private let styleRules: [(pattern: String, suggestion: String, explanation: String)] = [
        ("\\bI think\\b", "Consider omitting", "Starting with \"I think\" weakens the statement — state it confidently"),
        ("\\bI believe\\b", "Consider omitting", "\"I believe\" can weaken your point — assert it directly"),
        ("\\bI feel like\\b", "Consider removing", "\"I feel like\" is casual and weakens arguments in formal writing"),
        ("\\bmaybe\\b", "consider", "\"Maybe\" sounds uncertain — use \"consider\" or \"perhaps\" for formal tone"),
        ("\\bperhaps\\b", "", "Note: \"perhaps\" is fine in formal writing but check context"),
        ("\\bstuff\\b", "items", "\"Stuff\" is informal — use \"items\" or a specific noun"),
        ("\\bthings\\b", "factors", "\"Things\" is vague — use a specific noun"),
        ("\\bguy\\b", "person", "\"Guy\" is informal — use \"person\" in formal writing"),
        ("\\bkinda\\b", "somewhat", "Informal contraction — spell out \"kind of\" or use \"somewhat\""),
        ("\\bgonna\\b", "going to", "Informal — use \"going to\""),
        ("\\bwanna\\b", "want to", "Informal — use \"want to\""),
        ("\\bgotta\\b", "have to", "Informal — use \"have to\""),
        ("\\bcoz\\b", "because", "Informal — spell out \"because\""),
        ("\\bcause\\b(?! of)", "because", "Use \"because\" rather than \"cause\" in formal writing")
    ]

    func analyze(text: String, settings: SettingsStore) {
        analysisTask?.cancel()
        analysisTask = Task { @MainActor in
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                self.issues = []
                self.stats = TextStats()
                self.wordFrequencies = []
                self.isAnalyzing = false
                return
            }

            self.isAnalyzing = true

            // Small delay to debounce
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }

            var foundIssues: [GrammarIssue] = []

            // Spelling check via UITextChecker
            if settings.enableSpelling {
                foundIssues += self.checkSpelling(in: text)
            }

            // Redundant phrases
            if settings.enableRedundancy {
                foundIssues += self.checkRedundancy(in: text)
            }

            // Word choice improvements
            if settings.enableWordChoice {
                foundIssues += self.checkWordChoice(in: text)
            }

            // Grammar rules
            if settings.enableGrammar {
                foundIssues += self.checkGrammar(in: text)
            }

            // Punctuation
            if settings.enablePunctuation {
                foundIssues += self.checkPunctuation(in: text)
            }

            // Style
            if settings.enableStyle {
                foundIssues += self.checkStyle(in: text)
            }

            // Passive voice
            if settings.enablePassive {
                foundIssues += self.checkPassiveVoice(in: text)
            }

            // Clarity (sentence length, complexity)
            if settings.enableClarity {
                foundIssues += self.checkClarity(in: text)
            }

            // Remove overlapping issues, prefer higher-priority ones
            let deduped = self.deduplicateIssues(foundIssues)

            self.issues = deduped
            self.stats = self.computeStats(for: text, issues: deduped)
            self.wordFrequencies = self.computeWordFrequencies(for: text)
            self.isAnalyzing = false
        }
    }

    private func checkSpelling(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []
        let nsText = text as NSString
        var offset = 0

        while offset < text.count {
            let range = NSRange(location: offset, length: text.count - offset)
            let misspelledRange = checker.rangeOfMisspelledWord(
                in: text, range: range, startingAt: offset,
                wrap: false, language: "en"
            )
            guard misspelledRange.location != NSNotFound else { break }

            let misspelled = nsText.substring(with: misspelledRange)
            let guesses = checker.guesses(forWordRange: misspelledRange, in: text, language: "en") ?? []
            let suggestion = guesses.first ?? ""

            if let swiftRange = Range(misspelledRange, in: text) {
                results.append(GrammarIssue(
                    type: .spelling,
                    range: swiftRange,
                    original: misspelled,
                    suggestion: suggestion,
                    explanation: suggestion.isEmpty
                        ? "Possible misspelling detected"
                        : "Possible misspelling — did you mean \"\(suggestion)\"?",
                    isDismissed: false,
                    displayRange: misspelledRange
                ))
            }
            offset = misspelledRange.location + misspelledRange.length
        }
        return results
    }

    private func checkRedundancy(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []
        let lower = text.lowercased()

        for rule in redundantPhrases {
            var searchRange = lower.startIndex..<lower.endIndex
            while let range = lower.range(of: rule.original, options: .caseInsensitive, range: searchRange) {
                let nsRange = NSRange(range, in: text)
                results.append(GrammarIssue(
                    type: .redundancy,
                    range: range,
                    original: String(text[range]),
                    suggestion: rule.suggestion,
                    explanation: rule.explanation,
                    isDismissed: false,
                    displayRange: nsRange
                ))
                searchRange = range.upperBound..<lower.endIndex
            }
        }
        return results
    }

    private func checkWordChoice(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []

        for rule in wordChoiceImprovements {
            var searchRange = text.startIndex..<text.endIndex
            while let range = text.range(of: rule.original, options: [.caseInsensitive], range: searchRange) {
                // Word boundary check
                let before = range.lowerBound > text.startIndex ? text[text.index(before: range.lowerBound)] : " "
                let after  = range.upperBound < text.endIndex   ? text[range.upperBound] : " "
                if (before.isWhitespace || before.isPunctuation) &&
                   (after.isWhitespace  || after.isPunctuation  || range.upperBound == text.endIndex) {
                    let nsRange = NSRange(range, in: text)
                    results.append(GrammarIssue(
                        type: .wordChoice,
                        range: range,
                        original: String(text[range]),
                        suggestion: rule.suggestion,
                        explanation: rule.explanation,
                        isDismissed: false,
                        displayRange: nsRange
                    ))
                }
                searchRange = range.upperBound..<text.endIndex
            }
        }
        return results
    }

    private func checkGrammar(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []

        for rule in grammarRules {
            guard let regex = try? NSRegularExpression(pattern: rule.pattern, options: [.caseInsensitive]) else { continue }
            let nsText = text as NSString
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            for match in matches {
                let nsRange = match.range
                guard let swiftRange = Range(nsRange, in: text) else { continue }
                let original = nsText.substring(with: nsRange)
                let suggestion = rule.exampleFix(original)

                results.append(GrammarIssue(
                    type: .grammar,
                    range: swiftRange,
                    original: original,
                    suggestion: suggestion,
                    explanation: rule.explanation,
                    isDismissed: false,
                    displayRange: nsRange
                ))
            }
        }
        return results
    }

    private func checkPunctuation(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []

        for rule in punctuationRules {
            guard let regex = try? NSRegularExpression(pattern: rule.pattern) else { continue }
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            for match in matches {
                let nsRange = match.range
                guard let swiftRange = Range(nsRange, in: text) else { continue }
                let original = String(text[swiftRange])

                results.append(GrammarIssue(
                    type: .punctuation,
                    range: swiftRange,
                    original: original,
                    suggestion: rule.suggestion,
                    explanation: rule.explanation,
                    isDismissed: false,
                    displayRange: nsRange
                ))
            }
        }
        return results
    }

    private func checkStyle(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []

        for rule in styleRules {
            guard let regex = try? NSRegularExpression(pattern: rule.pattern, options: [.caseInsensitive]) else { continue }
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            for match in matches {
                let nsRange = match.range
                guard let swiftRange = Range(nsRange, in: text) else { continue }
                let original = String(text[swiftRange])

                results.append(GrammarIssue(
                    type: .style,
                    range: swiftRange,
                    original: original,
                    suggestion: rule.suggestion,
                    explanation: rule.explanation,
                    isDismissed: false,
                    displayRange: nsRange
                ))
            }
        }
        return results
    }

    private func checkPassiveVoice(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []

        for (pattern, explanation) in passivePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

            for match in matches {
                let nsRange = match.range
                guard let swiftRange = Range(nsRange, in: text) else { continue }
                let original = String(text[swiftRange])

                results.append(GrammarIssue(
                    type: .passive,
                    range: swiftRange,
                    original: original,
                    suggestion: "",
                    explanation: explanation,
                    isDismissed: false,
                    displayRange: nsRange
                ))
            }
        }
        return results
    }

    private func checkClarity(in text: String) -> [GrammarIssue] {
        var results: [GrammarIssue] = []
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text

        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let sentence = String(text[range])
            let words = sentence.components(separatedBy: .whitespaces).filter { !$0.isEmpty }

            if words.count > 35 {
                let nsRange = NSRange(range, in: text)
                results.append(GrammarIssue(
                    type: .clarity,
                    range: range,
                    original: sentence,
                    suggestion: "",
                    explanation: "This sentence has \(words.count) words — consider breaking it into shorter sentences for clarity",
                    isDismissed: false,
                    displayRange: nsRange
                ))
            }
            return true
        }
        return results
    }

    private func deduplicateIssues(_ issues: [GrammarIssue]) -> [GrammarIssue] {
        var result: [GrammarIssue] = []
        for issue in issues {
            let overlaps = result.contains { existing in
                let a = existing.displayRange
                let b = issue.displayRange
                return NSIntersectionRange(a, b).length > 0
            }
            if !overlaps {
                result.append(issue)
            }
        }
        return result
    }

    private func computeStats(for text: String, issues: [GrammarIssue]) -> TextStats {
        var stats = TextStats()

        let wordTokenizer = NLTokenizer(unit: .word)
        wordTokenizer.string = text
        var words: [String] = []
        wordTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            words.append(String(text[range]))
            return true
        }

        let sentenceTokenizer = NLTokenizer(unit: .sentence)
        sentenceTokenizer.string = text
        var sentenceCount = 0
        var syllableCount = 0
        sentenceTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            sentenceCount += 1
            let sentence = String(text[range])
            let sentWords = sentence.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            for word in sentWords {
                syllableCount += self.countSyllables(in: word)
            }
            return true
        }

        stats.wordCount      = words.count
        stats.charCount      = text.count
        stats.sentenceCount  = max(sentenceCount, 1)
        stats.paragraphCount = text.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count

        let avgSyllables = words.isEmpty ? 0.0 : Double(syllableCount) / Double(words.count)
        let avgWords     = Double(words.count) / Double(max(stats.sentenceCount, 1))
        stats.avgWordsPerSentence = avgWords

        // Flesch Reading Ease
        stats.readabilityScore = max(0, min(100,
            206.835 - (1.015 * avgWords) - (84.6 * avgSyllables)
        ))

        let uniqueWords = Set(words.map { $0.lowercased() })
        stats.uniqueWordRatio = words.isEmpty ? 0 : Double(uniqueWords.count) / Double(words.count)

        let passiveCount = issues.filter { $0.type == .passive }.count
        stats.passiveVoicePercent = stats.sentenceCount == 0 ? 0 :
            Double(passiveCount) / Double(stats.sentenceCount) * 100

        stats.readingTimeSeconds = max(1, words.count / 4) // ~240 wpm average
        stats.issueCount = issues.count

        return stats
    }

    private func countSyllables(in word: String) -> Int {
        let lower = word.lowercased()
        var count = 0
        var prevWasVowel = false
        let vowels: Set<Character> = ["a","e","i","o","u","y"]

        for char in lower {
            let isVowel = vowels.contains(char)
            if isVowel && !prevWasVowel { count += 1 }
            prevWasVowel = isVowel
        }
        if lower.hasSuffix("e") && count > 1 { count -= 1 }
        return max(1, count)
    }

    private func computeWordFrequencies(for text: String) -> [WordFrequency] {
        let stopWords: Set<String> = ["the","a","an","and","or","but","in","on","at","to","for",
                                       "of","with","by","from","is","was","are","were","be","been",
                                       "have","has","had","do","does","did","will","would","could",
                                       "should","may","might","shall","can","this","that","these",
                                       "those","i","you","he","she","it","we","they","not","no","as",
                                       "if","then","than","so","yet","nor","both","either","neither","such"]

        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        var freq: [String: Int] = [:]

        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let word = String(text[range]).lowercased()
            if word.count > 2 && !stopWords.contains(word) {
                freq[word, default: 0] += 1
            }
            return true
        }

        return freq
            .filter { $0.value > 1 }
            .sorted { $0.value > $1.value }
            .prefix(20)
            .map { WordFrequency(word: $0.key, count: $0.value) }
    }

    func applyFix(to text: inout String, issue: GrammarIssue) {
        guard !issue.suggestion.isEmpty else { return }
        text = text.replacingCharacters(in: issue.range, with: issue.suggestion)
    }

    func applyAllFixes(to text: inout String) {
        // Sort by location descending so ranges stay valid
        let sorted = issues.filter { !$0.suggestion.isEmpty && !$0.isDismissed }
            .sorted { $0.displayRange.location > $1.displayRange.location }

        for issue in sorted {
            if let range = Range(issue.displayRange, in: text) {
                text = text.replacingCharacters(in: range, with: issue.suggestion)
            }
        }
    }
}

// MARK: - History Store

class HistoryStore: ObservableObject {
    @Published var entries: [HistoryEntry] = []

    private let key = "grammarHistory"

    init() { load() }

    func save(_ text: String, issueCount: Int, wordCount: Int) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let entry = HistoryEntry(text: text, issueCount: issueCount, wordCount: wordCount)
        entries.insert(entry, at: 0)
        entries = Array(entries.prefix(50))
        persist()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        persist()
    }

    func clear() {
        entries.removeAll()
        persist()
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else { return }
        entries = decoded
    }
}

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject private var engine      = GrammarEngine()
    @StateObject private var history     = HistoryStore()
    @State private var inputText         = ""
    @State private var selectedTab: Tab  = .editor
    @State private var showSettings      = false
    @State private var selectedIssue: GrammarIssue? = nil
    @State private var showHistory       = false
    @State private var showShareSheet    = false
    @State private var showPaywall       = false
    @State private var debounceTimer: Timer? = nil

    enum Tab: String, CaseIterable {
        case editor   = "Editor"
        case insights = "Insights"
        case vocab    = "Vocabulary"

        var icon: String {
            switch self {
            case .editor:   return "square.and.pencil"
            case .insights: return "chart.bar.xaxis.ascending"
            case .vocab:    return "textformat.abc"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Score banner
                if !inputText.isEmpty {
                    ScoreBanner(stats: engine.stats, isAnalyzing: engine.isAnalyzing) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTab = .insights
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Tab bar
                PillTabBar(selection: $selectedTab)

                // Content
                switch selectedTab {
                case .editor:
                    EditorView(
                        inputText: $inputText,
                        issues: $engine.issues,
                        selectedIssue: $selectedIssue,
                        settings: settings,
                        engine: engine,
                        onTextChange: triggerAnalysis,
                        onApplyAll: applyAllFixes,
                        onSave: saveToHistory
                    )
                case .insights:
                    InsightsView(stats: engine.stats, issues: engine.issues)
                case .vocab:
                    VocabularyView(frequencies: engine.wordFrequencies)
                }
            }
            .navigationTitle("Grammar Check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showHistory = true } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !inputText.isEmpty {
                        Button { shareText() } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button { clearText() } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    Button { showSettings = true } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(settings)
                    .environmentObject(subscriptionManager)
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(history: history) { entry in
                    inputText = entry.text
                    showHistory = false
                    triggerAnalysis()
                }
            }
            .sheet(item: $selectedIssue) { issue in
                IssueDetailSheet(
                    issue: issue,
                    onAccept: { applyFix(for: issue) },
                    onDismiss: { dismissIssue(issue) }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(text: exportReport())
            }
            // ── Paywall: presented when a non-subscriber tries to type/paste text ──
            .sheet(isPresented: $showPaywall, onDismiss: {
                Task { await subscriptionManager.refresh() }
            }) {
                PaywallView()
            }
            .onChange(of: inputText) { _, newValue in
                guard !subscriptionManager.isSubscribed else { return }
                if !newValue.isEmpty {
                    // Block the keystroke/paste — non-subscribers can't populate the editor
                    inputText = ""
                    engine.issues = []
                    engine.stats  = TextStats()
                    engine.wordFrequencies = []
                    showPaywall = true
                }
            }
            .animation(.easeInOut(duration: 0.25), value: inputText.isEmpty)
        }
    }

    private func triggerAnalysis() {
        debounceTimer?.invalidate()
        if settings.checkAsYouType {
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
                engine.analyze(text: inputText, settings: settings)
            }
        }
    }

    private func applyAllFixes() {
        engine.applyAllFixes(to: &inputText)
        engine.analyze(text: inputText, settings: settings)
        if settings.hapticFeedback {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func applyFix(for issue: GrammarIssue) {
        engine.applyFix(to: &inputText, issue: issue)
        engine.analyze(text: inputText, settings: settings)
        selectedIssue = nil
        if settings.hapticFeedback {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func dismissIssue(_ issue: GrammarIssue) {
        if let idx = engine.issues.firstIndex(where: { $0.id == issue.id }) {
            engine.issues[idx].isDismissed = true
        }
        selectedIssue = nil
    }

    private func clearText() {
        if !inputText.isEmpty {
            saveToHistory()
        }
        inputText = ""
        engine.issues = []
        engine.stats  = TextStats()
        engine.wordFrequencies = []
    }

    private func saveToHistory() {
        history.save(inputText, issueCount: engine.stats.issueCount, wordCount: engine.stats.wordCount)
    }

    private func shareText() {
        showShareSheet = true
    }

    private func exportReport() -> String {
        var report = "Grammar Check Report\n"
        report += "====================\n\n"
        report += "Text:\n\(inputText)\n\n"
        report += "Stats:\n"
        report += "• Words: \(engine.stats.wordCount)\n"
        report += "• Sentences: \(engine.stats.sentenceCount)\n"
        report += "• Readability: \(engine.stats.readabilityLabel) (\(String(format: "%.0f", engine.stats.readabilityScore)))\n"
        report += "• Issues: \(engine.issues.filter { !$0.isDismissed }.count)\n\n"

        if !engine.issues.isEmpty {
            report += "Issues:\n"
            for issue in engine.issues.filter({ !$0.isDismissed }) {
                report += "• [\(issue.type.rawValue)] \"\(issue.original)\""
                if !issue.suggestion.isEmpty {
                    report += " → \"\(issue.suggestion)\""
                }
                report += "\n  \(issue.explanation)\n"
            }
        }
        return report
    }
}

// MARK: - Pill Tab Bar

// A custom animated tab bar replaces the default segmented Picker so the
// active tab reads unmistakably at a glance, and matches the blue/violet
// accent language used in the splash and onboarding flows instead of
// looking like a stock system control dropped into a themed app.
struct PillTabBar: View {
    @Binding var selection: ContentView.Tab
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                Button {
                    guard selection != tab else { return }
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                        selection = tab
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 13, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundStyle(selection == tab ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if selection == tab {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#5E9FFF"), Color(hex: "#A78BFA")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color(hex: "#5E9FFF").opacity(0.35), radius: 8, x: 0, y: 3)
                                .matchedGeometryEffect(id: "activeTabPill", in: namespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.secondary.opacity(0.1), in: Capsule())
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Score Banner

struct ScoreBanner: View {
    let stats: TextStats
    let isAnalyzing: Bool
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 18) {
                // Readability ring — a small at-a-glance dial instead of a bare
                // letter grade, echoing the ring-style widgets used elsewhere.
                ZStack {
                    Circle()
                        .stroke(stats.scoreColor.opacity(0.15), lineWidth: 4)
                    if isAnalyzing {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else {
                        Circle()
                            .trim(from: 0, to: max(0.03, stats.readabilityScore / 100))
                            .stroke(stats.scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.6), value: stats.readabilityScore)
                        Text(stats.scoreGrade)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(stats.scoreColor)
                    }
                }
                .frame(width: 40, height: 40)

                Divider().frame(height: 32)

                statItem(label: "Words",   value: "\(stats.wordCount)")
                statItem(label: "Issues",  value: "\(stats.issueCount)")
                statItem(label: "Reading", value: stats.readingTime)
                statItem(label: "Level",   value: stats.readabilityLabel.components(separatedBy: " ").first ?? "")

                Spacer()

                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Editor View

struct EditorView: View {
    @Binding var inputText: String
    @Binding var issues: [GrammarIssue]
    @Binding var selectedIssue: GrammarIssue?
    let settings: SettingsStore
    let engine: GrammarEngine
    let onTextChange: () -> Void
    let onApplyAll: () -> Void
    let onSave: () -> Void

    @State private var showIssuesList = true
    @FocusState private var isEditorFocused: Bool

    var activeIssues: [GrammarIssue] {
        issues.filter { !$0.isDismissed }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Text editor — GeometryReader pins the editor to the available width,
            // preventing UITextView from expanding horizontally beyond the screen.
            GeometryReader { geo in
                ScrollView {
                    HighlightedTextEditor(
                        text: $inputText,
                        issues: activeIssues,
                        fontSize: settings.fontSize,
                        onTapIssue: { issue in selectedIssue = issue },
                        onChange: onTextChange
                    )
                    .frame(width: geo.size.width - 32, alignment: .leading)
                    .frame(minHeight: 200, alignment: .topLeading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .overlay(alignment: .center) {
                    if inputText.isEmpty {
                        placeholderView
                    }
                }
            }

            // Issues panel
            if !activeIssues.isEmpty {
                Divider()
                issuesPanel
            }

            // Toolbar
            if !inputText.isEmpty {
                editorToolbar
            }
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Paste or type text to check")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Grammar, spelling, style, and clarity suggestions appear as you write")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .allowsHitTesting(false)
    }

    private var issuesPanel: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showIssuesList.toggle()
                }
            } label: {
                HStack {
                    Text("\(activeIssues.count) issue\(activeIssues.count == 1 ? "" : "s") found")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if !activeIssues.filter({ !$0.suggestion.isEmpty }).isEmpty {
                        Button(action: onApplyAll) {
                            Label("Fix all", systemImage: "wand.and.stars")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#5E9FFF"), Color(hex: "#A78BFA")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 6)
                    }
                    Image(systemName: showIssuesList ? "chevron.down" : "chevron.up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }

            if showIssuesList {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(activeIssues) { issue in
                            IssueRow(
                                issue: issue,
                                onTap: { selectedIssue = issue },
                                onQuickFix: { applyQuickFix(issue) }
                            )
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .frame(maxHeight: 220)
            }
        }
        .background(.ultraThinMaterial)
    }

    private func applyQuickFix(_ issue: GrammarIssue) {
        engine.applyFix(to: &inputText, issue: issue)
        engine.analyze(text: inputText, settings: settings)
        if settings.hapticFeedback {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private var editorToolbar: some View {
        HStack(spacing: 12) {
            Button(action: onSave) {
                Label("Save", systemImage: "square.and.arrow.down")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.secondary.opacity(0.1), in: Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            if !settings.checkAsYouType {
                Button {
                    engine.analyze(text: inputText, settings: settings)
                } label: {
                    Label("Check now", systemImage: "sparkle.magnifyingglass")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#5E9FFF"), Color(hex: "#A78BFA")],
                                startPoint: .leading, endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider() }
    }
}

// MARK: - Highlighted Text Editor

struct HighlightedTextEditor: UIViewRepresentable {
    @Binding var text: String
    let issues: [GrammarIssue]
    let fontSize: Double
    let onTapIssue: (GrammarIssue) -> Void
    let onChange: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        tv.font = UIFont.systemFont(ofSize: fontSize)
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        // Fix width overflow: tell the text container not to widen beyond its set width
        tv.textContainer.widthTracksTextView = true
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.isEditable = true
        tv.isScrollEnabled = false
        tv.autocorrectionType = .no
        tv.spellCheckingType = .no
        tv.smartDashesType = .no
        tv.smartQuotesType = .no
        // Prevent horizontal expansion
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        tap.delegate = context.coordinator
        tv.addGestureRecognizer(tap)

        context.coordinator.textView = tv
        return tv
    }

    func updateUIView(_ tv: UITextView, context: Context) {
        context.coordinator.parent = self

        // Fix deletion loop: guard against re-entrant updates triggered by setting attributedText.
        // Only proceed when SwiftUI's text differs from what's in the UITextView right now.
        guard !context.coordinator.isUpdating else { return }
        context.coordinator.isUpdating = true
        defer { context.coordinator.isUpdating = false }

        // Only rewrite attributedText when the plain string actually changed OR issues changed.
        // Comparing issues by count+first-id is cheap and avoids needless redraws mid-typing.
        let currentPlain = tv.attributedText?.string ?? ""
        let issuesChanged = context.coordinator.lastIssueCount != issues.count ||
                            context.coordinator.lastIssueFirstID != issues.first?.id

        if currentPlain != text || issuesChanged {
            let selectedRange = tv.selectedRange
            tv.attributedText = buildAttributedString()

            // Restore cursor, clamped to valid range
            let len = (tv.text as NSString).length
            let safeLoc = min(selectedRange.location, len)
            let safeLen = min(selectedRange.length, len - safeLoc)
            tv.selectedRange = NSRange(location: safeLoc, length: safeLen)

            context.coordinator.lastIssueCount   = issues.count
            context.coordinator.lastIssueFirstID = issues.first?.id
        }

        // Keep font in sync if settings changed without text change
        if let pointSize = tv.font?.pointSize, Double(pointSize) != fontSize {
                    tv.font = UIFont.systemFont(ofSize: fontSize)
                }
    }

    private func buildAttributedString() -> NSAttributedString {
        let nsText = text as NSString
        let attributed = NSMutableAttributedString(string: text)
        let fullRange = NSRange(location: 0, length: nsText.length)

        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.label
        ], range: fullRange)

        for issue in issues {
            let nsRange = issue.displayRange
            guard nsRange.location + nsRange.length <= nsText.length else { continue }

            let style: NSUnderlineStyle = issue.type == .spelling ? [.double] : [.single]
            attributed.addAttributes([
                .underlineStyle: style.rawValue,
                .underlineColor: UIColor(issue.type.color)
            ], range: nsRange)
        }

        return attributed
    }

    class Coordinator: NSObject, UITextViewDelegate, UIGestureRecognizerDelegate {
        var parent: HighlightedTextEditor
        weak var textView: UITextView?

        // Re-entrancy guard — prevents textViewDidChange from firing during our own
        // programmatic attributedText assignment in updateUIView.
        var isUpdating: Bool = false

        // Cheap change-detection to avoid unnecessary attributed string rebuilds.
        var lastIssueCount: Int = -1
        var lastIssueFirstID: UUID? = nil

        init(_ parent: HighlightedTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // Skip if we triggered this change ourselves
            guard !isUpdating else { return }
            parent.text = textView.text
            parent.onChange()
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let tv = textView, !parent.text.isEmpty else { return }
            let point = recognizer.location(in: tv)
            let layoutManager = tv.layoutManager

            let charIndex = layoutManager.characterIndex(
                for: point,
                in: tv.textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )
            guard charIndex < parent.text.count else { return }

            for issue in parent.issues {
                let r = issue.displayRange
                if r.location <= charIndex && charIndex < r.location + r.length {
                    parent.onTapIssue(issue)
                    return
                }
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }
    }
}

// MARK: - Issue Row

struct IssueRow: View {
    let issue: GrammarIssue
    let onTap: () -> Void
    var onQuickFix: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(issue.type.color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: issue.type.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(issue.type.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(issue.type.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(issue.type.color)
                            Text("·")
                                .foregroundStyle(.tertiary)
                            Text("\"\(issue.original.prefix(30))\(issue.original.count > 30 ? "…" : "")\"")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(issue.explanation)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            // One-tap fix for suggestions that don't need a full explanation —
            // saves a trip through the detail sheet for the obvious cases.
            if let onQuickFix, !issue.suggestion.isEmpty {
                Button(action: onQuickFix) {
                    Text("Fix")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(issue.type.color.opacity(0.15))
                        .foregroundStyle(issue.type.color)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - Issue Detail Sheet

struct IssueDetailSheet: View {
    let issue: GrammarIssue
    let onAccept: () -> Void
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Type badge
                HStack {
                    Label(issue.type.rawValue, systemImage: issue.type.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(issue.type.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(issue.type.color.opacity(0.12))
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding()

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Original vs suggestion
                        Group {
                            if !issue.suggestion.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Original", systemImage: "xmark.circle")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.red)
                                    Text(issue.original)
                                        .font(.body)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.red.opacity(0.07))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.red.opacity(0.2), lineWidth: 1)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Suggested fix", systemImage: "checkmark.circle")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.green)
                                    Text(issue.suggestion)
                                        .font(.body)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.green.opacity(0.07))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.green.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("Flagged text", systemImage: "flag")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.orange)
                                    Text(issue.original.prefix(200) + (issue.original.count > 200 ? "…" : ""))
                                        .font(.body)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(.orange.opacity(0.07))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }

                        // Explanation
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Why this matters", systemImage: "info.circle")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(issue.explanation)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding()
                }

                // Actions
                VStack(spacing: 10) {
                    if !issue.suggestion.isEmpty {
                        Button(action: onAccept) {
                            Label("Apply fix", systemImage: "checkmark")
                                .font(.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button(action: onDismiss) {
                        Text("Dismiss this issue")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.secondary.opacity(0.12))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Issue Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Insights View

struct InsightsView: View {
    let stats: TextStats
    let issues: [GrammarIssue]

    var issuesByType: [(IssueType, Int)] {
        IssueType.allCases.compactMap { type in
            let count = issues.filter { $0.type == type && !$0.isDismissed }.count
            return count > 0 ? (type, count) : nil
        }.sorted { $0.1 > $1.1 }
    }

    var body: some View {
        if stats.wordCount == 0 {
            ContentUnavailableView(
                "No text yet",
                systemImage: "chart.bar.xaxis",
                description: Text("Add text in the editor to see detailed insights")
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Readability card
                    readabilityCard

                    // Issue breakdown
                    if !issuesByType.isEmpty {
                        issueBreakdownCard
                    }

                    // Writing stats grid
                    statsGrid

                    // Sentence quality
                    sentenceQualityCard
                }
                .padding()
            }
        }
    }

    private var readabilityCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Readability")
                    .font(.headline)
                Spacer()
                Text(stats.scoreGrade)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(stats.scoreColor)
            }

            // Score bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.secondary.opacity(0.15))
                        RoundedRectangle(cornerRadius: 6)
                            .fill(stats.scoreColor)
                            .frame(width: geo.size.width * (stats.readabilityScore / 100))
                            .animation(.spring(response: 0.6), value: stats.readabilityScore)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("Very Difficult")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(stats.readabilityLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(stats.scoreColor)
                    Spacer()
                    Text("Very Easy")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Based on Flesch Reading Ease — measures how easy your text is to understand")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var issueBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Issues by type")
                .font(.headline)
                .padding(.bottom, 4)

            ForEach(issuesByType, id: \.0) { type, count in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: type.icon)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(type.color)
                    }

                    Text(type.rawValue)
                        .font(.subheadline)

                    Spacer()

                    Text("\(count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(type.color)
                        .frame(minWidth: 24)

                    // Mini bar
                    GeometryReader { geo in
                        let max = Double(issuesByType.first?.1 ?? 1)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(type.color)
                            .frame(width: geo.size.width * (Double(count) / max))
                            .animation(.spring(response: 0.5), value: count)
                    }
                    .frame(width: 60, height: 8)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard("Words",      value: "\(stats.wordCount)",            icon: "text.word.spacing",   color: .blue)
            statCard("Sentences",  value: "\(stats.sentenceCount)",        icon: "text.alignleft",      color: .purple)
            statCard("Paragraphs", value: "\(stats.paragraphCount)",       icon: "text.aligncenter",   color: .teal)
            statCard("Characters", value: "\(stats.charCount)",            icon: "character.cursor.ibeam", color: .orange)
            statCard("Reading",    value: stats.readingTime,               icon: "clock",               color: .green)
            statCard("Avg sentence", value: String(format: "%.1f words", stats.avgWordsPerSentence), icon: "ruler", color: .indigo)
        }
    }

    private func statCard(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 14))
                Spacer()
            }
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var sentenceQualityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Writing quality")
                .font(.headline)

            qualityRow(
                icon: "text.word.spacing",
                label: "Unique word ratio",
                value: String(format: "%.0f%%", stats.uniqueWordRatio * 100),
                color: stats.uniqueWordRatio > 0.6 ? .green : stats.uniqueWordRatio > 0.4 ? .orange : .red,
                caption: "Higher ratio = more varied vocabulary"
            )

            Divider()

            qualityRow(
                icon: "arrow.left.arrow.right",
                label: "Passive voice",
                value: String(format: "%.0f%%", stats.passiveVoicePercent),
                color: stats.passiveVoicePercent < 10 ? .green : stats.passiveVoicePercent < 25 ? .orange : .red,
                caption: "Keep under 10% for clearer writing"
            )

            Divider()

            qualityRow(
                icon: "ruler",
                label: "Avg sentence length",
                value: String(format: "%.0f words", stats.avgWordsPerSentence),
                color: stats.avgWordsPerSentence < 20 ? .green : stats.avgWordsPerSentence < 30 ? .orange : .red,
                caption: "Under 20 words is ideal"
            )
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func qualityRow(icon: String, label: String, value: String, color: Color, caption: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Vocabulary View (Word Cloud / Frequency)

struct VocabularyView: View {
    let frequencies: [WordFrequency]

    var body: some View {
        if frequencies.isEmpty {
            ContentUnavailableView(
                "No vocabulary data",
                systemImage: "character.magnify",
                description: Text("Write more text to see your most-used words")
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Most-used words")
                        .font(.headline)
                        .padding(.horizontal)

                    // Word cloud
                    FlowLayout(frequencies: frequencies)
                        .padding(.horizontal)

                    Divider()

                    // Frequency list
                    Text("Frequency breakdown")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVStack(spacing: 0) {
                        ForEach(Array(frequencies.prefix(15).enumerated()), id: \.element.id) { idx, freq in
                            HStack(spacing: 12) {
                                Text("\(idx + 1)")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 20)

                                Text(freq.word)
                                    .font(.subheadline)

                                Spacer()

                                GeometryReader { geo in
                                    let max = Double(frequencies.first?.count ?? 1)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(wordColor(for: idx).opacity(0.7))
                                        .frame(width: geo.size.width * (Double(freq.count) / max))
                                        .animation(.spring(response: 0.5).delay(Double(idx) * 0.03), value: freq.count)
                                }
                                .frame(width: 100, height: 8)

                                Text("\(freq.count)×")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 32, alignment: .trailing)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)

                            if idx < frequencies.prefix(15).count - 1 {
                                Divider().padding(.leading, 44)
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
    }

    private func wordColor(for index: Int) -> Color {
        let colors: [Color] = [.blue, .purple, .teal, .orange, .pink, .indigo, .green, .red]
        return colors[index % colors.count]
    }
}

// MARK: - Flow Layout (Word Cloud)

struct FlowLayout: View {
    let frequencies: [WordFrequency]

    var body: some View {
        let max = Double(frequencies.first?.count ?? 1)

        return GeometryReader { _ in
            FlowLayoutContent(items: frequencies.prefix(20).map { freq in
                (
                    freq,
                    fontSize(for: freq.count, max: max)
                )
            })
        }
        .frame(height: 200)
    }

    private func fontSize(for count: Int, max: Double) -> CGFloat {
        let ratio = Double(count) / max
        return CGFloat(12 + ratio * 20)
    }
}

struct FlowLayoutContent: View {
    let items: [(WordFrequency, CGFloat)]

    private let colors: [Color] = [.blue, .purple, .teal, .orange, .pink, .indigo, .green]

    var body: some View {
        var x: CGFloat = 0
        var y: CGFloat = 0
        let spacing: CGFloat = 8

        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(Array(items.enumerated()), id: \.element.0.id) { idx, pair in
                    let (freq, size) = pair
                    let estimatedWidth = CGFloat(freq.word.count) * size * 0.55 + 16
                    Text(freq.word)
                        .font(.system(size: size, weight: size > 24 ? .bold : .regular, design: .rounded))
                        .foregroundStyle(colors[idx % colors.count].opacity(0.8))
                        .padding(.horizontal, 4)
                        .alignmentGuide(.leading) { _ in
                            let result = -x
                            if x + estimatedWidth > geo.size.width {
                                x = estimatedWidth + spacing
                                y += size + spacing
                            } else {
                                x += estimatedWidth + spacing
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in -y }
                }
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss
    @State private var showResetConfirm = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Form {
                // ── Subscription banner ──
                Section {
                    if subscriptionManager.isSubscribed {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("GrammarCheck Pro")
                                    .font(.subheadline.weight(.semibold))
                                Text("You have full access to all features")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(.yellow)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Upgrade to Pro")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text("Unlock unlimited grammar checking")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Writing tone
                Section {
                    Picker("Writing tone", selection: $settings.writingTone) {
                        ForEach(WritingTone.allCases, id: \.self) { tone in
                            VStack(alignment: .leading) {
                                Text(tone.rawValue)
                                Text(tone.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(tone)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Writing context")
                } footer: {
                    Text("Adjusts style and tone suggestions to match your writing goals")
                }

                // Check types
                Section("Check for") {
                    ForEach(IssueType.allCases, id: \.self) { type in
                        Toggle(isOn: Binding(
                            get: { settings.isEnabled(type) },
                            set: { _ in settings.toggle(type) }
                        )) {
                            Label {
                                Text(type.rawValue)
                            } icon: {
                                Image(systemName: type.icon)
                                    .foregroundStyle(type.color)
                            }
                        }
                    }
                }

                // Behavior
                Section("Behavior") {
                    Toggle("Check as you type", isOn: $settings.checkAsYouType)
                    Toggle("Show readability stats", isOn: $settings.showReadability)
                    Toggle("Haptic feedback", isOn: $settings.hapticFeedback)
                }

                // Appearance
                Section("Appearance") {
                    Picker("Color scheme", selection: $settings.appearanceMode) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font size")
                            Spacer()
                            Text("\(Int(settings.fontSize))pt")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $settings.fontSize, in: 12...24, step: 1)
                            .tint(.blue)
                    }
                }

                // Reset
                Section {
                    Button("Reset all settings", role: .destructive) {
                        showResetConfirm = true
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall, onDismiss: {
                Task { await subscriptionManager.refresh() }
            }) {
                PaywallView()
            }
            .confirmationDialog(
                "Reset all settings?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset settings", role: .destructive) {
                    settings.enableGrammar     = true
                    settings.enableSpelling    = true
                    settings.enablePunctuation = true
                    settings.enableStyle       = true
                    settings.enableClarity     = true
                    settings.enableWordChoice  = true
                    settings.enablePassive     = true
                    settings.enableRedundancy  = true
                    settings.checkAsYouType    = true
                    settings.showReadability   = true
                    settings.hapticFeedback    = true
                    settings.fontSize          = 16.0
                    settings.appearanceMode    = "system"
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This restores every check, behavior, and appearance setting to its default. This can't be undone.")
            }
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @ObservedObject var history: HistoryStore
    let onSelect: (HistoryEntry) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if history.entries.isEmpty {
                    ContentUnavailableView(
                        "No history yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Saved texts will appear here")
                    )
                } else {
                    List {
                        ForEach(history.entries) { entry in
                            Button {
                                onSelect(entry)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(entry.title.isEmpty ? "Untitled" : entry.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)

                                    HStack(spacing: 12) {
                                        Label("\(entry.wordCount) words", systemImage: "text.word.spacing")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)

                                        if entry.issueCount > 0 {
                                            Label("\(entry.issueCount) issues", systemImage: "exclamationmark.triangle")
                                                .font(.caption)
                                                .foregroundStyle(.orange)
                                        } else {
                                            Label("No issues", systemImage: "checkmark.circle")
                                                .font(.caption)
                                                .foregroundStyle(.green)
                                        }

                                        Spacer()

                                        Text(entry.date, style: .relative)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: history.delete)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !history.entries.isEmpty {
                        Button("Clear all", role: .destructive) {
                            history.clear()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheetView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
