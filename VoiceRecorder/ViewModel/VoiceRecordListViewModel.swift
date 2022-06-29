
import Foundation

struct VoiceRecordListViewModel{
    var voiceRecordList : [RecordFile]
    
    func numOfList() -> Int{
        return self.voiceRecordList.count
    }
    
    func ListAtIndex(index : Int)->VoiceRecordViewModel{
        return VoiceRecordViewModel(recordFile: voiceRecordList[index])
    }
}
