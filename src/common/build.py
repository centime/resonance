main = file('content.js').read()
css = file('resonance.css').read().replace('\n', '\\\n').replace('"', "'")
html = file('resonance.html').read().replace('\n', '\\\n').replace('"', "'")

output = main.replace('<style>\\','<style>\\'+css).replace('</style>\\','</style>\\'+html)

open('content-built.js','w').write(output)