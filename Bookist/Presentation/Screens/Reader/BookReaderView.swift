import SwiftUI
import UIKit
import Combine

// MARK: - Readium Imports
import ReadiumShared
import ReadiumStreamer
import ReadiumNavigator
import ReadiumAdapterGCDWebServer

struct BookReaderView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ReadiumReaderViewModel()
    
    var body: some View {
        ZStack {
            if let publication = viewModel.publication, let server = viewModel.httpServer {
                ReadiumNavigatorWrapper(publication: publication, httpServer: server)
                    .edgesIgnoringSafeArea(.bottom) // Keep top safe area for nav bar
            } else if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Preparing book to read...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("Unable to open book")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Try Again") {
                        Task { await viewModel.loadBook(book: book) }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Close") {
                        dismiss()
                    }
                    .padding(.top)
                }
            }
        }
        .task {
            await viewModel.loadBook(book: book)
        }
        .onDisappear {
            viewModel.cleanup()
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .tint(.black) // Ensure back button is black
    }
}

// MARK: - ViewModel
@MainActor
class ReadiumReaderViewModel: ObservableObject {
    @Published var publication: Publication?
    @Published var isLoading = false
    @Published var error: String?
    @Published var httpServer: GCDHTTPServer?
    
    private var publicationOpener: PublicationOpener
    private var assetRetriever: AssetRetriever
    
    init() {
        let httpClient = DefaultHTTPClient()
        let assetRetriever = AssetRetriever(httpClient: httpClient)
        self.assetRetriever = assetRetriever
        
        // Use CompositePublicationParser with EPUBParser to avoid PDF dependency
        let parser = CompositePublicationParser([EPUBParser()])
        
        self.publicationOpener = PublicationOpener(
            parser: parser,
            contentProtections: []
        )
    }
    
    func loadBook(book: Book) async {
        // 1. Check for EPUB format
        guard let url = book.formats.epubUrl else {
            self.error = "This book is not available in EPUB format."
            return
        }
        
        self.isLoading = true
        self.error = nil
        
        do {
            // 2. Download the file
            let localURL = try await downloadFile(from: url, title: book.title)
            
            // 3. Setup Server
            // GCDHTTPServer is the correct class in 3.x adapter
            let server = GCDHTTPServer(assetRetriever: assetRetriever)
            self.httpServer = server
            
            // 4. Open the Publication
            // Convert URL to Readium's FileURL
            guard let fileURL = FileURL(string: localURL.absoluteString) else {
                throw URLError(.badURL)
            }
            
            let assetResult = await assetRetriever.retrieve(url: fileURL)
            
            switch assetResult {
            case .success(let asset):
                let openResult = await publicationOpener.open(asset: asset, allowUserInteraction: false, sender: nil as Any?)
                
                switch openResult {
                case .success(let publication):
                    self.publication = publication
                    self.isLoading = false
                case .failure(let error):
                    throw error
                }
            case .failure(let error):
                throw error
            }
            
        } catch {
            print("Readium Error: \(error)")
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
    
    private func downloadFile(from url: URL, title: String) async throws -> URL {
        let sanitizedTitle = title.components(separatedBy: .alphanumerics.inverted).joined(separator: "_")
        let fileName = "\(sanitizedTitle).epub"
        
        // Use Document Directory for persistence
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw URLError(.fileDoesNotExist)
        }
        
        let destinationURL = documentsURL.appendingPathComponent(fileName)
        
        // Check if file already exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("Book already downloaded: \(destinationURL.path)")
            return destinationURL
        }
        
        // Download if not exists
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        try FileManager.default.moveItem(at: tempURL, to: destinationURL)
        return destinationURL
    }
    
    func cleanup() {
        publication?.close()
        publication = nil
        httpServer = nil
    }
}

// MARK: - UIViewControllerRepresentable
struct ReadiumNavigatorWrapper: UIViewControllerRepresentable {
    let publication: Publication
    let httpServer: GCDHTTPServer
    
    func makeUIViewController(context: Context) -> EPUBNavigatorViewController {
        do {
            // Create the EPUB Navigator
            let config = EPUBNavigatorViewController.Configuration()
            
            let navigator = try EPUBNavigatorViewController(
                publication: publication,
                initialLocation: nil,
                config: config,
                httpServer: httpServer
            )
            
            return navigator
        } catch {
            fatalError("Failed to initialize reader: \(error.localizedDescription)")
        }
    }
    
    func updateUIViewController(_ uiViewController: EPUBNavigatorViewController, context: Context) {
        // Updates can be handled here (e.g. changing theme)
    }
}


