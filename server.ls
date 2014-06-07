express = require 'express'
path = require 'path'
http = require 'http'
request = require \request
bodyParser = require('body-parser');
{test-url, get-cache-filename, get-cache} = require \./check.ls



app = express()
app.use(bodyParser())
#app.use express.static '/.public'
app.set 'port', (process.env.PORT or 3004)
app.set('views', __dirname + '/views')
app.engine('.html', require('ejs').__express);
app.set('view engine', 'ejs');


#app.use require('morgan') 'dev'

#app.use require('body-parser')
#app.use require('method-override')


# app.use express.static __dirname + '/public'
app.use '/lib', express.static 'views/lib'
app.use '/index/js', express.static 'views/index/js'
app.use '/details/js', express.static 'views/details/js'



app.get '/', (req, res) -> 
	console.log 'reques to /'
	res.render 'index/index'
	#res.end!
	#res.render 'home/index', {title: ''}

app.get '/details', (req, res) -> 
	console.log 'reques to /details'
	res.render 'details/index'

app.post '/check', (req, res) ->
	console.log \check
	(err, obj) <- get-cache get-cache-filename(req.param('link'))
	console.log err if !!err
	res.header \content-type, \application/json
	res.write JSON.stringify({obj.progress, obj.res})
	res.end!

app.post '/search', (req, res) ->
	countries = JSON.parse req.param('countries')
	link = req.param('link')
	console.log countries
	console.log link
	test-url link, countries
	res.end!

app.get '/proxy/:method', (req, res) ->

	#Cachable = require(\./cache).Cachable

	method = req.params.method

	res.write method
	res.end!

	# getter = new Cachable method, req.query.from, req.query.to, cache-duration, url-makers[method]
	
	# {body, content-type} <- getter.get!

	# res.header \content-type, content-type
	# res.write body
	# res.end!



app.listen app.get \port

#_ <- http.createServer(app).listen app.get('port')
#console.log "express started at port " + app.get 'port'