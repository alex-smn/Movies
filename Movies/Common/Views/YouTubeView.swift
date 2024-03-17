//
//  YouTubeView.swift
//  Movies
//
//  Created by Alexander Livshits on 16/03/2024.
//

import SwiftUI
import WebKit

struct YouTubeView: UIViewRepresentable {
    var videoId: String
    
    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        let request = URLRequest(url: URL(string: "https://youtube.com/embed/\(videoId)")!)
        webView.allowsLinkPreview = true
        webView.allowsBackForwardNavigationGestures = true
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}

