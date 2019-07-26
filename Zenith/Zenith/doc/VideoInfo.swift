//
//  VideoInfo.swift
//  Zenith
//
//  Created by simba on 7/26/19.
//  Copyright © 2019 simba. All rights reserved.
//

import Foundation


struct VideoInfo {
    
    var subject: String!
    var locked: Bool!
    var loopVideo: String!
    var swipeVideo: String!
    
    var rightLink: LinkInfo!
    var leftLink: LinkInfo
    
    var state: Int!
    
    init(subject: String, locked: Bool, loopVideo: String, swipeVideo: String, rightLink: LinkInfo, leftLink: LinkInfo, state: Int) {
        
        self.subject = subject
        self.locked = locked
        self.loopVideo = loopVideo
        self.swipeVideo = swipeVideo
        self.rightLink = rightLink
        self.leftLink = leftLink
        
        self.state = state
    }
}
