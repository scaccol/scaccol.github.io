var express = require('express');
var mysql = require('./dbcon.js');

var app = express();
var handlebars = require('express-handlebars').create({defaultLayout:'main'});

app.engine('handlebars', handlebars.engine);
app.set('view engine', 'handlebars');
app.set('port', process.argv[2]);

app.get('/',function(req,res,next){
  var context = {};
  mysql.pool.query('SELECT * FROM EMPLOYEE', function(err, rows, fields){
    //context.results = JSON.stringify(rows);
    res.render('displayTable',{data: rows});
  });
});

app.use(function(req,res){
  res.status(404);
  res.render('404');
});

app.use(function(err, req, res, next){
    console.error(err.stack);
    res.status(500);
    res.render('500');
  });



app.listen(app.get('port'), function(){
  console.log('Express started on http://localhost:' + app.get('port') + '; press Ctrl-C to terminate.');
});
