request = require \request
{Obj, each, difference} = require \prelude-ls
{
	promises: {
		LazyPromise, parallel-map, serial-map, parallel-limited-map,ffmapP, fmapP
	},
	monads: {
		filterM, liftM
	}
} = require \async-ls
fs = require \fs
cache-directory = \cache/


get-headers = (url, callback) ->
	(err, res) <- request.get url
	callback res.headers


app-exists = (url) ->
	new LazyPromise (res, rej) ->
		headers <- get-headers url
		res <| not headers[\content-length]

url-for-country = (url, country) ->
	r = /^(https\:\/\/itunes\.apple\.com\/)(\w{2})(\/.*$)/
	url.replace r, "$1#{country}$3"



test-example = ->
	us-link = 'https://itunes.apple.com/us/app/lesbian-short-stories-part-1/id384862413?mt=8&uo=4'
	countries = ['us', 'ae', 'ca', 'fr', 'jp', 'sa']
	test-url us-link, countries
	# countries |>parallel-limited-map 4, (c) ->
	# 	url = url-for-country us-link, c
	# 	console.log "checking #c, #url"
	# 	app-exists url |> fmapP (e) -> [c, e]

get-cache-filename = (us-link) ->
	r = /id\d+/
	id = r.exec(us-link)[0]
	cache-directory + id + ".json"

get-cache = (file-name, callback) ->
	(err, body) <~ fs.readFile file-name, {encoding: \utf8}
	callback err, null if !!err
	callback null, JSON.parse body


test-url = (us-link, countries) ->
	file-name = get-cache-filename us-link
	console.log us-link, file-name
	# (err, body) <~ fs.readFile @file-name, {encoding: \utf8}

	cache = {countries: countries, progress: 0, res: []}
	save = (c, e) ->
		cache.res.push [c, e] if c is not null and e is not null
		cache.progress = cache.res.length / cache.countries.length
		fs.writeFileSync file-name, JSON.stringify(cache)

	save null, null
	countries |> serial-map (c) ->
		url = url-for-country us-link, c
		console.log "checking #c, #url"
		app-exists url |> fmapP (e) -> 
			console.log "#c = #e"
			save(c, e)
			[c, e]


exports.get-cache-filename = get-cache-filename
exports.get-cache = get-cache
exports.test-url = test-url
# test!
# 	..then ->
# 		console.log it
# 	..catch ->
# 		console.log it



check-diff = ->
	ae <- get-headers "https://itunes.apple.com/ae/app/pof-free-online-dating/id389638243?mt=8&uo=4"
	us <- get-headers "https://itunes.apple.com/us/app/pof-free-online-dating/id389638243?mt=8&uo=4"


	diff = difference Obj.keys(ae), Obj.keys(us)
	diff |> each (key) -> console.log "#key: #{us[key]}, #{ae[key]}"

	console.log 'us - ae'
	diff = difference Obj.keys(us), Obj.keys(ae)
	diff |> each (key) -> console.log "#key: #{us[key]}, #{ae[key]}"


