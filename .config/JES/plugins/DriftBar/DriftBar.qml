import Quickshell
import JES.Helpers

BaseBar {
    JsonListen {
        id: cameraStream
        command: localPath(Qt.resolvedUrl("./camera-driftwm.sh stream-json"))
        debug: false
        
        onDataChanged: {
            cameraData = data
        }
    }
    
    JsonListen {
        id: activeWindowStream
        command: localPath(Qt.resolvedUrl("./active_window-driftwm.sh stream-window"))
        debug: false       
        onDataChanged: {
            activeWindow = typeof data === 'string' ? data : ""
        }
    }
    
    JsonListen {
        id: kbLayoutStream
        command: localPath(Qt.resolvedUrl("./kb_layout-driftwm.sh stream-layout"))
        debug: false
        
        onDataChanged: {
            kbLayout = typeof data === 'string' ? data : ""
        }
    }   
    JsonListen {
        id: batteryStream
        command: localPath(Qt.resolvedUrl("./battery.sh"))
        debug: false
        
        onDataChanged: {
            batteryData = data
        }
    }   
}
