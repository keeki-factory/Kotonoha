import SwiftUI

struct QuoteCardView: View {
    let quote: Quote
    let image: UIImage?
    let cardType: CardType
    @State private var componentHeight: CGFloat = 0.0

    init(quote: Quote, image: UIImage?, cardType: CardType? = nil) {
        self.quote = quote
        self.image = image
        self.cardType = cardType ?? quote.cardType
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                cardBackground
                
                if let _ = image {
                    VStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(
                                LinearGradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black.opacity(0.75), location: 0.2),
                                    .init(color: .black.opacity(0.75), location: 1)
                                ], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: proxy.size.width, height: proxy.size.height*0.4)
                    }
                }
                
                switch cardType {
                case .image:
                    imageCardContent
                        
                case .text:
                    textCardContent
                }
                
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(height: cardType == .image ? 300 : 260)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    @ViewBuilder
    private var cardBackground: some View {
        GeometryReader { proxy in
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            } else {
                LinearGradient(
                    colors: [.indigo.opacity(0.85), .black.opacity(0.92)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var imageCardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)
            Rectangle()
                .fill(
                    LinearGradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.75), location: 1.0)
                    ], startPoint: .top, endPoint: .bottom)
                )
                .frame(height: 30)
            VStack(alignment: .leading, spacing: 6) {
                Text("“\(quote.text)”")
                    .font(.system(size: 25, weight: .semibold, design: .serif))
                    .lineLimit(3)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)

                metadata(alignment: .leading)
            }
            .foregroundStyle(.white)
            .padding(12)
            .padding([.leading, .trailing], 8)
            .background(.black.opacity(0.75))
        }
    }

    private var textCardContent: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("“\(quote.text)”")
                .font(.system(size: 25, weight: .semibold, design: .serif))
                .lineSpacing(5)
                .lineLimit(6)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            metadata(alignment: .center)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(22)
    }

    @ViewBuilder
    private func metadata(alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 2) {
            if let author = quote.author {
                Text("— \(author)")
                    .font(.caption.weight(.medium))
            }
            if let source = quote.source {
                Text(source)
                    .font(.caption)
                    .opacity(0.8)
            }
        }
    }
}

struct QuoteCardPreView: View {
    @Binding var quoteEditorViewModel: QuoteEditorViewModel

    private var quote: Quote {
        Quote(
            text: quoteEditorViewModel.text,
            source: quoteEditorViewModel.source,
            author: quoteEditorViewModel.author
        )
    }

    var body: some View {
        QuoteCardView(
            quote: quote,
            image: quoteEditorViewModel.imagePreview,
            cardType: quoteEditorViewModel.cardType
        )
        .padding(.horizontal)
    }
}
