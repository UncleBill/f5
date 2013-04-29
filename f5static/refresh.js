var socket = io.connect(location.hostname);
var pathname = location.pathname;   // a prefix

var getFileAttachers = function(){
    var tags,
        tagSize,
        attachers = [];

    if( document.querySelectorAll ){
        tags = document.querySelectorAll("*[href],*[src]");
    } else {
        tags = document.getElementsByTagName("*");
    }

    var localHref = location.href;
        tagSize = tags.length;
    for( var i = 0;i < tagSize; ++i ){
        var tag = tags[i];
        if( tag.src ){
            attachers.push({
                element:tag,
                file:  decodeURIComponent(tag.src)
            })
        } else if ( tag.href && tag.href !== localHref + "#" ){
            attachers.push({
                element:tag,
                file:  decodeURIComponent(tag.href)
            });
        }
    }

    return attachers;
}

var reloadTag = function( attcher ){
    var element = attcher.element;
    //console.log( 'reloading ...' );
    if( !!element.href ){
        var href = element.href;
        element.href = href;
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
    //console.log( "log:$data",$data );
    if( pathname === $data.slice(1) ){       // type of $data is ./foo/bar/file.html
        window.location.reload();
    } else {
        for(var i = 0; i < attachers.length; ++i){
            var url = location.protocol + "//" + location.host + $data.slice(1);
            if(url == attachers[i].file) {
                reloadTag( attachers[i] );
                //console.log( "log:file", attachers.file );
            }
        }
    }
});

//;(function(){
    //setTimeout(function(){
        //alert('reload script');
    //},100);
//})();
