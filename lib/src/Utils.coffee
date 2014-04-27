sha1 = require('../lib/sha1.js').sha1

# Set the 'old' flag for the messages in histories
# Todo : no need to set it all at once, we could do it when served.
setUpHistory = (history) ->
    for user,list of history
      for m in list
        m.old = 'true'

getChan = (url,title) ->
  # todo : about:blank & co
  domain = getDomain(url)
  '#'+sha1(domain+title.replace(/\ /g,'')).toString() 

getDomain = (url) ->
    url.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)?[2]

module.exports =
    'setUpHistory':setUpHistory
    'getChan':getChan
    'getDomain':getDomain