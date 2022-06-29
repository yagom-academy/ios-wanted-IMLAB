import Foundation
import FirebaseStorage

class FirebaseStorageManager{
    let storage = Storage.storage()
    
    func uploadRecord(){
        
    }
    
    func fetchRecordList(completion : @escaping([RecordFile])->()){
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
                                completion(recordFileList)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}
