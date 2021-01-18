//
//  SourceOfTruth.swift
//  test-datastore
//
//  Created by hai on 15/1/21.
//  Copyright © 2021 biorithm. All rights reserved.
//

import SwiftUI
import Amplify
import Foundation
import Combine

class SourceOfTruth: ObservableObject {
    
    @Published var messages = [Message]()
    
    func send(_ message: Message){
        Amplify.API.mutate(request: .create(message), listener: { mutationResult in
            switch mutationResult {
            case .success(let createResult):
                switch createResult {
                case .success:
                    print("successfully created message")
                case .failure(let error):
                    print(error)
                }
            case .failure(let apiError):
                print("error ", apiError)
            }
        })
    }
    
    func getMessages() {
        Amplify.API.query(request: .list(Message.self)){[weak self] result in
            do {
                let messages = try result.get().get()
                DispatchQueue.main.async {
                    self?.messages = messages
                }
            } catch {
                print(error)
            }
        }
    }
    
    var subscription: GraphQLSubscriptionOperation<Message>?
    func observeMessages() {
        subscription = Amplify.API.subscribe(
            request: .subscription(of: Message.self, type: .onCreate),
            valueListener: { subscriptionEvent in
                switch subscriptionEvent {
                case .connection(let connectionState):
                    print("connection state:", connectionState)
                    
                case .data(let dataResult):
                    do {
                        let message = try dataResult.get()
                        
                        DispatchQueue.main.async {
                            self.messages.append(message)
                        }
                    } catch {
                        print(error)
                    }
                }
        },
            completionListener: { completion in
                
        }
        )
    }
    
    var mysub: GraphQLSubscriptionOperation<Message>?
    func myObserve(_ senderName: String) {
        let operationName = "onCreateMessageFilter"
        let document = "subscription onCreateMessageFilter($senderName: String!){ \(operationName)(senderName: $senderName){ id senderName body creationDate} }"
        mysub = Amplify.API.subscribe(
            request: GraphQLRequest<Message>(
                                    document: document,
                                    variables: ["senderName": senderName],
                                    responseType: Message.self,
                                    decodePath: "onCreateMessageFilter"),
            valueListener: { subscriptionEvent in
                print("mysub")
                switch subscriptionEvent {
                case .connection(let connectionState):
                    print("connection state:", connectionState)
                    
                case .data(let dataResult):
                    do {
                        let message = try dataResult.get()
                        print("sub \(message)")
                        
                        DispatchQueue.main.async {
                            self.messages.append(message)
                        }
                    } catch {
                        print(error)
                    }
                }
        },
            completionListener: { completion in
        }
        )
    }
}
