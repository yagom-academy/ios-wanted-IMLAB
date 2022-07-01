import Foundation
import FirebaseStorage


class FirebaseStorageManager{
    let storage = Storage.storage()
    
    func uploadRecord(completion : @escaping ()->Void){
        print("upload file")
        //파일 위치
        let localFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("myRecoding.m4a")
        print(localFile)
        let meta = StorageMetadata.init()
        meta.contentType = "m4a"
        //현재 날짜, 시간 기준으로 파일 이름
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH:mm:ss"
        let nowDate = dateFormatter.string(from: Date())
        let fileName = "voiceRecords_\(nowDate).m4a"
        
        //현재 날짜 시간으로 저장
        let firebaseRef = storage.reference().child("record").child("\(fileName)")
        
        firebaseRef.putFile(from: localFile, metadata: meta) { meta, error in
            if let error = error{
                print("upload file error \(error.localizedDescription)")
                return
            }
            print("complete upload file \(meta)")
            //스토리지에 저장 완료시 테이블 뷰 업데이트
            completion()
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
    
    func deleteRecord(fileName : String, completion : @escaping()->Void){
        let storageRef = storage.reference().child("record/\(fileName).m4a")
        storageRef.delete { error in
            if let error = error{
                error.localizedDescription
            }else{
                print("Delete Success")
                completion()
            }
        }
    }
    
}
