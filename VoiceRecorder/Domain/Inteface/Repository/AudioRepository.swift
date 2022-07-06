//
//  AudioRepository.swift
//  VoiceRecorder
//
//  Created by 이윤주 on 2022/07/06.
//

import Foundation

protocol AudioRepository {

    associatedtype EndPoint

    func fetchAll() async throws -> [EndPoint]
    func download(from endPoint: EndPoint) async throws -> Data
    func putDataLocally(from endPoint: EndPoint) -> URL
    func upload()
    func delete(_ endPoint: EndPoint) async throws
}
