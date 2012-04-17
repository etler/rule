{exec} = require 'child_process'

option '-w', '--watch', 'watch scripts for changes and rerun commands'

task 'build', 'build rule.js', (options) ->
  rule = exec 'coffee '+(if options.watch is true then '-w ' else '')+'--compile rule.coffee'
  rule.stdout.on 'data', (data) -> console.log data

task 'test', 'build rule.js with tests', (options) ->
  invoke 'build'
  test = exec 'coffee '+(if options.watch is true then '-w ' else '')+' -c test/test.coffee'
  test.stdout.on 'data', (data) -> console.log data

task 'example', 'build rule.js with examples', (options) ->
  invoke 'build'
  example = exec 'coffee '+(if options.watch is true then '-w ' else '')+' -c example/example.coffee'
  example.stdout.on 'data', (data) -> console.log data
