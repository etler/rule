{exec} = require 'child_process'

option '-w', '--watch', 'watch scripts for changes and rerun commands'

task 'build', 'build rule.js', (options) ->
  exec 'coffee '+(if options.watch is true then '-w ' else '')+'--compile rule.coffee'

task 'test', 'build rule.js ', (options) ->
  exec 'coffee '+(if options.watch is true then '-w ' else '')+'-j test/rule.js -c rule.coffee test/template.coffee test/init.coffee'
