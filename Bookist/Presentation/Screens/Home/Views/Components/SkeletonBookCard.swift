import SwiftUI

struct SkeletonBookCard: View {
    let width: CGFloat = 120
    let height: CGFloat = 180
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover Image Placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shimmer()
            
            // Title Placeholder
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 14)
                    .frame(width: 100)
                    .shimmer()
                
                Spacer().frame(height: 4)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 14)
                    .frame(width: 80)
                    .shimmer()
            }
            .frame(width: width, alignment: .leading)
            .frame(height: 36, alignment: .topLeading)
        }
    }
}
