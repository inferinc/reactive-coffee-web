cheerio = require('cheerio')
grunt = require('grunt')
fs = require('fs')
try
  fs.mkdirSync('.spell/')
catch error
for path in grunt.file.glob.sync('.tmp/*.html')
  $ = cheerio.load(fs.readFileSync(path))
  $('code, pre, script').remove()
  fs.writeFileSync(path.replace('.tmp/', '.spell/'), $.html())
