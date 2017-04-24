fs = require('fs')
path = require('path')
cheerio = require('cheerio')
_ = require('grunt').util._
module.exports = (grunt) ->
  grunt.registerMultiTask 'autolink', 'Highlight nav links to current page and generate TOCs', (target) ->
    console.log('files', @files)
    page2anchors = {}
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
            page = path.basename(filepath)
            page2anchors[page] = anchors = []
            for link in $('.side-nav a')
              if _(filepath).endsWith($(link).attr('href'))
                toc = $('<ul/>').addClass('toc')
                for hdr in $('#main-content h2').map((i,x) -> $(x))
                  anchor = hdr.text().replace(/\W/g, '-').toLowerCase()
                  anchors.push(anchor)
                  toc.append(
                    $('<li/>').append(
                      $('<a/>').attr('href', "##{anchor}").html(hdr.html())
                    )
                  )
                  hdr.html($('<a/>').attr('name', anchor).html(hdr.html()))
                toc = if toc.children().length > 0 then toc else $()
                $(link).addClass('current').parent().append(toc)
            grunt.file.write(filepath, $.html())
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
            currentPage = path.basename(filepath)
            for link in $('a[href]').map((i,x) -> $(x))
              href = link.attr('href')
              check = (page, anchor) ->
                if _(page).startsWith('/')
                  if page != '/bobtail/'
                    grunt.fail.warn "Bad abs. link in #{filepath}: #{page}"
                  page = 'index.html'
                else
                  matches = grunt.file.glob.sync(path.join(path.dirname(filepath), page))
                  if matches.length == 0
                    grunt.fail.warn "Broken link in #{filepath}: #{href}"
                  page = path.basename(page)
                if anchor? and anchor not in anchors = page2anchors[page] ? []
                  grunt.fail.warn "Anchor not found in #{filepath}: #{href} (available: #{anchors})"
              if _(href).startsWith('#')
                check(currentPage, href.substring(1))
              # if (absolute or relative) local, non-global path
              else if not href.match(/^(\w+:)?\/\//)
                if '#' in href
                  [page, anchor] = href.split('#')
                  check(page, anchor)
                else
                  check(href, null)
            # jsfiddle APIs have no support for Coffeescript - must do manually
            ###
            for fiddle in $('a[data-fiddle]').map((i,x) -> $(x))
              name = fiddle.attr('data-fiddle')
              code = fiddle.parent().next().find('pre').text()
              grunt.file.mkdir('examples')
              grunt.file.write('examples/' + name + '.coffee', code)
            ###
    catch e
      grunt.fail.warn(e.toString())
    console.log('done')
