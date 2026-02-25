import Photos
import SwiftUI
import Combine

final class PhotoLibraryManager: ObservableObject {

    static let shared = PhotoLibraryManager()

    @Published var images: [UIImage] = []

    private init() {
        requestPermission()
        fetchPhotos()
    }

    private func requestPermission() {
        PHPhotoLibrary.requestAuthorization { _ in }
    }

    func savePhoto(_ data: Data) {
        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: data, options: nil)
        } completionHandler: { _, _ in
            self.fetchPhotos()
        }
    }

    func fetchPhotos() {
        images.removeAll()

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let assets = PHAsset.fetchAssets(with: .image, options: options)

        assets.enumerateObjects { asset, _, _ in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 500, height: 500),
                contentMode: .aspectFill,
                options: nil
            ) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self.images.append(image)
                    }
                }
            }
        }
    }
}
