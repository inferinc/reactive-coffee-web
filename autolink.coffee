fs = require('fs')
cheerio = require('cheerio')
_ = require('grunt').util._
module.exports = (grunt) ->
  grunt.registerMultiTask 'autolink', 'Highlight nav links to current page and generate TOCs', (target) ->
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
            $ = cheerio.load(fs.readFileSync(filepath))
            for link in $('.side-nav a')
              if _(filepath).endsWith($(link).attr('href'))
                toc = $('<ul/>').addClass('toc')
                for hdr in $('#main-content h2').map((i,x) -> $(x))
                  anchor = hdr.text().replace(/\W/, '-').toLowerCase()
                  hdr.html($('<a/>').attr('name', anchor).html(hdr.html()))
                  toc.append(
                    $('<li/>').append(
                      $('<a/>').attr('href', "##{anchor}").text(hdr.text())
                    )
                  )
                toc = if toc.children().length > 0 then toc else $()
                $(link).addClass('current').parent().append(toc)
            grunt.file.write(filepath, $.html())
    catch e
      grunt.fail.warn(e.toString())
    console.log('done')
