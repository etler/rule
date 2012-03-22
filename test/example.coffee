console.time('example')
rule = new Rule
  'select':
    '=': -> '<select>'
    '@test': 'attribute'
    '': '<option>test</option>'
  '<': 'test'
template = $('<div><select><option>bad</option></select></div>')
rule.template = template
$('body').append rule.render {}
console.timeEnd('example')

console.time('example2')
rule = new Rule
  '-': 'a'
  '+': 'e'
  '' : 'c'
  '<': 'b'
  '>': 'd'
template = $('<span></span>')
rule.template = template
$('body').append rule.render {}
console.timeEnd('example2')