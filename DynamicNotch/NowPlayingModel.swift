import Foundation
import SwiftUI

class NowPlayingModel: ObservableObject {
    @Published var artistName: String = ""
    @Published var title: String = ""
    @Published var albumName: String = ""
    @Published var artwork: NSImage? = nil
    @Published var elapsedTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlaying: Bool = false
    
    private var lastRecordedElapsedTime: TimeInterval = 0
    
    private var timer: Timer?
    private var fetchCounter: Int = 0
    
    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerFired()
        }
        fetchNowPlayingInfo()
    }
    
    private func timerFired() {
        // Fetch now playing info every 1 second (10 * 0.1s interval)
        if isPlaying{
            self.elapsedTime += 0.1
        }
        fetchCounter += 1
        if fetchCounter >= 10 {
            fetchCounter = 0
            fetchNowPlayingInfo()
        }
    }
    

    
    private func debug() {
        print(artistName)
        print(title)
        print(albumName)
        print("Elapsed time: \(formatTime(elapsedTime))")
        print("Is playing: \(isPlaying)")
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func fetchNowPlayingInfo() {
        let frameworkPath = "/System/Library/PrivateFrameworks/MediaRemote.framework"
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, URL(fileURLWithPath: frameworkPath) as CFURL) else {
            print("Failed to create bundle for MediaRemote framework")
            return
        }
        
        guard let getNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return }
        
        typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
        let getNowPlayingInfo = unsafeBitCast(getNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        getNowPlayingInfo(DispatchQueue.global(qos: .background)) { [weak self] information in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                if let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String,
                   let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String,
                   let album = information["kMRMediaRemoteNowPlayingInfoAlbum"] as? String {
                    self.artistName = artist
                    self.title = title
                    self.albumName = album
                } else {
                    self.artistName = ""
                    self.title = ""
                    self.albumName = ""
                    self.artwork = nil
                }
                
                if let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                    self.artwork = NSImage(data: artworkData)
                }
                
                if let et = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? TimeInterval {
                    if self.lastRecordedElapsedTime != et || !self.isPlaying{
                        self.elapsedTime = et
                        self.lastRecordedElapsedTime = et
                    }
                }
                
                if let duration = information["kMRMediaRemoteNowPlayingInfoDuration"] as? TimeInterval {
                    self.duration = duration
                }
                
                if let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Float {
                    self.isPlaying = playbackRate > 0
                } else {
                    self.isPlaying = false
                }
                
                //self.debug()
            }
        }
    }
    
    private func sendCommand(commandType: UInt32) {
        let frameworkPath = "/System/Library/PrivateFrameworks/MediaRemote.framework"
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, URL(fileURLWithPath: frameworkPath) as CFURL) else {
            print("Failed to create bundle for MediaRemote framework")
            return
        }
        
        guard let sendCommandPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) else {
            print("Failed to get MRMediaRemoteSendCommand function pointer")
            return
        }
        
        typealias MRMediaRemoteSendCommandFunction = @convention(c) (UInt32) -> Void
        let sendCommand = unsafeBitCast(sendCommandPointer, to: MRMediaRemoteSendCommandFunction.self)
        
        print("Sending command with type: \(commandType)")
        sendCommand(commandType)
    }
    
    func togglePlay() {
        sendCommand(commandType: 0x00000002) // Play/Pause
    }
    
    func nextTrack() {
        sendCommand(commandType: 0x00000004)
    }
    
    func prevTrack() {
        sendCommand(commandType: 0x00000005)
    }
}
