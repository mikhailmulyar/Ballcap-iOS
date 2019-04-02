//
//  Batch.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/01.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public final class Batch {

    private var writeBatch: FirebaseFirestore.WriteBatch

    private var storage: [String: [String: Any]] = [:]

    private var isCommitted: Bool = false

    init(firestore: Firestore = Firestore.firestore()) {
        self.writeBatch = firestore.batch()
    }

    @discardableResult
    func save<T: Encodable>(document: Document<T>, reference: DocumentReference? = nil) -> WriteBatch {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data: [String: Any] = try Firestore.Encoder().encode(document.data!)
            if document.isIncludedInTimestamp {
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self.storage[reference.path] = data
            return self.writeBatch.setData(data, forDocument: reference)
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    func update<T: Encodable>(document: Document<T>, reference: DocumentReference? = nil) -> WriteBatch {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data = try Firestore.Encoder().encode(document.data!)
            if document.isIncludedInTimestamp {
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self.storage[reference.path] = data
            return self.writeBatch.updateData(data, forDocument: reference)
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    func delete<T: Encodable>(document: Document<T>) -> WriteBatch {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        return self.writeBatch.deleteDocument(document.documentReference)
    }

    func commit(_ completion: ((Error?) -> Void)? = nil) {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        self.writeBatch.commit { [weak self] (error) in
            if let error = error {
                completion?(error)
                return
            }
            self?.storage.forEach({ key, data in
                Store.shared.set(key: key, data: data)
            })
            self?.storage = [:]
            completion?(nil)
        }
    }
}
