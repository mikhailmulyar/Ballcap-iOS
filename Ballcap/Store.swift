//
//  Store.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

internal final class Store {
    
    static let shared: Store = Store()
    
    lazy var cache: NSCache<NSString, NSDictionary> = {
        let cache: NSCache<NSString, NSDictionary> = NSCache()
        return cache
    }()
    
    func get<Document: Documentable, Model: Modelable & Codable>(documentType: Document.Type, reference: DocumentReference) -> Document? where Document.Model == Model {
        guard let data: Model = self.get(modelType: Model.self, reference: reference) else { return nil }
        return documentType.init(id: reference.documentID, from: data as! [String : Any], collectionReference: reference.parent)
    }
    
    func get<T: Codable & Modelable>(modelType: T.Type, reference: DocumentReference) -> T? {
        guard let data: T = self.cache.object(forKey: reference.path as NSString) as? T else { return nil }
        return data
    }
    
    func set<Document: Documentable, Model: Modelable & Codable>(_ document: Document, reference: DocumentReference? = nil) throws where Document.Model == Model {
        do {
            let data: [String: Any] = try Firestore.Encoder().encode(document.data)
            let reference: DocumentReference = reference ?? document.documentReference
            self.set(key: reference.path, data: data)
        } catch (let error) {
            throw error
        }
    }
    
    func set(key: String, data: [String: Any]) {
        self.cache.setObject(data as NSDictionary, forKey: key as NSString)
    }

    func delete(reference: DocumentReference) {
        self.delete(key: reference.path)
    }

    func delete(key: String) {
        self.cache.removeObject(forKey: key as NSString)
    }
}
