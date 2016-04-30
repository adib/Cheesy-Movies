# OMDB API Notes

- Open Movie Database
- Reference: http://omdbapi.com
- Search works for both HTTP and HTTPS (although the API examples are HTTP)


## Ratings

- Only available at the “movie details” call – not available on search.

## Images

- Relies on IMDB
- has a size parameter at the end of the URL
 	- `http://ia.media-imdb.com/images/M/MV5BMTc5MTg0ODgxMF5BMl5BanBnXkFtZTcwODEzOTYwMw@@._V1_SX600.jpg`
 	- `http://ia.media-imdb.com/images/M/MV5BMTc5MTg0ODgxMF5BMl5BanBnXkFtZTcwODEzOTYwMw@@._V1_SX600.jpg`
 	- `http://ia.media-imdb.com/images/M/MV5BMTc5MTg0ODgxMF5BMl5BanBnXkFtZTcwODEzOTYwMw@@._V1_SX64.jpg`
- Can use regex -> replace V1_SX{d+}.jpg with the correct desired size


## Search Response

- Search by string, type, year
- Paginated API, returns 10 items at a time

Sample search response:

	{
	  "Search": [
	    {
	      "Title": "Frozen",
	      "Year": "2013",
	      "imdbID": "tt2294629",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTQ1MjQwMTE5OF5BMl5BanBnXkFtZTgwNjk3MTcyMDE@._V1_SX300.jpg"
	    },
	    {
	      "Title": "Frozen",
	      "Year": "2010",
	      "imdbID": "tt1323045",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTc5MTg0ODgxMF5BMl5BanBnXkFtZTcwODEzOTYwMw@@._V1_SX300.jpg"
	    },
	    {
	      "Title": "The Frozen Ground",
	      "Year": "2013",
	      "imdbID": "tt2005374",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMjA0MjAyMjIxMl5BMl5BanBnXkFtZTcwNTQ1NDc2OQ@@._V1_SX300.jpg"
	    },
	    {
	      "Title": "Frozen River",
	      "Year": "2008",
	      "imdbID": "tt0978759",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTk2NjMwMDgzNF5BMl5BanBnXkFtZTcwMDY0NDY3MQ@@._V1_SX300.jpg"
	    },
	    {
	      "Title": "Frozen Planet",
	      "Year": "2011",
	      "imdbID": "tt2092588",
	      "Type": "series",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTU5MDI2NjU0N15BMl5BanBnXkFtZTcwNDMwMTA0Nw@@._V1_SX300.jpg"
	    },
	    {
	      "Title": "Frozen Fever",
	      "Year": "2015",
	      "imdbID": "tt4007502",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTYxMTIxNDEwNV5BMl5BanBnXkFtZTgwODY4ODk1NjE@._V1_SX300.jpg"
	    },
	    {
	      "Title": "Frozen Stiff",
	      "Year": "2002",
	      "imdbID": "tt0301634",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTk5NDc0MjU3Nl5BMl5BanBnXkFtZTcwNDc3NTU3OQ@@._V1_SX300.jpg"
	    },
	    {
	      "Title": "Frozen Land",
	      "Year": "2005",
	      "imdbID": "tt0388318",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTI0OTg0NTYwNF5BMl5BanBnXkFtZTcwNTQ0MjA0MQ@@._V1_SX300.jpg"
	    },
	    {
	      "Title": "A Frozen Flower",
	      "Year": "2008",
	      "imdbID": "tt1155053",
	      "Type": "movie",
	      "Poster": "http://ia.media-imdb.com/images/M/MV5BMTQzMDQ5ODY1MF5BMl5BanBnXkFtZTgwNDI5NTAzMTE@._V1_SX300.jpg"
	    },
	    {
	      "Title": "Warcraft III: The Frozen Throne",
	      "Year": "2003",
	      "imdbID": "tt0372023",
	      "Type": "game",
	      "Poster": "N/A"
	    }
	  ],
	  "totalResults": "215",
	  "Response": "True"
	}

## Details Response

Sample details:

	{
	  "Title": "Frozen",
	  "Year": "2013",
	  "Rated": "PG",
	  "Released": "27 Nov 2013",
	  "Runtime": "102 min",
	  "Genre": "Animation, Adventure, Comedy",
	  "Director": "Chris Buck, Jennifer Lee",
	  "Writer": "Jennifer Lee (screenplay), Hans Christian Andersen (story inspired by \"The Snow Queen\" by), Chris Buck (story by), Jennifer Lee (story by), Shane Morris (story by)",
	  "Actors": "Kristen Bell, Idina Menzel, Jonathan Groff, Josh Gad",
	  "Plot": "When the newly crowned Queen Elsa accidentally uses her power to turn things into ice to curse her home in infinite winter, her sister, Anna, teams up with a mountain man, his playful reindeer, and a snowman to change the weather condition.",
	  "Language": "English, Icelandic",
	  "Country": "USA",
	  "Awards": "Won 2 Oscars. Another 70 wins & 56 nominations.",
	  "Poster": "http://ia.media-imdb.com/images/M/MV5BMTQ1MjQwMTE5OF5BMl5BanBnXkFtZTgwNjk3MTcyMDE@._V1_SX300.jpg",
	  "Metascore": "74",
	  "imdbRating": "7.6",
	  "imdbVotes": "406,728",
	  "imdbID": "tt2294629",
	  "Type": "movie",
	  "tomatoMeter": "89",
	  "tomatoImage": "certified",
	  "tomatoRating": "7.7",
	  "tomatoReviews": "217",
	  "tomatoFresh": "193",
	  "tomatoRotten": "24",
	  "tomatoConsensus": "Beautifully animated, smartly written, and stocked with singalong songs, Frozen adds another worthy entry to the Disney canon.",
	  "tomatoUserMeter": "86",
	  "tomatoUserRating": "4.3",
	  "tomatoUserReviews": "302449",
	  "tomatoURL": "http://www.rottentomatoes.com/m/frozen_2013/",
	  "DVD": "18 Mar 2014",
	  "BoxOffice": "$400.7M",
	  "Production": "Walt Disney Pictures",
	  "Website": "http://www.disney.com/frozen",
	  "Response": "True"
	}

