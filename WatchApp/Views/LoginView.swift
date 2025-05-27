//
//  LoginView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-19.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = UserDefaults.standard.bool(forKey: "rememberMe")
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var showSignUpSheet = false
    @State private var showResetPasswordSheet: Bool = false
    
    
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
                    .fill(.red)
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("logo_w_pop_face")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                    
                    Text("WATCHAPP")
                        .font(.largeTitle)
                        .fontDesign(.monospaced)
                        .fontWeight(.heavy)
                        .foregroundColor(.popcornYellow)
                    
                    HStack{
                        Spacer()
                        
                        Button(action: {
                            authVM.signInAnonymously()
                        }) {
                            Image(systemName: "person.fill.questionmark")
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                        }
                        .padding(.trailing, 26)
                    }
                    
                    VStack(alignment: .leading, spacing: 4){
                        ZStack(alignment: .trailing) {
                            TextField("Email",text: $email)
                                .padding()
                                .padding(.trailing, 30)
                                .background(Color.white.opacity(1.0))
                                .cornerRadius(8)
                                .foregroundColor(.gold)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            
                            if !email.isEmpty {
                                Button(action: {email = ""
                                    emailError = nil
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundStyle(.gold)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                        
                        if let emailError = emailError {
                            Text(emailError)
                                .foregroundStyle(.white)
                                .font(.caption)
                                .padding(.horizontal, 4)
                        }
                        
                        if let authError = authVM.errorMessage {
                            Text(authError)
                                .foregroundStyle(.white)
                                .font(.caption)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 4) {
                    ZStack(alignment: .trailing) {
                        SecureField("Password", text: $password)
                            .padding()
                            .padding(.trailing, 30)
                            .background(Color.white.opacity(1.0))
                            .cornerRadius(8)
                            .foregroundColor(.gold)
                        
                    if !password.isEmpty {
                        Button(action: {password = ""
                            passwordError = nil
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(.gold)
                                .padding(.trailing, 8)
                        }
                    }
                }
                    
                    if let passwordError = passwordError {
                        Text(passwordError)
                            .foregroundStyle(.white)
                            .font(.caption)
                            .padding(.horizontal, 4)
                    }
                    
                    if let authError = authVM.errorMessage {
                        Text(authError)
                            .foregroundStyle(.white)
                            .font(.caption)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)
                    
                    HStack{
                        Button(action: {
                            rememberMe.toggle()
                            UserDefaults.standard.set(rememberMe, forKey: "rememberMe")
                        }) {
                            HStack{
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(.gold)
                                    .font(.system(size: 20))
                                Text("Remember Me")
                                    .foregroundStyle(.gold)
                                    .font(.headline)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            SoundPlayer.play("pop")
                            showResetPasswordSheet = true
                        }) {
                            Text("Forgot Password?")
                                .foregroundStyle(.gold)
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        SoundPlayer.play("pop")
                        showSignUpSheet = true
                    }){
                        Text("Create Account!")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showSignUpSheet) {
                        SignUpView(authVM: authVM)
                        .presentationDetents([.fraction(0.5)])
                        .presentationDragIndicator(.visible)
                    }

                    Button(action: {
                        SoundPlayer.play("click")
                        authVM.signInWithEmail(email: email, password: password)
                    }) {
                        Text("LOGIN")
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .foregroundColor(.gold)
                            .font(.title3)
                            .fontWeight(.bold)
                            .background(Color.black.opacity(0.9))
                            .cornerRadius(40)
                            .shadow(radius: 30)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        print("google sign in")
                    }){
                        Image("google_sign_in")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 50)
                            .padding()
                    }
                    .padding(.horizontal)
                    
                }
            }
            .sheet(isPresented: $showResetPasswordSheet) {
                ResetPasswordView(authVM: authVM)
                    .presentationDetents([.fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                if UserDefaults.standard.bool(forKey: "rememberMe") {
                    if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail") {
                        email = savedEmail
                    }
                    if let savedPassword = KeychainService.shared.retrieve(forKey: "savedPassword") {
                        password = savedPassword
                    }
                }
            }
        }
    }
}


#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
