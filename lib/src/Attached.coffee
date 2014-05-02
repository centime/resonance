tabs = require('sdk/tabs')
data = require('sdk/self').data 
getChan = require('./Utils.js').getChan

require("sdk/simple-storage").storage.attachedPages ?= []
pages = require("sdk/simple-storage").storage.attachedPages

tab = undefined
worker = undefined

tabs.open({
    'url':data.url('attached.html')
    'onReady': (t) ->
        tab = t
        worker = tab.attach({
                            contentScriptFile:[
                              data.url("lib/angular.min.js"),
                              data.url("attached/attached.js"),
                            ]
                        })
        worker.port.emit('pages',pages)

        worker.port.on 'detach', (page) ->
            # part from chan ?
            pageIndex = pages.indexOf(page)
            pages.splice(pageIndex,1)
            worker.port.emit('pages',pages)
    })

attach = (url, title) ->
    page = 
     'url' : url
     'title' : title
     'chan' : getChan(url,title) 
    pages.push(page)
    worker.port.emit('pages',pages)

module.exports = 
    'attach':attach