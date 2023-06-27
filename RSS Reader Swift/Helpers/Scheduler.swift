import Foundation
import UIKit

protocol SchedulerDelegate {
    func refreshFeedsUsingTimer()
}

class Scheduler {
    var delegate:SchedulerDelegate?
    private var timer: Timer?
    private var startTime: TimeInterval = 0
    private var backgroundTime: TimeInterval = 0
    private var interval: TimeInterval = 30
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    func startTimer() {
        print("Auto Fetching Data every \(interval) seconds")
        startTime = Date().timeIntervalSinceReferenceDate
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: interval,
                                         target: self,
                                         selector: #selector(timerFired),
                                         userInfo: nil,
                                         repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func timerFired() {
        print("Fetched Data at \(Date())")
        self.delegate?.refreshFeedsUsingTimer()
    }
    
    @objc func appDidEnterBackground() {
        print("App moved to background at \(Date())")
        stopTimer()
        backgroundTime = Date().timeIntervalSinceReferenceDate
    }
    
    @objc func appDidBecomeActive() {
        let elapsedTime = Date().timeIntervalSinceReferenceDate - startTime
        
        if elapsedTime >= interval || (backgroundTime > 0 && elapsedTime - (backgroundTime - startTime) >= interval) {
            timerFired()
            startTimer()
        } else {
            startTimer()
        }
        print("App moved to foreground at \(Date())")
    }

}
