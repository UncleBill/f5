var $pickForm = $("#pickForm");
var rootpath = $("#rootPath").attr('data-root');
$pickForm.submit(function (e) {
    e.preventDefault();
    e.returnValue = false;
    
    var $this = $(this);
    var $sel = $this.find("[name=sel]:checked");
    $.ajax({
        type: 'post',
        url: '/f5api?action=pick',
        data: $pickForm.serialize(),
        dataType: 'text',
        success: function (htmlcode) {
            $("#pick-file-tree").html(htmlcode)
        }
    })
})

$pickForm.on('change', function () {
    var $sel = $pickForm.find("[name=sel]:checked");
    var $folders = $pickForm.find("[name=selfolder]:checked");
    var files = [],
        folders = [];
    var tree = {};
    $sel.each(function () {
        files.push( this.value );
        fp2tree(this.value, tree);
    });
    $folders.each(function () {
        folders.push(this.value);
    })
    // console.log(tree);
    var data = {
        tree: tree,
        files: files,
        folders: folders
    };
    if (window.localStorage) {
        localStorage.setItem(rootpath, JSON.stringify(data))
    }
    // console.log(buildHtml(tree));
    renderTree(tree, files);
});

restore();

function restore() {
    var data = JSON.parse(localStorage.getItem(rootpath));
    if (!data || !data.tree) {
        return;
    }
    renderTree(data.tree, data.files);
    var checkboxs = data.files.concat( data.folders );
    for (var i = 0,len = checkboxs.length; i < len; ++i) {
        $('input[value="'+checkboxs[i]+'"]').prop('checked', true);
    }
}

function renderTree(tree, files) {
    var htmlcode = "<p>Total: " + files.length + "</p>";
    htmlcode += buildHtml( tree );
    if (files.length) {
        $(".wrapper").addClass('splited');
        $("#pick-file-tree").html(htmlcode)
    } else {
        $(".wrapper").removeClass('splited');
        $("#pick-file-tree").html('');
    }
}


$pickForm.find("[name=selfolder]").click(function () {
    var checked = this.checked;
    $(this).parent(".subdir").find("[type=checkbox]").each(function () {
        this.checked = checked;
    })
    $pickForm.trigger('change');
})


function fp2tree(fp, tree) {
    var first = fp.indexOf('/');
    var next = fp.indexOf('/', first+1);
    var folder;
    if (next != -1) {
        folder = fp.substring(first+1, next);
        if (tree[folder]) {
            return fp2tree(fp.substring(next+1), tree[folder])
        } else {
            var newFolder = {}
            tree[folder] = fp2tree(fp.substring(next), newFolder)
            return tree;
        }
    } else {
        tree[fp.substring(first+1)] = fp.substring(first+1);
        return tree;
    }
}

function buildHtml(tree) {
    var codepool = [];
    var deep = 0;
    codepool.push("<ul>");
    codepool = buildpool(tree, codepool, deep);
    codepool.push("</ul>");
    return codepool.join('\n');
}

function buildpool(tree, htmlArr, deep) {
    var subtree;
    for (var file in tree) {
        if (tree.hasOwnProperty( file )) {
            if ( (typeof tree[file]) === 'string' ) {
                htmlArr.push(indent(deep) + "<li class='file-entry'>"+tree[file]+"</li>");
            }
            else
            {
                htmlArr.push(indent(deep) + "<li class='subdir folder'>");
                htmlArr.push(indent(deep+1) + '<a class="folder" href="javascript:void(0);" onclick="toggleFold(this)">' + file + "</a>");
                htmlArr.push(indent(deep+1) + "<ul>");
                subtree = buildpool( tree[file], [], deep+1 ).join("\n")
                htmlArr.push(indent(deep+1) + subtree);
                htmlArr.push(indent(deep+1) + "<!-- end of folder -->");
                htmlArr.push("</ul></li>");
            }
        }
    }

    function indent(n) {
        return (new Array(n+1)).join("  ");
    }

    return htmlArr
}

