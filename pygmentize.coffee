sync = require('sync')
ent = require('ent')
pyg = require('pygmentize-bundled')
module.exports = (grunt) ->
  grunt.registerMultiTask 'pygmentize', 'Highlight syntax', (target) ->
    done = @async()
    src = '<code class="lang-coffeescript">class Foo</code>'
    pygmentize = (lang, code) ->
      pyg.sync(null, {lang: lang, format: 'html'}, code)
    sync =>
      console.log('files', @files)
      try
        @files.forEach (f) ->
          f.src
            .filter (filepath) ->
              # Warn on and remove invalid source files (if nonull was set).
              if not grunt.file.exists(filepath)
                grunt.log.warn('Source file "' + filepath + '" not found.')
                false
              else
                true
            .forEach (filepath) ->
              src = grunt.file.read(filepath)
              out = src.replace(
                ///
                  <pre>
                    <code \s+ class="lang-((?:.|\n)*?)">
                      ((?:.|\n)*?)
                    </code>
                  </pre>
                ///g
                (full, lang, code) -> pygmentize(lang, ent.decode(code))
              )
              grunt.file.write(filepath, out)
      catch e
        grunt.fail.warn(e.toString())
      console.log('done')
      done()
