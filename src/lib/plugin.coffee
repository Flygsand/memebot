# -*- Mode: coffee; tab-width: 2 -*-

sys = require 'sys'

class Plugin
  constructor: (metadata) ->
    {name: @name, path: @path} = metadata
    @handlers = {}

  map: (ev_type, callback, patterns) ->
    patterns ?= {}

    @handlers[ev_type] ?= []
    @handlers[ev_type].push { callback: callback, patterns: patterns }

  trigger: (event, bot) ->
    return unless @handlers[event.type]
    event.matches = {}

    match = (handler, event) ->
      for k, p of handler.patterns
        return false unless event[k]
        m = event[k].match p
        return false unless m
        event.matches[k] = m

      return true

    for handler in @handlers[event.type]
      continue unless match handler, event

      try
        handler.callback event, bot
      catch error
        bot.error "[#{@name}] #{error}"

module.exports = Plugin