import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var translationHistory: [String] = []

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter text to translate", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(5)

                Button("Translate") {
                    translateText(inputText, from: "en", to: "it")
                }
                .padding()

                TextField("Translation", text: $translatedText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(5)
                Button("Clear History") {
                                // Clear the local translation history
                                self.translationHistory.removeAll()
                                clearFirestoreHistory()
                                
                            }
                            .padding()
                            .foregroundColor(.red)

                List(translationHistory, id: \.self) { item in
                    Text(item)
                }
            }
            .navigationBarTitle("TranslationMe")
            .onAppear {
                fetchTranslationHistory()
            }
        }
    }

    // Ensure this method is within the ContentView struct
    func translateText(_ text: String, from sourceLang: String, to targetLang: String) {
        let query = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.mymemory.translated.net/get?q=\(query)&langpair=\(sourceLang)|\(targetLang)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [self] data, _, _ in
            if let data = data, let response = try? JSONDecoder().decode(TranslationResponse.self, from: data) {
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        self.translatedText = response.responseData.translatedText
                        // If you're appending to history, ensure it's also within this block
                    }

                    self.saveTranslation(originalText: text, translatedText: response.responseData.translatedText)
                }
            }
        }.resume()
    }
    
    // Ensure this method is also within the ContentView struct
    func saveTranslation(originalText: String, translatedText: String) {
        FirestoreService.shared.saveTranslation(originalText: originalText, translatedText: translatedText) { error in
            if let error = error {
                print("Error saving translation: \(error.localizedDescription)")
            } else {
                // Refresh your history view to include the new translation
                self.fetchTranslationHistory()
            }
        }
    }

    // Ensure this method is within the ContentView struct
    func fetchTranslationHistory() {
        FirestoreService.shared.fetchTranslationHistory { [self] history in
            self.translationHistory = history.map { "\($0.originalText) -> \($0.translatedText)" }
        }
    }
    func clearFirestoreHistory() {
        let db = Firestore.firestore()
        db.collection("translations").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            for document in documents {
                db.collection("translations").document(document.documentID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err.localizedDescription)")
                    } else {
                        print("Document successfully removed")
                    }
                }
            }
        }
    }

}


        
        
    // Your TranslationResponse, ResponseData, and Match structs remain unchanged and are correctly set up.
    
    struct TranslationResponse: Codable {
        let responseData: ResponseData
        let responseStatus: Int
        let matches: [Match]
    }
    
    struct ResponseData: Codable {
        let translatedText: String
        let match: Double
    }
    
    struct Match: Codable {
        let id: String
        let segment: String
        let translation: String
        let source: String
        let target: String
        let quality: Int
        let usageCount: Int
        let subject: String
        let createdBy: String
        let lastUpdatedBy: String
        let createDate: String
        let lastUpdateDate: String
        let match: Double
        
        enum CodingKeys: String, CodingKey {
            case id, segment, translation, source, target, quality, subject, match
            case usageCount = "usage-count"
            case createdBy = "created-by"
            case lastUpdatedBy = "last-updated-by"
            case createDate = "create-date"
            case lastUpdateDate = "last-update-date"
        }
    }
    
