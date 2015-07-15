fs      = require "fs"
path    = require "path"

_SOCKET_TEMPLATE_="""
    <script src="/socket.io/socket.io.js"></script>
    <script src="/f5static/refresh.js"></script>
"""

tempCache = {}
getTempl = (file)->
    if file of tempCache
        return tempCache[file]

    templDir = path.join(__dirname,'..','./template/')
    file = templDir + file
    tempCache[file] = "#{fs.readFileSync(file)}"

_insertTempl = (file, templ)->
    matchrx = ///
    </\s*body\s*>
    (?![^]*</\s*body\s*>)           # not followed by any more </\s*body\s>
    ///gi

    if not file.search matchrx
        file += templ.join ''
    else
        RegExp.leftContext + templ.join('\n') + '\n' + RegExp.lastMatch + RegExp.rightContext

insertSocket = ( file )->
    _insertTempl( file, [_SOCKET_TEMPLATE_] )

res500 = (err,res)->
    res.writeHead 500,{"Content-Type":"text/plain"}
    res.end err

rmFile = (file)->
    fs.exists file,( isexists )->
        if isexists
            fs.unlinkSync file,(err)->
                throw err if err
        else return

# http://stackoverflow.com/questions/4340227/sort-mixed-alpha-numeric-array
sortAlphaNum = (a, b)->
    reAlpha = /[^a-zA-Z]/g
    reNumer = /[^0-9]/g
    aAlpha = a.replace(reAlpha, "")
    bAlpha = b.replace(reAlpha, "")
    if aAlpha is bAlpha
        aNumber = parseInt(a.replace(reNumer, ""), 10)
        bNumber = parseInt(b.replace(reNumer, ""), 10)
        `aNumber === bNumber ? 0 : aNumber > bNumber ? 1 : -1`
    else
        `aAlpha > bAlpha ? 1 : -1`

sortFiles = (realPath,files)->
    _folders = []
    _files   = []
    files = files.sort sortAlphaNum
    if realPath[realPath.length-1] isnt "/"
        realPath += "/"
    for file in files
        if not fs.existsSync(realPath+file)
            continue
        if fs.statSync(realPath+file).isDirectory()
            _folders.push file
        else
            _files.push file

    _folders.concat _files

_cpFile = (src, tg) ->
    src = path.normalize(src)
    _ensureExists path.dirname( tg )
    rs = fs.createReadStream( src )
    ws = fs.createWriteStream( tg )
    console.log(src, "->", tg)
    debugger
    rs.pipe( ws )

cp2Folder = (tgFolder, src, cb) ->
    _ensureExists( tgFolder )
    tg = path.join(tgFolder, src)
    _cpFile(src, tg)
    cb && cb(src, tg)

_ensureExists = (dir) ->
    exists = fs.existsSync(dir)
    parentDir = path.join.apply(null, dir.split( path.sep ).slice(0, -1) )
    if not exists
        _ensureExists( parentDir )
        fs.mkdirSync( dir )

fileCategorize = (ext) ->
    filetype = ''
    switch ext
        when 'css'  then filetype = 'css'
        when 'html','htm' then filetype = 'html'
        when 'js','coffee'   then filetype = 'javascript'
        when 'jpg','jpeg','gif','png' then filetype = 'image'
        when 'psd' then filetype = 'psd'
        when 'rar','zip','7z' then filetype = 'zipfile'
        else filetype = 'defaulttype'
    return filetype


exports.getTempl = getTempl
exports.insertSocket = insertSocket
exports.res500 = res500
exports.sortFiles = sortFiles
exports.cp2Folder = cp2Folder
exports.rmFile = rmFile
exports.fileCategorize = fileCategorize

try
    exports.version = JSON.parse(fs.readFileSync("#{ __dirname }/../package.json")).version
catch err
    exports.version = '0.0.0'
# vim:set expandtab
