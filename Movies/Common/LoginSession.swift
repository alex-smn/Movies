//
//  LoginSession.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import AuthenticationServices

class LoginSession: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    var session: ASWebAuthenticationSession?
    private var continuation: CheckedContinuation<Bool, Never>?
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
    
    @MainActor
    func signIn(token: String) async -> Bool {
        let authUrl = URL(string: "\(Constants.tokenApproveUrl)\(token)?redirect_to=tmdbhome://")
        let scheme = "tmdbhome"
        
        self.session = ASWebAuthenticationSession(url: authUrl!, callbackURLScheme: scheme) { [weak self] callbackUrl, error in
            defer {
                self?.continuation = nil
            }
            
            guard 
                error == nil, 
                let successUrl = callbackUrl,
                !successUrl.absoluteString.contains("denied")
            else {
                self?.continuation?.resume(with: .success(false))
                return
            }
                        
            self?.continuation?.resume(with: .success(true))
        }
        
        session?.presentationContextProvider = self
        session?.start()
        
        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            self.continuation = continuation
        }
    }
}
