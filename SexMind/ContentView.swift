import SwiftUI
import AVFoundation
import SpriteKit
import UserNotifications

struct ContentView: View {
    @State private var currentQuote: String = QuoteManager.shared.randomQuote()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var spermScene = SpermScene(size: UIScreen.main.bounds.size)
    @State private var selectedTime = Date()
    @State private var notificationSet: Bool? = false
    @State private var showSweatOverlay = false

    @AppStorage("favoriteQuotes") private var favoriteQuotesData: Data = Data()
    @State private var favoriteQuotes: [String] = []
    @State private var showingFavorites = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.8), .pink.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .zIndex(0)

            SpriteView(scene: spermScene)
                .background(Color.clear)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
                .zIndex(1)

         

            // Fixed header
            VStack {
                Text("💖 SexMind Daily 💖")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 30)

                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .zIndex(2)

            // Main content
            VStack(spacing: 30) {
                Spacer().frame(height: 100)

                VStack(spacing: 8) {
                    Text(currentQuote)
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 20) {
                        Button(action: {
                            if !favoriteQuotes.contains(currentQuote) {
                                favoriteQuotes.append(currentQuote)
                                if let encoded = try? JSONEncoder().encode(favoriteQuotes) {
                                    favoriteQuotesData = encoded
                                }
                            }
                        }) {
                            Image(systemName: favoriteQuotes.contains(currentQuote) ? "heart.fill" : "heart")
                                .foregroundColor(.pink)
                                .font(.title2)
                        }

                        Button("View Favorites") {
                            showingFavorites = true
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    }
                }

                GeometryReader { geo in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentQuote = QuoteManager.shared.randomQuote()
                        }

                      

                        let buttonFrame = geo.frame(in: .global)
                        let buttonCenterGlobal = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)

                        if let window = UIApplication.shared.connectedScenes
                            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                            .first,
                           let rootView = window.rootViewController?.view {

                            let converted = rootView.convert(buttonCenterGlobal, from: nil)
                            let scenePoint = spermScene.convertPoint(fromView: converted)

                            spermScene.emitSperm(from: scenePoint)
                            spermScene.emitSweat(from: scenePoint)
                        }

                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

                        if let url = Bundle.main.url(forResource: "squirt", withExtension: "mp3")
                            ?? Bundle.main.url(forResource: "squirt", withExtension: "wav") {
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: url)
                                audioPlayer?.play()
                            } catch {
                                print("⚠️ Error playing squirt sound: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Show Me Another")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    Color.pink
                                    Image("sweat_overlay")
                                        .resizable()
                                        .scaledToFill()
                                        .opacity(0.3)
                                }
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                            )
                    }
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                .frame(height: 50)

                // Notifications
                if notificationSet == true {
                    VStack(spacing: 6) {
                        Text("✅ Daily notification set.")
                            .foregroundColor(.white)
                            .font(.headline)

                        HStack(spacing: 12) {
                            Button("Change Time") {
                                notificationSet = false
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                            Button("Stop Notification") {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                notificationSet = nil
                                print("🛑 All notifications cancelled by user")
                            }
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .padding(.top)
                } else if notificationSet == false {
                    VStack(spacing: 16) {
                        Text("🔔 Want a daily quote?")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        DatePicker("Pick Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())

                        HStack(spacing: 16) {
                            Button("Set Notification") {
                                NotificationScheduler.scheduleDailyNotification(at: selectedTime)
                                notificationSet = true
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.pink)
                            .clipShape(Capsule())

                            Button("No Notification") {
                                notificationSet = nil
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .foregroundColor(.white.opacity(0.7))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top)
                } else {
                    VStack(spacing: 10) {
                        Text("🔕 No notification active")
                            .foregroundColor(.white)
                            .font(.headline)

                        Button("Enable Again") {
                            notificationSet = false
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top)
                }
            }
            .padding()
            .zIndex(2)
            .onAppear {
                if let decoded = try? JSONDecoder().decode([String].self, from: favoriteQuotesData) {
                    favoriteQuotes = decoded
                }
            }
            .sheet(isPresented: $showingFavorites) {
                NavigationView {
                    List {
                        ForEach(favoriteQuotes, id: \.self) { quote in
                            Text(quote)
                                .font(.body)
                                .padding(.vertical, 4)
                        }
                    }
                    .navigationTitle("💖 Favorites")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Clear All") {
                                favoriteQuotes.removeAll()
                                favoriteQuotesData = Data()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

