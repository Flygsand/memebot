# -*- Mode: coffee; tab-width: 2 -*-

Plugin = require '../plugin'
util = require '../util'
sys = require 'sys'
fs = require 'fs'

messages = {}

loaded = ->
  @db 'messages', (msg_db) ->
    stream = msg_db.find()
    stream.on 'document', (ms, to) ->
      messages[to] = ms

tell = (e) ->
  to = e.matches.text[1]
  m = {from: e.user, to: to, body: e.matches.text[2], time: util.format_time new Date()}

  messages[to] ?= []
  messages[to].push m

  @db 'messages', (msg_db) ->
    msg_db.save to, messages[to], (err) ->
      throw err if err

  @bot.say "#{e.user}: Message stored", e.source

regurgitate = (e) ->

  if messages[e.user]
    for m in messages[e.user]
      @bot.say "#{e.user}: (message from #{m.from} @ #{m.time}) \"#{m.body}\""

    messages[e.user] = []
    @db 'messages', (msg_db) ->
      msg_db.remove e.user, (err) ->
        throw err if err

module.exports = ->
  p = new Plugin
  p.onload = loaded
  p.command /tell (\w+) that (.*)/, tell
  p.listen 'privmsg', {}, regurgitate
  p.listen 'join', {}, regurgitate
  p