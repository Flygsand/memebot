# -*- Mode: coffee; tab-width: 2 -*-

Plugin = require '../plugin'

about = (e, bot) ->
  info = bot.info()

  response = switch e.matches.text[1]
    when 'source' then 'Get the source from http://github.com/mtah/memebot'
    when 'author' then 'memebot was written by Martin "mtah" Häger'
    when 'license' then 'memebot is free as in beard. Specifically, it is available under the GNU AGPLv3 or later.'
    else "memebot, version #{info.version}. Powered by node.js and CoffeeScript awesomeness."

  bot.say "#{e.user}: #{response}", e.source

module.exports = ->
  p = new Plugin {name: 'about', path: __filename}
  p.map 'privmsg', about, {text: /version|about(?: (source|author|license|version))?$/}
  p