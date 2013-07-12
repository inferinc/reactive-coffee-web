fs = require('fs')
path = require('path')
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
            anchors = []
            for link in $('.side-nav a')
              if _(filepath).endsWith($(link).attr('href'))
                toc = $('<ul/>').addClass('toc')
                for hdr in $('#main-content h2').map((i,x) -> $(x))
                  anchor = hdr.text().replace(/\W/, '-').toLowerCase()
                  anchors.push(anchor)
                  hdr.html($('<a/>').attr('name', anchor).html(hdr.html()))
                  toc.append(
                    $('<li/>').append(
                      $('<a/>').attr('href', "##{anchor}").text(hdr.text())
                    )
                  )
                toc = if toc.children().length > 0 then toc else $()
                $(link).addClass('current').parent().append(toc)
            for link in $('a[href]').map((i,x) -> $(x))
              href = link.attr('href')
              if _(href).startsWith('#')
                if href.substring(1) not in anchors
                  grunt.fail.warn "Broken link in #{filepath}: #{href}"
              else if not href.match(/^(\w+:)?\/\//)
                exists =
                  if _(href).startsWith('/')
                    grunt.file.glob.sync('{app,.tmp}' + href)
                  else
                    grunt.file.glob.sync(path.join(path.dirname(filepath), href))
                if exists.length == 0
                  grunt.fail.warn "Broken link in #{filepath}: #{href}"
            grunt.file.write(filepath, $.html())
    catch e
      grunt.fail.warn(e.toString())
    console.log('done')
