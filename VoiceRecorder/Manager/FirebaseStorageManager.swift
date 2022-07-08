import Foundation
import FirebaseStorage

class FirebaseStorageManager {
    let storage = Storage.storage()
    
    func uploadRecord(time : String, completion : @escaping ()->Void){
        //파일 위치
        let localFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myRecoding.m4a")
        let imageFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("myWaveForm.png")
        print(imageFile)
        let meta = StorageMetadata.init()
        meta.contentType = "m4a"
        let imageMeta = StorageMetadata.init()
        imageMeta.contentType = "image/png"
        //현재 날짜, 시간 기준으로 파일 이름
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let nowDate = dateFormatter.string(from: Date())
        let fileName = "voiceRecords_\(nowDate)"
        
        //현재 날짜 시간으로 저장
        let firebaseRef = storage.reference().child("record").child("\(fileName)@\(time).m4a")
        //이미지 파일 저장 위치
        let imageRef = storage.reference().child("waveForm").child("\(fileName)WaveForm.png")
        
        
        firebaseRef.putFile(from: localFile, metadata: meta) { meta, error in
            if let error = error{
                print("upload file error \(error.localizedDescription)")
                return
            }
            imageRef.putFile(from: imageFile, metadata: imageMeta){ meta, error in
                if let error = error{
                    print("upload file error \(error.localizedDescription)")
                    print(error)
                    return
                }
                completion()
            }
        }
    }
    
    func fetchRecordList(completion : @escaping([RecordFile]?)->()){
        let storageRef = storage.reference().child("record")
        var recordFileList : [RecordFile] = []
        //파일 리스트를 가져옴
        storageRef.listAll { result, error in
            if let error = error{
                print(error)
            }
            print("LIST : \(result!)")
            //가져온 리스트들
            if let result = result {
                let resultCount = result.items.count
                var count = 0
                result.items.map { item in
                    //리스트에서 파일 이름 추출
                    let fileName = item.name
                    //리스트에서 파일 다운로드 url 추출
                    item.downloadURL { url, error in
                        if let url = url{
                            recordFileList.append(RecordFile(fileName: fileName, url: url))
                            count += 1
                            if count == resultCount{
                                //가장 최근에 녹음한것이 위로 올라가도록 정렬
                                recordFileList.sort {$0.fileName > $1.fileName}
                                completion(recordFileList)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteRecord(fileName : String, fileLength : String, completion : @escaping()->Void){
        let storageRef = storage.reference().child("record/\(fileName)@\(fileLength).m4a")
        let imageRef = storage.reference().child("waveForm/\(fileName)WaveForm.png")
        storageRef.delete { error in
            if let error = error{
                print(error.localizedDescription)
            }else{
                imageRef.delete { error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    completion()
                }
            }
        }
    }
    
    deinit {
        print("Close firebase manager")
    }
}
