// 设置bridge
var bridge

function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        return callback(WebViewJavascriptBridge);
    }
    if (window.WVJBCallbacks) {
        return window.WVJBCallbacks.push(callback);
    }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function () {
        document.documentElement.removeChild(WVJBIframe)
    }, 0)
}
setupWebViewJavascriptBridge(function (bridge) {
                             self.bridge = bridge
                             bridge.registerHandler('changeTitle', function (data, responseCallback) {
                                                    var titleElement = document.getElementsByClassName('head')[0];
                                                    titleElement.innerText = data
                                                    responseCallback(data)
                                                    });
                             bridge.registerHandler('getHeight', function (data, responseCallback) {
                                                    var height = document.body.offsetHeight;
                                                    responseCallback(height)
                                                    });
                             });
function didTapAvatar(){
    bridge.callHandler('gotoPersonalCenter', {}, function responseCallback(responseData) {});
    
}
function didTappedImage(index, imgUrl){
    var data = {'index' : index}
    bridge.callHandler('showImage', data, function responseCallback(responseData) {});
}







    
