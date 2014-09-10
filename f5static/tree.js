// fold handling
// -------------
var toggleFold = function (obj) { // toggle fold by toggle className
    var cn = obj.parentNode.className;
    if (/\bfolded\b/.test(cn)) { // if folded
        cn = cn.replace(/\bfolded\b/, '') + ' unfold';
    } else {
        cn = cn.replace(/\bunfold\b/g, '') + ' folded'; // if unfold
    }
    obj.parentNode.className = cn.replace("  ", " ")
}

// image holder handling
// ---------------------
$("<div id='image_holder' />").appendTo($("body")).hide();
var $image_holder = $("#image_holder");

$(".ft_image").each( function( index ){
    var $target = $(this);
    $target.hover( function(){
        var $href =  this.href;
        $image_holder.show().html( "<img src='" + $href + "' />"  ).pos;
    },function(){
        $image_holder.hide();
    } );
} );
// file manage : delete
// --------------------

$(".delete").bind("click",function(){
    var $parent = $(this).parent();
    var file = $parent.find(".file").attr("href");
    $parent.slideUp(function(){
        socket.emit("delete",file);
    });
});

// go to parent handle
// -------------------
$("#parent").bind("click",function(){
    if(location.href == location.origin+'/'){
    $(this).css({"opacity":0.5});
        return
    }
    location.href = location.origin
})


// kill f5
// -------
$("#quit").bind("click",function(){
    socket.emit("quit");
    window.open('', '_self', '');
    window.close();
});
