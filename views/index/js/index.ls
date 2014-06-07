{each} = require \prelude-ls


search = (app, country, callback) ->
	link = "https://itunes.apple.com/WebObjects/MZStoreServices.woa/ws/wsSearch?term=#{app}&country=#{country}&media=software&entity=software&limit=25&genreId=&version=2&output=json"

	(e, d) <- $.ajax {url: link, dataType: \jsonp  } .done

	callback e.results


countries |> each ({name, code}) ->
	$ \#search-countries .append "<option value='#code'>#name</option>"

$ \#search-countries .val \US

$ \#appstore-search .on \submit, (e) ->
	e.preventDefault!
	country = $ \#search-countries .val!
	app = $ \#search .val!
	res <- search app, country

	$results = $ \#search-result .html ''
	res |> each (r) ->
		$results.append "<li><a href='/details?url=#{escape(r.trackViewUrl)}&icon=#{escape r.artworkUrl60}&title=#{r.trackName}'><img src='#{r.artworkUrl60}' /> <span class='name'>#{r.trackName}</span></a></li>"
	return false

#data <- search \blinkist, \AE

#console.log data