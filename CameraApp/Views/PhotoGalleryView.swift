import SwiftUI

struct PhotoGalleryView: View {

    @ObservedObject var library = PhotoLibraryManager.shared
    @State private var selectedImage: UIImage?

    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(library.images.indices, id: \.self) { index in
                        Image(uiImage: library.images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .onTapGesture {
                                selectedImage = library.images[index]
                            }
                    }
                }
            }
            .navigationTitle("Camera Roll")
            .sheet(isPresented: Binding(
                get: { selectedImage != nil },
                set: { if !$0 { selectedImage = nil } }
            )) {
                if let image = selectedImage {
                    FullScreenPhotoView(image: image)
                }
            }
        }
    }
}
