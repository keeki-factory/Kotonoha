import SwiftUI
import PhotosUI

@Observable
class QuoteEditorViewModel {
    var quote: Quote?
    var text: String
    var source: String
    var author: String
    var detail: String
    var selectedPhoto: PhotosPickerItem?
    var imageData: Data?
    var imagePreview: UIImage?
    var validationError: String?
    var cardType: CardType
    
    init(quote: Quote?, initialImage: UIImage?, onSave: @escaping (String, String?, String?, String?, Data?, String?, CardType) -> Void) {
        self.quote = quote
        self.text = quote?.text ?? ""
        self.source = quote?.source ?? ""
        self.author = quote?.author ?? ""
        self.detail = quote?.detail ?? ""
        self.imagePreview = initialImage
        self.cardType = quote?.cardType ?? .image
    }
}

struct QuoteEditorPreview: View {
    @Binding var quoteEditorViewModel: QuoteEditorViewModel
    var body: some View {
        
    }
}

struct QuoteEditorView: View {
//    let quote: Quote?
    let onSave: (String, String?, String?, String?, Data?, String?, CardType) -> Void

    @Environment(\.dismiss) private var dismiss
    @State var quoteEditorViewModel: QuoteEditorViewModel
    

    init(quote: Quote?, initialImage: UIImage?, onSave: @escaping (String, String?, String?, String?, Data?, String?, CardType) -> Void) {
        self.onSave = onSave
        _quoteEditorViewModel = State(initialValue: .init(quote: quote, initialImage: initialImage, onSave: onSave))
    }

    var body: some View {
        NavigationStack {
            QuoteCardPreView(
                quoteEditorViewModel: $quoteEditorViewModel
            )
            Form {
                Section("名言") {
                    TextEditor(text: $quoteEditorViewModel.text)
                        .frame(minHeight: 110)
                    if let validationError = quoteEditorViewModel.validationError {
                        Text(validationError).font(.caption).foregroundStyle(.red)
                    }
                }
                Section("情報（任意）") {
                    TextField("発言者", text: $quoteEditorViewModel.author)
                    TextField("出典・引用元", text: $quoteEditorViewModel.source)
                    TextField("詳細・メモ", text: $quoteEditorViewModel.detail, axis: .vertical)
                        .lineLimit(3...7)
                    Picker("カードの種類", selection: $quoteEditorViewModel.cardType) {
                        Text("text").tag(CardType.text)
                        Text("image").tag(CardType.image)
                    }
                }
                Section("背景画像") {
                    if let imagePreview = quoteEditorViewModel.imagePreview {
                        Image(uiImage: imagePreview)
                            .resizable().scaledToFill()
                            .frame(height: 160).frame(maxWidth: .infinity)
                            .clipped().clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    PhotosPicker(selection: $quoteEditorViewModel.selectedPhoto, matching: .images) {
                        Label("写真を選択", systemImage: "photo")
                    }
                    if quoteEditorViewModel.imagePreview != nil {
                        Button("画像を外す", role: .destructive) {
                            quoteEditorViewModel.imagePreview = nil
                            quoteEditorViewModel.imageData = nil
                            quoteEditorViewModel.selectedPhoto = nil
                        }
                    }
                }
            }
            .navigationTitle(quoteEditorViewModel.quote == nil ? "名言を追加" : "名言を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        guard Quote.validate(text: quoteEditorViewModel.text) == nil else {
                            quoteEditorViewModel.validationError = "名言を入力してください。"
                            return
                        }
                        onSave(
                            quoteEditorViewModel.text,
                            quoteEditorViewModel.source,
                            quoteEditorViewModel.author,
                            quoteEditorViewModel.detail,
                            quoteEditorViewModel.imageData,
                            (quoteEditorViewModel.imagePreview == nil ? nil : quoteEditorViewModel.quote?.imageFilename),
                            quoteEditorViewModel.cardType)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: quoteEditorViewModel.selectedPhoto) { _, item in
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    quoteEditorViewModel.imageData = data
                    quoteEditorViewModel.imagePreview = image
                }
            }
        }
    }
}
