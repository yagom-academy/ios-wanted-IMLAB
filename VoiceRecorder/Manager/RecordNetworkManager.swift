//
//  RecordNetworkManager.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import FirebaseStorage
import Foundation

protocol NetworkManager {
    func saveRecord(filename: String, completion: ((Bool) -> Void)?)
    func getRecordData(filename: String, completion: ((Result<Data, CustomNetworkError>) -> Void)?)
    func getRecordMetaData(filename: String, completion: ((StorageMetadata?) -> Void)?)
    func getRecordList(completion: ((Result<[String], CustomNetworkError>) -> Void)?)
    func deleteRecord(filename: String, completion: ((Bool) -> Void)?)
}

struct RecordNetworkManager: NetworkManager {
    let storageRef = Storage.storage().reference().child("record")

    func saveRecord(filename: String, completion: ((Bool) -> Void)? = nil) {
        let localRecordFileURL = Config.getRecordFilePath()

        let recordRef = storageRef.child(filename)

        do {
            let data = try Data(contentsOf: localRecordFileURL)
            DispatchQueue.global().async {
                recordRef.putData(data, metadata: nil) { metadata, error in
                    guard error == nil,
                          let metadata = metadata else {
                        print("fail")
                        DispatchQueue.main.async {
                            completion?(false)
                        }
                        return
                    }
                    print("success!", metadata)
                    DispatchQueue.main.async {
                        completion?(true)
                    }
                }
            }
        } catch {
            print("error!")
            completion?(false)
        }
    }

    func getRecordData(filename: String, completion: ((Result<Data, CustomNetworkError>) -> Void)? = nil) {
        let recordRef = storageRef.child(filename)
        DispatchQueue.global().async {
            recordRef.getData(maxSize: 1500000) { data, error in
                if let error = error {
                    print("download error: ", error)
                    DispatchQueue.main.async {
                        completion?(.failure(CustomNetworkError.failLoadData))
                    }
                } else {
                    guard let data = data else {
                        completion?(.failure(CustomNetworkError.noData))
                        return
                    }
                    print("success download data!")
                        completion?(.success(data))
                }
            }
        }
    }

    func getRecordMetaData(filename: String, completion: ((StorageMetadata?) -> Void)? = nil) {
        let recordRef = storageRef.child(filename)

        DispatchQueue.global().async {
            recordRef.getMetadata { metadata, error in
                if let error = error {
                    print("download error: ", error)
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                } else {
                    print("success download metaData!")
                    completion?(metadata)
                }
            }
        }
    }

    func getRecordList(completion: ((Result<[String], CustomNetworkError>) -> Void)? = nil) {
        DispatchQueue.global().async {
            storageRef.listAll { data, error in
                if let error = error {
                    print("load list error!", error)
                    DispatchQueue.main.async {
                        completion?(.failure(CustomNetworkError.failLoadData))
                    }
                    return
                }
                guard let data = data else {
                    print("no data!")
                    DispatchQueue.main.async {
                        completion?(.failure(CustomNetworkError.noData))
                    }
                    return
                }

                // MARK: Prefix가 뭐지?

                for _prefix in data.prefixes {
                    print(_prefix)
                }

                let result = data.items.map { $0.name }
                completion?(.success(result))
            }
        }
    }

    func deleteRecord(filename: String, completion: ((Bool) -> Void)? = nil) {
        let recordRef = storageRef.child(filename)
        DispatchQueue.global().async {
            recordRef.delete { error in
                if let error = error {
                    print("delete error!", error)
                    DispatchQueue.main.async {
                        completion?(false)
                    }
                } else {
                    print("success delete file!")
                    DispatchQueue.main.async {
                        completion?(true)
                    }
                }
            }
        }
    }
}
