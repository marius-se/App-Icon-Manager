//
//  IconViewModel.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 21.12.20.
//

import AppKit
import Combine

class IconViewModel: ObservableObject {
    @Published private (set) var image: NSImage?
    let title: String
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(imageURL: URL, title: String) {
        self.title = title
        fetchImage(fromURL: imageURL)
    }
    
    func fetchImage(fromURL url: URL) {
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished: break
                }
            } receiveValue: { [weak self] (result) in
                guard let self = self else { return }
                self.image = NSImage(data: result.data)
            }
            .store(in: &cancellables)
    }
}
