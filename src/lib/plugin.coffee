# -*- Mode: coffee; tab-width: 2 -*-

require 'underscore'
sys = require 'sys'

class Plugin
  constructor: (info) ->
    throw 'Missing required plugin info (see plugin development documentation)' unless info && info.name
    @info = info
    @handlers = {}

  command: (pattern, callback) ->
    addressed = (event, bot) ->
      nick = bot.config.nick
      bot.config.prefix && event.text[0] == bot.config.prefix || event.text.substr(0, nick.length) == nick

    patterns = { text: pattern }
    this.add_handler 'privmsg', { callback: callback, patterns: patterns, guard: addressed }

  listen: (ev_type, patterns, callback) ->
    patterns ?= {}

    this.add_handler ev_type, { callback: callback, patterns: patterns }

  add_handler: (ev_type, handler) ->
    @handlers[ev_type] ?= []
    @handlers[ev_type].push handler

  trigger: (event, bot) ->
    return unless @handlers[event.type]
    event.matches = {}

    match = (handler, event) ->
      return false unless !handler.guard || handler.guard event, bot
      for k, p of handler.patterns
        return false unless event[k]
        m = event[k].match p
        return false unless m
        event.matches[k] = m

      return true

    for handler in @handlers[event.type]
      continue unless match handler, event

      callback = _.bind(handler.callback, this, event, bot)
      try
        callback()
      catch error
        bot.error "[#{@info.name}] #{error}"

module.exports = Plugin