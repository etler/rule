{exec} = require 'child_process'

option '-w', '--watch', 'watch scripts for changes and rerun commands'

task 'build', 'build rule.js', (options) ->
  buildRule(options)

task 'test', 'build rule.js with tests', (options) ->
  buildRule(options)
  buildTest(options)

task 'example', 'build rule.js with examples', (options) ->
  buildRule(options)
  buildExample(options)

task 'all', 'build rule.js with tests and examples', (options) ->
  buildRule(options)
  buildTest(options)
  buildExample(options)

buildRule = (options) ->
  rule = exec 'coffee '+(if options.watch is true then '-w ' else '')+'--compile rule.coffee'
  rule.stdout.on 'data', (data) -> console.log data

buildTest = (options) ->
  test = exec 'coffee '+(if options.watch is true then '-w ' else '')+' -c test/test.coffee'
  test.stdout.on 'data', (data) -> console.log data

buildExample = (options) ->
  example = exec 'coffee '+(if options.watch is true then '-w ' else '')+' -c example/example.coffee'
  example.stdout.on 'data', (data) -> console.log data