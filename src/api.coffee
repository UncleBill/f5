fs = require 'fs'
path = require 'path'
url = require 'url'
util = require './util'
querystring = require 'querystring'
postHandler = (req, res)->
    urlobj = url.parse req.url
    pathname = urlobj.pathname
    querys = querystring.parse urlobj.query
    action = querys.action
    switch action
        when 'pick' then picker(req, res)

picker = (req, res)->
    text = ''
    req.on 'data',  (chunk) ->
        text += chunk

    req.on 'end', ()->
        console.log text
        files = querystring.parse( text )['sel']
        if not files
            res.write('No file packed')
            return
        if not Array.isArray(files)
            files = new Array( files )

        fs.rmdir './f5picker/', ()->
            debugger

        res.write "<ul>"
        for file in files
            debugger
            util.cp2Folder( './f5picker/', './'+file, (src, tg)->
                src = path.normalize( src )
                tg = path.normalize( tg )
                res.write "<li>F5: copy <b>#{src}</b> to <b>#{tg}</b>!</li>"
            )
        res.write "</ul>"
        res.end()

getHandler = (req, res)->
    res.write 'TODO: getHandler'
    res.end()

exports.postHandler = postHandler
exports.getHandler = getHandler
