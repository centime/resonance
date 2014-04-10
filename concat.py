main = file('data/content.js').read()
css = file('data/resonance.css').read().replace('\n', '\\\n').replace('"', "'")
html = file('data/resonance.html').read().replace('\n', '\\\n').replace('"', "'")

output = main.replace('<style>\\','<style>\\'+css+'\\').replace('</style>\\','</style>\\\n'+html+'\\')

open('data/content-built.js','w').write(output)

log='''
concat :
    data/content.js
    data/resonance.css
    data/resonance.html
into :
    data/content-built.js

'''
print(log)