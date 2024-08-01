import SwiftUI

struct ContentView: View {
    @State private var isExpanded = true
    @StateObject private var nowPlayingModel = NowPlayingModel()
    
    @State private var isPaused: Bool = true
    
    init() {
        isPaused = !self.nowPlayingModel.isPlaying
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if isExpanded {
                    expandedView
                } else {
                    collapsedView
                }
            }
            .frame(width: isExpanded ? 344 : 274, height: isExpanded ? 135 : 32)
            .background(Color.black)
            .clipShape(BottomCornersRoundedRectangle(radius: 20))
            .animation(.easeInOut(duration: 0.3), value: isExpanded)
        }
        .onTapGesture {
            isExpanded.toggle()
            NotificationCenter.default.post(name: Notification.Name("ToggleWindowSize"), object: nil)
        }
    }
    
    var collapsedView: some View {
        HStack {
            if let artwork = nowPlayingModel.artwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.leading, 15)
            }
            Spacer()
            PlayingWave(isPlaying: $nowPlayingModel.isPlaying).padding(.vertical)
        }
        .frame(height: 32)
        .padding([.top, .bottom])
    }
    
    
    var expandedView: some View {
        VStack {
            HStack(alignment: .bottom) {
                if let artwork = nowPlayingModel.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(.leading, 10)

                    VStack(alignment: .leading) {
                        
                        
                        SlideText(text: $nowPlayingModel.title, frameWidth: 200, fontSize: 14, fontWeight: .bold)
                        
                        Text(nowPlayingModel.artistName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    PlayingWave(isPlaying: $nowPlayingModel.isPlaying)
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text(nowPlayingModel.formatTime(nowPlayingModel.elapsedTime))
                    .font(.caption)
                ProgressView(value: nowPlayingModel.elapsedTime, total: nowPlayingModel.duration)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.white))
                    .frame(height: 10)
                Text(nowPlayingModel.formatTime(nowPlayingModel.duration))
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            
            HStack {
                Button(action: {
                    nowPlayingModel.prevTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button styling
                .padding(.trailing, 10)
                .padding(.horizontal, 10)
                
                Button(action: {
                    nowPlayingModel.togglePlay()
                    self.isPaused.toggle()
                }) {
                    Image(systemName: self.isPaused ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(PlainButtonStyle()) // Remove default button styling
                .padding(.trailing, 10)
                .padding(.horizontal, 10)
                
                Button(action: {
                    nowPlayingModel.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 10)
            }
            .padding(.top, 10)
            .padding(.bottom, 15)
        }
        .padding(.top, 5)
    }
}

#Preview {
    ContentView()
}
