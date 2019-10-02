//
//  GetTranslation.swift
//  Baluchon
//
//  Created by Samahir Adi on 02/09/2019.
//  Copyright © 2019 Samahir Adi. All rights reserved.
//

import Foundation

class TranslationService {
    
    static var shared = TranslationService()
    private init() {}
    
    static var text: String {
        return ""
    }
    
    private let translationUrl = URL(string: "https://translation.googleapis.com/language/translate/v2")!
    
    private var session = URLSession(configuration: .default)
    
    init(session: URLSession) {
        self.session = session
    }
    
    func getTranslation(text: String, callback: @ escaping (Bool, _ translatedText: String?) -> Void) {
        guard let request = createTranslationRequest(textToTranslate: text) else {
            print ("request = nil")
            callback(false, nil)
            return
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
//                print ("request error \(error!.localizedDescription)")
                callback(false, nil)
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print ("http code response error")
                callback(false, nil)
                return
            }
            
            do {
                let translation = try JSONDecoder().decode(Translation.self, from: data)
                callback(true, translation.data.translations.first?.translatedText)
            } catch {
                print ("error while parsing response \(error)")
                callback(false, nil)
            }
        }
        task.resume()
    }
    
    private func createTranslationRequest(textToTranslate: String) -> URLRequest? {
        var component = URLComponents(url: translationUrl, resolvingAgainstBaseURL: false)
        component?.queryItems = [
            URLQueryItem (name: "key", value: "AIzaSyDM04XaaZrYiz-vGhxTHjGMo1HBgo2rNO0"),
            URLQueryItem (name: "q", value: textToTranslate),
            URLQueryItem (name: "source", value: "fr"),
            URLQueryItem (name: "target", value: "en"),
            URLQueryItem (name: "format", value: "text")
        ]
        guard let urlComponent = component, let url = urlComponent.url else {return nil}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
}