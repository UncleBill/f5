var socket = io.connect(location.hostname);
var pathname = location.pathname;   // a prefix

var getFileAttachers = function() {
    var images = document.images;
    var styles = document.styleSheets;
    var scripts = document.scripts;
    var i;
    var attachers = [];
    for (i = 0; i < images.length; ++i) {
        attachers.push({
            element: images[i],
            uid: "F5UID" + (+ new Date()),
            file: decodeURIComponent(images[i].src)
        })
    }
    for (i = 0; i < styles.length; ++i) {
        if (styles[i].href !== null) {
            attachers.push({
                element: styles[i].ownerNode || styles[i].owningElement,
                uid: "F5UID" + (+ new Date()),
                file: decodeURIComponent(styles[i].href)
            })
        }
    }
    for (i = 0; i < scripts.length; ++i) {
        attachers.push({
            element: scripts[i],
            uid: "F5UID" + (+ new Date()),
            file: decodeURIComponent( scripts[i].src )
        })
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
    if (!element) {
        return;
    }
    //console.log( 'reloading ...' );
    if( !!element.href ){
        var href = element.getAttribute('href');
        element.href = href;
        return element;
    } else {
        var src = element.src;

        // Refresh page, if JavaScript
        if(element.tagName.toLowerCase() === "script"){
            window.location.reload();
            return;
        }
        element.src = src;
        return element;
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
                var element = reloadTag( attachers[i] );
                attachers[i].element = element;
            }
        }
    }
});
