//
//  Created by Frida Eriksson on 2025-05-26.
//

import Foundation
import SwiftUI

extension View {
    func withLogoutButton(authVM: AuthViewModel) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button(action: {
                        SoundPlayer.play("pop-1")
                        authVM.signOut()
                    }) {
                        Image(systemName: "arrow.right.to.line.circle.fill")
                            .foregroundStyle(.accent)
                    }
                }
            }
    }
}
