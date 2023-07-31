//
//  ReplyCounter.swift
//  damus
//
//  Created by William Casarin on 2023-04-04.
//

import Foundation

class ReplyCounter {
    private var replies: [NoteId: Int]
    private var counted: Set<NoteId>
    private var our_replies: [NoteId: NostrEvent]
    private let our_pubkey: Pubkey

    init(our_pubkey: Pubkey) {
        self.our_pubkey = our_pubkey
        replies = [:]
        counted = Set()
        our_replies = [:]
    }
    
    func our_reply(_ evid: NoteId) -> NostrEvent? {
        return our_replies[evid]
    }
    
    func get_replies(_ evid: NoteId) -> Int {
        return replies[evid] ?? 0
    }
    
    func count_replies(_ event: NostrEvent) {
        guard event.is_textlike else {
            return
        }
        
        if counted.contains(event.id) {
            return
        }
        
        counted.insert(event.id)
        
        for reply in event.direct_replies(nil) {
            if event.pubkey == our_pubkey {
                self.our_replies[reply.ref_id] = event
            }
            
            if replies[reply.ref_id] != nil {
                replies[reply.ref_id] = replies[reply.ref_id]! + 1
            } else {
                replies[reply.ref_id] = 1
            }
        }
    }
}
