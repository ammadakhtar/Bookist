import SwiftUI

struct RatingSection: View {
    @Binding var rating: Int
    @Binding var reviewText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How was the book?")
                .textStyle(.headline)
                .foregroundColor(AppColors.primaryText)
            
            // Star Selection
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: {
                        HapticHelper.light()
                        rating = index
                    }) {
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundColor(index <= rating ? .orange : .gray)
                    }
                }
            }
            
            // Text Area
            TextEditor(text: $reviewText)
                .frame(minHeight: 150)
                .padding(12)
                .background(Color.clear)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.divider, lineWidth: 1.5)
                )
        }
    }
}
