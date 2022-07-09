
import Foundation

struct VoiceRecordViewModel{
    
    var recordFile : RecordFile
    
    init(recordFile : RecordFile){
        self.recordFile = recordFile
    }
    
    var fileName : String{
        return String(recordFile.fileName.split(separator: ".")[0].split(separator: "@")[0])
    }
    
    var fileLength : String{
        return String(recordFile.fileName.split(separator: ".")[0].split(separator: "@")[1])
    }
    
    var url : URL{
        return recordFile.url
    }
}
