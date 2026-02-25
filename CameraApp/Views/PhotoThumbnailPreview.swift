import SwiftUI
import Combine

struct PhotoThumbnailView: View {

    @ObservedObject var library = PhotoLibraryManager.shared
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            Group {
                if let image = library.images.first {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.black
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 1)
            )
        }
    }
}
