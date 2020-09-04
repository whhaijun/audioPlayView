//
//  CMSAudioEnum.swift
//  CMSAudio
//
//  Created by admin on 2020/9/3.
//  Copyright © 2020 Sihj. All rights reserved.
//

import Foundation

public enum CMSAudioType {
    case AudioTypeURL
    case AudioTypeLocal
}

public enum CMSAudioStatus {
    case AudioStatusPlaying
    case AudioStatusPaused
    case AudioStatusFailed
    case AudioStatusStopped
    case AudioStatusFinished
}
