import SwiftUI

struct FullScreenPhotoView: View, Identifiable {

    let id = UUID()
    let image: UIImage

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}
