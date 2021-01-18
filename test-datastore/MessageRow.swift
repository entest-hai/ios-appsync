//
//  MessageView.swift
//  test-datastore
//
//  Created by hai on 15/1/21.
//  Copyright © 2021 biorithm. All rights reserved.
//

import SwiftUI

struct MessageRow: View {
    
    let message: Message 
    let isCurrentUser: Bool
    
    private var iconName: String {
        if let initial = message.senderName.first {
            return initial.lowercased()
        } else {
            return "questionmark"
        }
    }
    
    private var iconColor: Color {
        if isCurrentUser {
            return .blue
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .top){
                Image(systemName: "\(iconName).circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(iconColor)
                
                VStack(){
                    Text(message.senderName)
                        .font(.headline)
                    Text(message.body)
                        .font(.body)
                }
            }
            .padding(.horizontal, 16)
            
//            Divider().padding(.leading, 16)
        }
    }
}
