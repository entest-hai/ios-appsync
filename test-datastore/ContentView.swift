//
//  ContentView.swift
//  test-datastore
//
//  Created by hai on 15/1/21.
//  Copyright © 2021 biorithm. All rights reserved.
//

import SwiftUI
import Amplify
import Combine

struct ContentView: View {
    
    @State var text = String()
    @ObservedObject var sot = SourceOfTruth()
    let currentUser = "Minh"
    
    init() {
        
        self.sot.getMessages()
        self.sot.myObserve("Minh")
//        self.sot.observeMessages()
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(sot.messages){ message in
                    MessageRow(
                        message: message,
                        isCurrentUser: message.senderName == self.currentUser
                    )
                }
            }
            HStack{
                TextField("Enter message", text: $text)
                Button("Send", action: {self.didTapSend()
                })
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.purple)
            }
        }
    .onAppear(perform: {
//        self.subscribeToPosts()
    })
    }

    
    func didTapSend() {
        let message = Message(senderName: self.currentUser, body: self.text, creationDate: .now())
        self.sot.send(message)
        print("tap send", self.text)
    }
    
    // In your type declaration, declare a cancellable to hold onto the subscription
    @State var postsSubscription: AnyCancellable?
    
    // Then in the body of your code, subscribe to the publisher
    func subscribeToPosts() {
        postsSubscription = Amplify.DataStore.publisher(for: Message.self).sink(
            receiveCompletion: {
                print($0)
        }, receiveValue: { event in
            do {
                let message = try event.decodeModel(as: Message.self)
                self.sot.messages.append(message)
                print(message)
            } catch {
                print(error)
            }
        })
    }
}

