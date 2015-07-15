http    = require "http"
io      = require "socket.io"
ejs     = require "ejs"
url     = require "url"
fs      = require "fs"
path    = require "path"
{types} = require "mime"
util    = require './util'
querystring = require('querystring')
run = require './run'

watch = require('node-watch')
ignore_re = /([\\\/]\.|.*~$)/

SOCKET_TEMPLATE="""
    <script src="/socket.io/socket.io.js"></script>
    <script src="/f5static/refresh.js"></script>
"""



renderDir = (realPath,files)->
    files = util.sortFiles(realPath,files)

    if realPath[realPath.length-1] isnt "/"
        realPath += "/"
    html = []
    html.push "<ul>"
    for file in files
        if file[0] is '.'       # ingore dot files
            continue
        _path = realPath + file
        if fs.statSync(_path).isDirectory()
            _files = fs.readdirSync(_path)
            html.push ejs.render util.getTempl("dir.ejs"), {
                _path  : _path[1..]       # ./foo/bar => /foo/bar
                file   : file,
                subdir : renderDir _path, _files
            }
        else
            _extname = path.extname( file )
            _extname = if _extname.length then _extname.substr 1 else ""
            filetype = ''
            switch _extname
                when 'css'  then filetype = 'css'
                when 'html','htm' then filetype = 'html'
                when 'js','coffee'   then filetype = 'javascript'
                when 'jpg','jpeg','psd','gif','png' then filetype = 'image'
                when 'rar','zip','7z' then filetype = 'zipfile'
                else filetype = 'defaulttype'

            html.push ejs.render util.getTempl("file.ejs"), {
                filetype : filetype,
                _path    : _path[1..]       # ./foo/bar => /foo/bar
                file     : file
            }
    html.push "</ul>"
    html.join ""


createServer = (config)->
    _path = config.path
    _port = config.port
    server = http.createServer (req,res)->
        pathname = url.parse(req.url).pathname
        if req.method == 'POST'
            if  pathname.match /^\/f5api\//
                text = ''
                req.on('data',  (chunk) ->
                    text += chunk
                )
                req.on('end', ()->
                    console.log text
                    files = querystring.parse( text )['sel']
                    if not files
                        res.end('No file packed')
                        return
                    if not Array.isArray(files)
                        files = new Array( files )
                    fs.rmdir('./f5picker/', ()->
                        debugger
                    )
                    res.write "<ul>"
                    for file in files
                        debugger
                        util.cp2Folder( './f5picker/', './'+file, (src, tg)->
                            src = path.normalize( src )
                            tg = path.normalize( tg )
                            res.write "<li>F5: copy <b>#{src}</b> to <b>#{tg}</b>!</li>"
                        )
                    res.write "</ul>"
                    # res.write ( utils.inspect files )
                    res.end()
                )

            else if req.method.toUpperCase() == 'GET'
                res.write 'f5api GET respone'
        realPath = decodeURIComponent _path+pathname

        renderPath = realPath
        # redirect to f5static file
        # console.log 'before split',realPath
        if (realPath.split "/")[1] == 'f5static'
            realPath = path.join( __dirname, '..', realPath )
            #console.log 'static request',realPath

        fs.exists realPath, (exists)->
            #console.log( 'handle path', realPath )
            if not exists
                res.writeHead 404,{"Content-Type":"text/html"}
                res.write ejs.render(util.getTempl("404.ejs"),{
                    _htmltext: "404 Not Found: url " + req.url
                    title: "404 Not Found"
                })
                res.end()
            else if fs.statSync(realPath).isDirectory()
                fs.readdir realPath,(err,files)->
                    if err
                        util.res500 err,res
                    else
                        res.writeHead 200,{"Content-Type":types["html"]}
                        _htmltext = renderDir renderPath, files
                        res.write ejs.render(util.getTempl("tree.ejs"), {
                            _htmltext: _htmltext
                            title: realPath
                            version: exports.version
                            root_path: fs.realpathSync('.')
                        })
                        res.end()
            else
                ext = path.extname realPath
                if ext
                    ext = ext[1..]
                else
                    ext = "unknown"
                res.setHeader "Content-Type",types[ext] or "text/plian"

                fs.readFile realPath,"binary",(err,file)->
                    if err
                        util.res500 err,res
                    else
                        res.writeHead 200,"Ok"
                        if ext is "html" or ext is "htm"
                            file = util.insertSocket file
                        res.write file,"binary"
                        res.end()
    _sockets = []
    _io = {sockets} = io.listen server, "log level":0
    sockets.on "connection",(socket)->
        _sockets = _sockets.filter (s)->
            return not s['disconnected']
        _sockets.push socket
        socket.on "delete",(file)->
            util.rmFile file
        socket.on "rename",(data)->
            f5Rename data

        socket.on 'quit', (data)->
            console.log('f5 quiting...')
            process.exit(0)

    watch '.', (filename)->
        normalize_file = './' + filename.replace(/\\/g, '/')
        if ignore_re.test(normalize_file)
            return
        console.log 'changed file:',normalize_file
        debugger
        if filename == 'f5file.js'
            console.log '[f5]', 'Reload f5file.'
            f5path = path.resolve('.', 'f5file.js')
            delete require.cache[require.resolve(f5path)]
            run = require(f5path)
        run.do filename
        for socket in _sockets
            socket.emit 'reload', normalize_file
            console.log 'emit reload', '--', normalize_file, '--', (new Date).toString()
        return

    server.listen _port
    console.log "f5 is on localhost:#{_port} now."


exports.version = util.version
exports.createServer = createServer
# vim:set expandtab
