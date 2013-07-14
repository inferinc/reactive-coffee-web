coffee spellcheck.coffee
for i in .spell/*.html; do
  aspell check -p .aspell.en.pws $i
done
