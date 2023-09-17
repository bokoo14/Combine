//
//  WebView.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // WKNavigationDelegate 설정
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // 웹 페이지 로딩이 완료되었을 때 호출됩니다.
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 추가적인 처리나 로딩 완료 후 동작을 수행할 수 있습니다.
        }
    }
}


struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(urlString: "https://music.apple.com/us/artist/rod-wave/1140623439")
    }
}
