//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by VinhHoang on 20/02/2023.
//

import SwiftUI
import Combine

class ImageLoader {
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func downloadImageWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map { [weak self] data, response in
                    self?.handleResponse(data: data, response: response)
            }
            .mapError({ $0 })
            .eraseToAnyPublisher()
            
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
    
    
}

class ViewModel: ObservableObject {
    @Published var image: UIImage?
    
    var cancellables = Set<AnyCancellable>()
    let loader = ImageLoader()
    
    func fetchImage() async {
        /*
         
//        loader.downloadImageWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//            } receiveValue: { [weak self] image in
//                self?.image = image
//            }
//            .store(in: &cancellables)
         
        */
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    @StateObject private var viewModel = ViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
            
        }
        
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
