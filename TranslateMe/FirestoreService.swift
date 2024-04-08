import Foundation
import Firebase
import FirebaseFirestore

class FirestoreService {
    private let db = Firestore.firestore()
    
    // Singleton instance
    static let shared = FirestoreService()
    
    private init() {} // Private initializer to ensure singleton usage
    
    // Function to save a translation
    func saveTranslation(originalText: String, translatedText: String, completion: @escaping (Error?) -> Void) {
        let translationData: [String: Any] = [
            "originalText": originalText,
            "translatedText": translatedText,
            "timestamp": Timestamp()
        ]
        
        db.collection("translations").addDocument(data: translationData) { error in
            completion(error)
        }
    }
    
    // Function to fetch translation history
    func fetchTranslationHistory(completion: @escaping ([TranslationHistory]) -> Void) {
        db.collection("translations").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            var history: [TranslationHistory] = []
            
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    let data = document.data()
                    let originalText = data["originalText"] as? String ?? ""
                    let translatedText = data["translatedText"] as? String ?? ""
                    // You can also fetch the timestamp if needed
                    
                    let translationHistory = TranslationHistory(originalText: originalText, translatedText: translatedText)
                    history.append(translationHistory)
                }
            }
            
            completion(history)
        }
    }
}

// Model for translation history
struct TranslationHistory: Identifiable {
    let id = UUID() // Generate a unique ID for each history item
    let originalText: String
    let translatedText: String
}

