import SwiftUI

struct ReadingStreakCard: View {
    let streakData: [ReadingStreak]
    var onMarkRead: () -> Void
    
    private var currentWeek: [(day: String, date: Int, fullDate: Date, isRead: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find start of week (e.g. Sunday or Monday depending on locale)
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        
        var days: [(String, Int, Date, Bool)] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "E" // Mon
                let dayName = dayFormatter.string(from: date)
                
                let dayNumber = calendar.component(.day, from: date)
                
                // Check if read
                let isRead = streakData.contains { calendar.isDate($0.date, inSameDayAs: date) && $0.isRead }
                
                days.append((dayName, dayNumber, date, isRead))
            }
        }
        return days
    }
    
    private var isReadToday: Bool {
        let calendar = Calendar.current
        return streakData.contains { calendar.isDateInToday($0.date) && $0.isRead }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Did you read today?")
                .font(.system(size: 20, weight: .bold)) // Bolder, custom size
                .foregroundColor(.black) // Strict Black
            
            // Calendar Strip
            HStack(spacing: 0) {
                ForEach(currentWeek, id: \.fullDate) { item in
                    VStack(spacing: 8) {
                        Text(item.day)
                            .textStyle(.caption)
                            .foregroundColor(Color(hex: "#666666")) // Grey text
                        
                        Text("\(item.date)")
                            .font(.system(size: 16, weight: Calendar.current.isDateInToday(item.fullDate) ? .bold : .regular))
                            .foregroundColor(Calendar.current.isDateInToday(item.fullDate) ? .white : .black) // White text for current day
                            .frame(width: 32, height: 32)
                            .background(
                                Group {
                                    if Calendar.current.isDateInToday(item.fullDate) {
                                        Circle()
                                            .fill(Color.black) // Black circle for current day
                                    }
                                }
                            )
                        
                        // Status Indicator
                        if item.isRead {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: "#F5F5F5")) // Grey background
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black) // Black tick
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                               .strokeBorder(Color(hex: "#000000").opacity(0.08), lineWidth: 1)
                               .background(Color.white)
                               .frame(width: 24, height: 24)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Action Button
            Button(action: {
                withAnimation(.spring) {
                    onMarkRead()
                }
            }) {
                Text(isReadToday ? "Great job 🎉" : "Yes, I read today!")
                    .textStyle(.bodyBold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .disabled(isReadToday)
            // Removed opacity reduction to ensure "solid black" appearance as requested
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}
