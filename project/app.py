from bottle import run, route, template, view, static_file

#ROUTES FOR PAGES

@route('/')
@view('home') # Uses views/home.tpl
def home():
    return {} # Dictionary for template variables if needed

@route('/about')
def about():
    return template('about') # Manual template rendering

@route('/contact')
@view('contact')
def contact():
    return {}

# ROUTE FOR STATIC FILES (CSS, IMAGES, JS)
@route('/static/<filename>')
def server_static(filename):
    return static_file(filename, root='./static')

# START SERVER
if __name__ == "__main__":
    run(host='localhost', port=8010, debug=True, reloader=True)