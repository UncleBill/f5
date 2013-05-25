{exec} = require "child_process"

_buildcmd   = "coffee -co lib/ src/"
_watchcmd   = "coffee -cwo lib/ src/"
_installcmd = "npm install -g"
_testcmd    = "node bin/f5"

build = (callback)->
    child = exec _buildcmd, (e,s,se)->
        if e
            console.log e
        else
            console.log "build succeeded"
            callback() if typeof callback is 'function'
    child.stdout.on "data",(data)->
        console.log data


task "watch","auto compile src to lib",->
    child = exec _watchcmd, (e,s,se)->
        if e
            console.log e
            throw new Error "Error while compiling .coffee to .js"
    child.stdout.on "data",(data)->
        console.log data


task "build","compile src to lib", build


task "test", "run server for test", ->
    build ->
        child = exec _testcmd,(err,s)->
            if err
                console.log err
            else
                console.log s
         child.stdout.on "data",(data)->
            console.log data


task "install","install f5 local",->
    build ->
        child = exec _installcmd,(err,s)->
            if err
                console.log err
            else
                console.log s
        child.stdout.on "data",(data)->
            console.log data
