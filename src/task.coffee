fs = require 'fs'
colors = require 'colors'

succeed = colors.green
fail    = colors.red
yellow  = colors.yellow

failDetail = (err)->
    console.log  fail "ERROR number: #{err['errno']},ERROR code: #{err['code']}"
# make directory
makeDir = (dir)->
    fs.exists dir, (exists)->
        if exists
            console.log yellow "#{dir} exists"
            return
        else
            fs.mkdir dir, (err)->
                if not err
                    console.log succeed "Making directory #{dir} succeed!"
                else
                    console.log fail "Fail to make directory #{dir}"
                    failDetail err

# write to fle
writeToFile = ( file, source )->
    fs.readFile source, (err,data)->
        if not err
            fs.exists file, (exists)->
                if exists
                    console.log "#{file} exists, return"
                    return
                fs.writeFile file, data.toString() ,(err)->
                    if not err
                        console.log succeed "Writing file #{file} succeed"
                    else
                        console.log fail "Fail to write file #{file}"
        else
            console.log fail "Fail to read data from file #{dir}"
# initFiles
initFiles = ->
    archives =
        folders: ['images','styles','scripts']
        files:['styles/index.css','scripts/index.js','index.html']

    for folder in archives['folders']
        makeDir folder
    for file in archives['files']
        writeToFile file,"#{__dirname}/../f5data/#{file}"

# task list
tasks = [initFiles]

runtasks = ->
    for task in tasks
        task()      # run task
# exports
exports.runtasks = runtasks
