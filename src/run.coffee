fs = require 'fs'
path = require 'path'

localroot = path.resolve '.'
if fs.existsSync 'f5file.js'
    worker_path = path.join localroot, 'f5file.js'
    debugger
    try
        worker = require worker_path
    catch reqerr
        console.log '[require error message]' reqerr.message
        return
else
    worker = {
        do: ()->
    }

exports.do = worker.do
