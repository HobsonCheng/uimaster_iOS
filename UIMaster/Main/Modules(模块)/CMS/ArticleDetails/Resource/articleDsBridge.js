
//js调原生
function didTapAvatar(){
    dsBridge.call('gotoPersonalCenter');
}
function didTappedImage(index, imgUrl){
    var data = {'index' : index}
    dsBridge.call('showImage', data);
}

dsBridge.register('addValue',function(l,r){
    var titleElement = document.getElementsByClassName('head')[0];
    titleElement.innerText = data
    return data
})
dsBridge.register('getHeight',function(){
    var height = document.body.offsetHeight;
    return height
})


