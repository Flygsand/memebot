# -*- Mode: coffee; tab-width: 2 -*-

Plugin = require '../plugin'
sys = require 'sys'

lookup = (e, bot) ->
  key = e.matches.text[1]
  bot.db.find 'definitions', {key: key}, (err, results) ->
    bot.say "#{e.user}: #{results[0]}"

define = (e, bot) ->
  key = e.matches.text[1]
  value = e.matches.text[2]
  bot.db.save 'definitions', {key: key, value: value}, ->
    bot.say "#{e.user}: definition saved"

module.exports = ->
  p = new Plugin {name: 'define'}
  p.command /what is (\w+)\??/, lookup
  p.command /define (\w+) as (\w+)/, define
  p