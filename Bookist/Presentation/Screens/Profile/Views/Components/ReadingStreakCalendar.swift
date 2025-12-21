import SwiftUI
import SwiftData

struct ReadingStreakCalendar: View {
    @State private var selectedMonth = Date()
    
    @Query private var readStatuses: [BookReadStatusEntity]
    
    private let calendar = Calendar.current
    
    private var dayLabels: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstDay = calendar.firstWeekday - 1
        return Array(symbols[firstDay...] + symbols[..<firstDay])
    }
    
    private var readDatesThisMonth: [Int: (isRead: Bool, bookCount: Int)] {
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        let filtered = readStatuses.filter {
            let statusComponents = calendar.dateComponents([.year, .month, .day], from: $0.finishedAt)
            return statusComponents.year == components.year && statusComponents.month == components.month && $0.finishedAt <= Date()
        }
        
        var counts: [Int: (isRead: Bool, bookCount: Int)] = [:]
        for status in filtered {
            let day = calendar.component(.day, from: status.finishedAt)
            let current = counts[day, default: (false, 0)]
            
            // It's a "read day" if ANY status exists for that day
            // Only increment bookCount if bookId > 0
            counts[day] = (
                isRead: true,
                bookCount: current.bookCount + (status.bookId > 0 ? 1 : 0)
            )
        }
        return counts
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reading Streak")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                
                Text("Filled dates show that you read a book on that specific date. If the number of books read via ePub reader is 1 or greater, it will display the total books read on that date as well.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText.opacity(0.8))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Month Picker Trigger
            Menu {
                // Month Picker
                Picker("Month", selection: Binding(
                    get: { calendar.component(.month, from: selectedMonth) },
                    set: { month in
                        if let date = calendar.date(bySetting: .month, value: month, of: selectedMonth) {
                            selectedMonth = date
                        }
                    }
                )) {
                    let year = calendar.component(.year, from: selectedMonth)
                    let today = Date()
                    let currentYear = calendar.component(.year, from: today)
                    let currentMonth = calendar.component(.month, from: today)
                    
                    let startMonth = year == 2025 ? 12 : 1
                    let endMonth = year == currentYear ? currentMonth : 12
                    
                    let finalStart = min(startMonth, endMonth)
                    
                    ForEach(finalStart...endMonth, id: \.self) { month in
                        Text(calendar.monthSymbols[month-1]).tag(month)
                    }
                }
                
                // Year Picker
                Picker("Year", selection: Binding(
                    get: { calendar.component(.year, from: selectedMonth) },
                    set: { year in
                        if let date = calendar.date(bySetting: .year, value: year, of: selectedMonth) {
                            selectedMonth = date
                        }
                    }
                )) {
                    let currentYear = calendar.component(.year, from: Date())
                    ForEach(2025...currentYear, id: \.self) { year in
                        Text(String(format: "%d", year)).tag(year)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(monthName(for: selectedMonth))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                }
                .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Calendar Grid
            VStack(spacing: 20) {
                // Days Labels
                HStack(spacing: 0) {
                    ForEach(dayLabels, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isCurrentDayOfWeek(day) ? .white : AppColors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isCurrentDayOfWeek(day) ? Color.black : Color.clear)
                            )
                    }
                }
                
                // Days Grid
                let days = daysInMonth(for: selectedMonth)
                let firstDayOffset = firstWeekdayOffset(for: selectedMonth)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
                    // Empty cells for offset - using unique strings for IDs
                    ForEach(0..<firstDayOffset, id: \.self) { i in
                        Color.clear
                            .frame(height: 48)
                            .id("empty-\(i)")
                    }
                    
                    ForEach(1...days, id: \.self) { day in
                        let data = readDatesThisMonth[day] ?? (false, 0)
                        DayCell(day: day, isRead: data.isRead, bookCount: data.bookCount)
                            .id("day-\(day)")
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - Helpers
    private func monthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func daysInMonth(for date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    private func firstWeekdayOffset(for date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        let firstOfMonth = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let firstDay = calendar.firstWeekday
        return (weekday - firstDay + 7) % 7
    }
    
    private func isCurrentDayOfWeek(_ day: String) -> Bool {
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let selectedComponents = calendar.dateComponents([.year, .month], from: selectedMonth)
        
        // Only highlight if we are in the current month/year
        guard todayComponents.year == selectedComponents.year,
              todayComponents.month == selectedComponents.month else {
            return false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: Date()) == day
    }
}

struct DayCell: View {
    let day: Int
    let isRead: Bool
    let bookCount: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(day)")
                .font(.system(size: 14))
                .foregroundColor(isRead ? .white : AppColors.secondaryText) // White text if day completed
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isRead ? Color.black : AppColors.divider, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 8).fill(isRead ? Color.black : Color.white)) // Black fill if day completed
                )
                .overlay(
                    Group {
                        if bookCount > 0 {
                            Text("\(bookCount)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 14, height: 14)
                                .background(Circle().fill(AppColors.accentOrange))
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                .offset(x: 18, y: -18)
                        }
                    },
                    alignment: .center
                )
        }
        .frame(height: 48)
    }
}
