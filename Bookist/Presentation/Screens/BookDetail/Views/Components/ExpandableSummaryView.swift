import SwiftUI

struct ExpandableSummaryView: View {
    let summary: String
    @State private var showFullSummary = false
    @State private var isTruncated = false
    
    private var cleanedSummary: String {
        summary.replacingOccurrences(of: "(This is an automatically generated summary.)", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(cleanedSummary)
                .textStyle(.body)
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(3)
                .onAppear {
                    // Simple heuristic: if text is longer than ~200 chars, it's likely truncated at 3 lines
                    isTruncated = cleanedSummary.count > 200
                }
            
            if isTruncated {
                Button(action: {
                    HapticHelper.light()
                    showFullSummary = true
                }) {
                    Text("View More")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showFullSummary) {
            SummarySheet(summary: cleanedSummary)
                .presentationDetents(UIDevice.current.userInterfaceIdiom == .pad ? [.large] : [.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct SummarySheet: View {
    let summary: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            ScrollView {
                Text(summary)
                    .textStyle(.body)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.horizontal, 20)
            }
        }
        .presentationCornerRadius(24)
    }
}
