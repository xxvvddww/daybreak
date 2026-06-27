import SwiftUI

/// A single welcome screen shown once: introduces the app, lets the user set
/// their salary, and states the indicative / on-device disclaimer before they
/// continue.
struct OnboardingView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(ProfileStore.self) private var store
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Brand.wallpaper(dark: scheme == .dark).ignoresSafeArea()
            RadialGradient(colors: [Color.white.opacity(0.28), .clear],
                           center: .center, startRadius: 0, endRadius: 320)
                .ignoresSafeArea()
                .blendMode(.softLight)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        MarkLogo(size: 60)
                        Text("Daybreak")
                            .serif(40, weight: .medium, relativeTo: .largeTitle)
                        Text("your money, by the second")
                            .sans(15)
                            .foregroundStyle(Brand.paper.opacity(0.66))
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 28)

                    VStack(spacing: 14) {
                        featureRow(icon: "sun.max.fill", title: "Live earnings",
                                   detail: "Your pay accrues in real time, every working second.")
                        featureRow(icon: "checkmark.shield.fill", title: "Super & tax",
                                   detail: "See contributions, the 15% gap and compounding.")
                        featureRow(icon: "chart.bar.fill", title: "Where you stand",
                                   detail: "Your percentile and what tax really costs you.")
                    }
                    .padding(.bottom, 28)

                    Text("YOUR SALARY")
                        .sans(11, weight: .bold, relativeTo: .caption).tracking(1.4)
                        .foregroundStyle(Brand.paper.opacity(0.6))
                    Text(DaybreakFormat.money(store.inputs.salary, fractionDigits: 0))
                        .mono(34, weight: .medium, relativeTo: .title)
                        .foregroundStyle(Brand.paper)
                        .padding(.top, 6)
                    Slider(value: store.binding(\.salary), in: 0...CountryConfig.australia.maxSalary, step: 1000)
                        .tint(Brand.gold)
                        .padding(.top, 8)
                        .accessibilityLabel("Annual salary")
                        .accessibilityValue(DaybreakFormat.money(store.inputs.salary, fractionDigits: 0))
                    Text("You can fine-tune your hours, super and more in Setup.")
                        .sans(12.5)
                        .foregroundStyle(Brand.paper.opacity(0.6))
                        .padding(.top, 10)

                    Button(action: onComplete) {
                        Text("Get started")
                            .sans(16, weight: .semibold)
                            .foregroundStyle(Brand.ink)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Brand.paper, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 28)

                    Text("Figures are indicative only and not financial advice. Everything you enter stays on your device.")
                        .sans(11.5)
                        .foregroundStyle(Brand.paper.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                }
                .padding(.horizontal, 26)
                .padding(.bottom, 30)
            }
        }
        .foregroundStyle(Brand.paper)
    }

    private func featureRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Brand.gold)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).sans(15, weight: .semibold).foregroundStyle(Brand.paper)
                Text(detail).sans(12.5).foregroundStyle(Brand.paper.opacity(0.66)).lineSpacing(1)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}
