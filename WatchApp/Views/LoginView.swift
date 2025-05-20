//
//  LoginView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-19.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authVM = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.BG.edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.6))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: 90))
                        path.addLine(to: CGPoint(x: -150, y: 950))
                        path.closeSubpath()
                    }
                    .fill(Color.red)
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    //sätt in logga
                    Image("logo_w_pop_face")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                    
                    Text("WATCHAPP")
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                        .fontWeight(.heavy)
                        .foregroundColor(.popcornYellow)
                    
                    HStack {
                        Button("LOGIN"){
                            authVM.signInAnonymously()
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .foregroundColor(.gold)
                        .font(.title3)
                        .fontWeight(.bold)
                        .background(Color.black.opacity(0.9))
                        .cornerRadius(40)
                        .shadow(radius: 30)
                    }
                }
      
                .padding(.horizontal)
                .navigationDestination(isPresented: $authVM.isSignedIn) {
                    MovieListView()
                }
            }
        }
    }
}



#Preview {
    LoginView()
}
