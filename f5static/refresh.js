var socket = io.connect(location.hostname);
var pathname = location.pathname;   // a prefix

var getFileAttachers = function(){
    var images = document.images;
    var styles = document.styleSheets;
    var i;
    var attachers = [];
    for (i = 0; i < images.length; ++i) {
        attachers.push({
            element: images[i],
            uid: "F5UID"+(+new Date()),
            file: decodeURIComponent(images[i].src)
        })
    }
    for (i = 0; i < styles.length; ++i) {
        if (styles[i].href !== null) {
            attachers.push({
                element: styles[i].ownerNode,
                uid: "F5UID"+(+new Date()),
                file: decodeURIComponent(styles[i].href)
            })
        }
    }

    return attachers;
}

var insertAfter = function (newEle, referenceEle) {
    var sibling = referenceEle.nextSibling;
    if (sibling) {
        referenceEle.parentNode.insertBefore(newEle, referenceEle.nextSibling);
    } else {
        referenceEle.parentNode.appendChild(newEle);
    }
};

var reloadTag = function( attcher ){
    var element = attcher.element;
    //console.log( 'reloading ...' );
    if( !!element.href ){
        var href = element.href;
        var uid = attcher.uid;
        var newTag = document.createElement('link');
        var oldTag = document.getElementById(uid);

        var parentNode = document.head;

        if (oldTag) {
            parentNode = oldTag.parentNode;
            insertAfter(newTag, element)
            newTag.outerHTML = oldTag.outerHTML;
        } else {
            newTag.rel = "stylesheet";
            newTag.type = "text/css";
            insertAfter(newTag, element)
        }
        newTag.href = href;
        newTag.id = uid;

        // remove old tag
        oldTag && oldTag.remove();

        return;         // done;
    } else {
        var src = element.src;
        var pieces = src.split(".");
        var ext = pieces[ pieces.length - 1 ];
        if( ext === "js" ){
            window.location.reload();       // if changed file is js, reload page
            return;
        }
        element.src = src;
    }
}

attachers = getFileAttachers();
socket.on('reload', function ($data) {
    pathname = decodeURIComponent( pathname );
    // console.log( "log:$data",$data );
    if( pathname === $data.slice(1) ){       // type of $data is ./foo/bar/file.html
        window.location.reload();
    } else {
        for(var i = 0; i < attachers.length; ++i){
            var url = location.protocol + "//" + location.host + $data.slice(1);
            if(url == attachers[i].file) {
                reloadTag( attachers[i] );
                // console.log( "log:file", attachers[i].file );
            }
        }
    }
});

//;(function(){
    //setTimeout(function(){
        //alert('reload script');
    //},100);
//})();
