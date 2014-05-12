path = './src/_book/'
fileNames = ['index.html', 'HowTo.html']
fileNames = [ path+name for name in fileNames]


def arrange(html) :
    html = html.replace('fa-check','')
    html = html.replace('class="bar"', '')
    html = html.replace('<a href="#" target="_blank" class="btn pull-right" data-sharing="google-plus"><i class="fa fa-google-plus"></i></a>','')
    html = html.replace('<a href="#" target="_blank" class="btn pull-right" data-sharing="facebook"><i class="fa fa-facebook"></i></a>','')
    html = html.replace('<a href="#" target="_blank" class="btn pull-right" data-sharing="twitter"><i class="fa fa-twitter"></i></a>','')

    return html

for fName in fileNames :
    f = file(fName)
    html = arrange(f.read())
    f.close()
    open(fName,'w').write(html)

