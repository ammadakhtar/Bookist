import SwiftUI

struct FinishedCard: View {
    let count: Int
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
    
    private var year: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Finished")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    if count == 0 {
                        Text("The reading goal is still doable")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        HStack(alignment: .lastTextBaseline, spacing: 8) {
                            Text("\(count)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppColors.primaryText)
                            Text("books so far this year")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Spacer()
                
                // Share Button
                Button(action: {
                    if count > 0 {
                        HapticHelper.medium()
                        // Share achievement
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(count > 0 ? AppColors.accentOrange : Color.gray.opacity(0.3))
                        .background(
                            Circle()
                                .fill(count > 0 ? AppColors.accentOrange.opacity(0.15) : Color.gray.opacity(0.1))
                        )
                }
                .disabled(count == 0)
            }
            
            // Insights
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(AppColors.accentOrange)
                    Text("Insights")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.accentOrange)
                }
                
                Text("Keep it going! at your current pace, you’re on track to meet your \(year) reading goal in \(currentMonth).")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.primaryText.opacity(0.8))
                    .lineSpacing(4)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "FFF7F0")) // Light orange/beige
        )
    }
}
