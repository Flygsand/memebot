# -*- Mode: coffee; tab-width: 2 -*-

_ = require 'underscore'
nstore = require('nstore').extend(require('nstore/query')())

sys = require 'sys'
path = require 'path'
fs = require 'fs'

class Plugin
  constructor: ->
    @handlers = {}
    @databases = {}

  command: (pattern, callback) ->
    addressed = (event, bot) =>
      nick = @bot.config.nick
      @bot.config.prefix && event.text[0] == @bot.config.prefix || event.text.substr(0, nick.length) == nick

    patterns = { text: pattern }
    @add_handler 'privmsg', { callback: callback, patterns: patterns, guard: addressed }

  listen: (ev_type, patterns, callback) ->
    patterns ?= {}

    @add_handler ev_type, { callback: callback, patterns: patterns }

  add_handler: (ev_type, handler) ->
    @handlers[ev_type] ?= []
    @handlers[ev_type].push handler

  trigger: (event) ->
    return unless @handlers[event.type]
    event.matches = {}

    match = (handler, event) ->
      return false unless !handler.guard || handler.guard event
      for k, p of handler.patterns
        return false unless event[k]
        m = event[k].match p
        return false unless m
        event.matches[k] = m

      return true

    for handler in @handlers[event.type]
      continue unless match handler, event

      callback = _.bind(handler.callback, this, event)
      try
        callback()
      catch error
        @bot.error "[#{@name}] #{error}"

  db: (name, callback) ->
    if @databases[name]
      callback @databases[name]
    else
      db_dir = path.join @bot.config.dir.data, 'plugins', @name
      @databases[name] = nstore.new path.join(db_dir, name + '.db'), =>
        callback @databases[name]

module.exports = Plugin