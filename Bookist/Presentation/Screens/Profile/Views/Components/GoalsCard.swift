import SwiftUI

struct GoalsCard: View {
    let current: Int
    let target: Int
    
    private var progress: Double {
        Double(current) / Double(max(1, target))
    }
    
    private var year: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            // Background decorations
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.1))
                .rotationEffect(.degrees(-15))
                .offset(x: 140, y: 40)
            
            Image(systemName: "book")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.1))
                .rotationEffect(.degrees(20))
                .offset(x: 160, y: -40)
            
            HStack(spacing: 20) {
                // Ring Dial
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 10)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-135)) // Start from top-leftish
                    
                    // Center Book
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "book.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "5142E1"))
                        )
                }
                .frame(width: 86, height: 86)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(year) Reading Goal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    if current == 0 {
                        Text("It's not too late to start reading!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    } else {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(current)")
                                .font(.system(size: 28, weight: .bold))
                            Text("of \(target)")
                                .font(.system(size: 18, weight: .semibold))
                            Text("books")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "5142E1"))
        )
    }
}
