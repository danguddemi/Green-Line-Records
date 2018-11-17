var express = require('express');
var router = express.Router();

// middleware that is specific to this router
router.use(function timeLog (req, res, next) {
  console.log('Time: ', Date.now())
  next()
})

var selectQuery = function(req, res, queryString) {
  	global.connection.query(queryString, function (error, results, fields) {
  		if (error) throw error;
  		// res.send(JSON.stringify({"status": 200, "error": null, "response": results}));
      res.send(results);
  	});
}

// Gets According to Primary Key
router.get('/', function(req, res) {
  selectQuery(req, res, 'SELECT * FROM live_session');
});

router.get('/id/:id', function(req, res) {
  // res.send(req.params)
  var id = req.params.id;
  var str = 'SELECT * FROM live_session where live_session_id=' + id;
  selectQuery(req, res, str);
});

// Gwts According to location
router.get('/location', function(req, res) {
  const str = 'SELECT * FROM live_session join location on live_session.location_id = location.location_id';
  selectQuery(req, res, str);
})

router.get('/location/id/:id', function(req, res) {
  var id = req.params.id;
  var str = 'SELECT * FROM live_session join location on live_session.location_id = ' + id;
  selectQuery(req, res, str);
})

router.get('/location/name/:name', function(req, res) {
  var id = req.params.name;
  id = id.replace('_', ' ');
  var str = 'SELECT * FROM live_session join location on live_session.location_id = location.location_id where location.location_name = \'' + id + '\'';
  selectQuery(req, res, str);
})

// Gets According to Show names
router.get('/name', function(req, res) {
  selectQuery(req, res, 'SELECT show_name FROM live_session');
});

router.get('/name/:name', function(req, res) {
  var name = req.params.name;
  var str = 'SELECT * FROM live_session where show_name like \'%' + name + '%\'';
  selectQuery(req, res, str);
});

// Gets According to Date and/or Time
router.get('/datetime/:YY-:MM-:DD-:HH-:MI-:SS', function(req, res) {
  var date = req.params.YY + "-" + req.params.MM + "-" + req.params.DD;
  var time = req.params.HH + ":" + req.params.MI + ":" + req.params.SS;
  var str = "SELECT * FROM live_session where date=\'" + date + "\' and start_time=\'" + time + "\'";
  selectQuery(req, res, str);
})

router.get('/datetime/time/:HH-:MI-:SS', function(req, res) {
  var time = req.params.HH + ":" + req.params.MI + ":" + req.params.SS;
  var str = "SELECT * FROM live_session where start_time=\'" + time + "\'";
  selectQuery(req, res, str);
})



module.exports = router;