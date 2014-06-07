{each, map, any, zip, group-by, obj-to-pairs, div, find} = require \prelude-ls

query-string = document.location.search.substring(1)
{url, title, icon} = decode-query-string query-string
$ \h1 .text title
$ \#icon .attr \src, icon
us-link = url

partition-in-n-parts = (n, arr) -->
	(arr `zip` [0 to arr.length - 1]) 
		|> (group-by ([_, i]) -> i `div` n) 
		|> obj-to-pairs 
		|> map (.1) >> map (.0)

$list = $ \#list-of-countries
countries |> each ({name, code}) ->
	$el = $ "<div class='item'><input type='checkbox' value='#code' id='country-#code' name='country' /><label for='country-#code'>#name</label></div>"
	if selected-countries.indexOf(code) > -1
		$el.find \input .attr \checked, \checked
	$list.append $el


$ \#search .on \submit, (e) ->
	selected-countries = $ 'input[name=country]:checked' .toArray!
	codes = selected-countries |> map (t) -> $ t .val!
	console.log codes
	e.preventDefault!
	(d) <- $.post( '/search', {countries: JSON.stringify(codes), link: us-link } ).done
	set-timeout check-loop, 2000
	return false

check = (callback) ->
	d <- $.post( '/check', { link: us-link } ).done
	callback d

check-loop = ->
	d <- check
	render d
	if d.progress < 1 then
		set-timeout check-loop, 2000

render = ({progress, res}) ->
	$ \#progress .text <| "Progress: " + Math.round(progress*100) + '%'
	$ul = $ \#countries
		..find \li .remove!
	res |> each ([code, exists]) ->
		country = find (.code == code), countries
		$li = $ "<li>(#code) #{country.name}</li>"
		if exists then
			$li.addClass \exists
		$ul.append $li


window.check = check