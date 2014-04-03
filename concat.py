main = file('src/common/content.js').read()
css = file('src/common/resonance.css').read().replace('\n', '\\\n').replace('"', "'")
html = file('src/common/resonance.html').read().replace('\n', '\\\n').replace('"', "'")

output = main.replace('<style>\\','<style>\\'+css+'\\').replace('</style>\\','</style>\\\n'+html+'\\')

open('src/common/content-built.js','w').write(output)

log='''
concat :
    src/common/content.js
    src/common/resonance.css
    src/common/resonance.html
into :
    src/common/content-built.js

'''
print(log)