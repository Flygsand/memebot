# -*- Mode: coffee; tab-width: 2 -*-

util = require '../util'
Plugin = require '../plugin'

phrases = [
  '001100010010011110100001101101110011'
  'PROGRAM-ID. TERMINATE-ALL-HUMANS.'
]

botspeak = (e, bot) ->
  bot.say "#{e.user}: #{util.randpick(phrases)}"

module.exports = ->
  p = new Plugin {name: 'linuxoutlaws'}
  p.listen 'privmsg', {user: /JibbyBot|FlyingMeerkat/}, botspeak
  p
