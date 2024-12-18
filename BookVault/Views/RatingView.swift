import SwiftUI

struct RatingView: View {
    let rating: Int
    let maxRating: Int
    let onRatingChanged: (Int) -> Void
    let size: CGFloat
    let spacing: CGFloat
    let color: Color
    
    init(
        rating: Int,
        maxRating: Int = 5,
        onRatingChanged: @escaping (Int) -> Void,
        size: CGFloat = 20,
        spacing: CGFloat = 4,
        color: Color = .yellow
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.onRatingChanged = onRatingChanged
        self.size = size
        self.spacing = spacing
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(color)
                    .onTapGesture {
                        onRatingChanged(index)
                    }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RatingView(rating: 3, onRatingChanged: { _ in })
        RatingView(rating: 4, onRatingChanged: { _ in }, size: 30, color: .orange)
        RatingView(rating: 2, onRatingChanged: { _ in }, size: 25, spacing: 8, color: .blue)
    }
    .padding()
}
