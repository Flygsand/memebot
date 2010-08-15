# -*- Mode: coffee; tab-width: 2 -*-

jasmine = require 'jasmine'
Plugin = require 'lib/plugin'

describe "Plugin", ->
  plugin = null

  beforeEach ->
    plugin = new Plugin {'name': 'foobar', path: '/foo/bar'}

  it "calls appropriate handler (without patterns) when event is triggered", ->
    callback = jasmine.createSpy()
    plugin.map 'event', callback

    plugin.trigger {type: 'event'}, 'bot'

    expect(callback).toHaveBeenCalledWith {type: 'event', matches: {}}, 'bot'

  xit "calls appropriate handler (with patterns) with match data when event is triggered", ->
    callback = jasmine.createSpy()
    plugin.map 'event', callback, {one: /^foo (\w+)/, two: /bar (\w+)$/}

    plugin.trigger {type: 'event', one: 'foo match1 more', two: 'more bar match2'}, 'bot'

    expected =
      type: 'event'
      one: 'foo match1 more'
      two: 'more bar match2'
      matches:
        one: ['foo match1', 'match1']
        two: ['bar match2', 'match2']

    expect(callback).toHaveBeenCalledWith expected, 'bot'

  it "doesn't call the handler when pattern doesn't match", ->
    callback = jasmine.createSpy()
    plugin.map 'event', callback, {text: /you shall not match/}

    plugin.trigger {type: 'event', text: 'Gabba gabba hey'}, 'bot'

    expect(callback).not.toHaveBeenCalled()

  it "doesn't call a handler for another event", ->
    callback = jasmine.createSpy()
    another_callback = jasmine.createSpy()
    plugin.map 'event', callback
    plugin.map 'another_event', another_callback

    plugin.trigger {type: 'another_event'}, 'bot'

    expect(callback).not.toHaveBeenCalled()
    expect(another_callback).toHaveBeenCalled()