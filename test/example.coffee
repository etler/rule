console.time('simple')
simple = new Rule
  '.content': ->@content

simple.render
  content: 'simple',
  document.querySelector '.simple'
console.timeEnd('simple')


console.time('book')
book = new Rule
  '.title': ->@title
  '.author':
    '.name':
      '.first': ->@author.first
      '.last': ->@author.last

book.render
  title: 'The Hobbit'
  author:
    first: 'J. R. R.'
    last: 'Tolkien',
  document.querySelector '.book'
console.timeEnd('book')


console.time('list')
itemRule = new Rule
  '.content': ->@content ? 'default',
  document.querySelector '.list li'
listRule = new Rule
  '': ->itemRule.render item for item in @list

listRule.render
  list: [{content: 'hello'}, {content: 'world'}, {}],
  document.querySelector '.list'
console.timeEnd('list')


console.time('recursive')
listItem = new Rule
  '': ->@location
  '>': ->if @list? then recursive.render @
  document.querySelector '.location'
recursive = new Rule
  '': ->listItem.render item for item in @list
  document.querySelector '.recursive'

recursive.render
  list:
    [
      {
        location: 'USA'
        list:
          [
            {
              location: 'California'
              list:
                [
                  { location: 'San Diego' }
                  { location: 'San Francisco' }
                  { location: 'San Jose' }
                ]
            }
            {
              location: 'Nevada'
              list:
                [
                  { location: 'Reno' }
                  { location: 'Las Vegas' }
                ]
            }
          ]
        }
      ]
  document.querySelector '.recursive'
console.timeEnd('recursive')