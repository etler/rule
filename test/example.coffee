console.time('example')
rule = new Rule
  'select':
    '=': -> '<select>'
    '@test': 'attribute'
    '': '<option>test</option>'
  '<': 'test',
  $('<div><select><option>bad</option></select></div>')
$('body').append rule.render {}
console.timeEnd('example')

console.time('example2')
rule = new Rule
  '-': 'a'
  '+': 'e'
  '' : 'c'
  '<': 'b'
  '>': 'd',
  $('<span></span>')
$('body').append rule.render {}
console.timeEnd('example2')