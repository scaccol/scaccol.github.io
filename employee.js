module.exports = function(){
    var express = require('express');
    var router = express.Router();

    function getProjects(res, mysql, context, complete){
        mysql.pool.query("SELECT Pname as Name, Pnumber as Number, Plocation as Location FROM PROJECT", function(error, results, fields){
            if(error){
                res.write(JSON.stringify(error));
                res.end();
            }
            context.projects  = results;
            complete();
        });
    }

    function getEmployees(res, mysql, context, complete){
        mysql.pool.query("SELECT Fname, Lname, Salary, Dno FROM EMPLOYEE", function(error, results, fields){
            if(error){
                res.write(JSON.stringify(error));
                res.end();
            }
            context.employee = results;
            complete();
        });
    }

    function getEmployeebyProject(req, res, mysql, context, complete){
      var query = "SELECT Fname, Lname, Salary, Dno FROM EMPLOYEE INNER JOIN WORKS ON ON Ssn = WORKS_ON.Essn WHERE WORKS_ON.Pno = ?";
      console.log(req.params)
      var inserts = [req.params.homeworld]
      mysql.pool.query(query, inserts, function(error, results, fields){
            if(error){
                res.write(JSON.stringify(error));
                res.end();
            }
            context.employee = results;
            complete();
        });
    }

    /* Find people whose fname starts with a given string in the req */
    function getEmployeeWithNameLike(req, res, mysql, context, complete) {
      //sanitize the input as well as include the % character
       var query = "SELECT Fname, Lname, Salary, Dno FROM EMPLOYEE WHERE Fname LIKE " + mysql.pool.escape(req.params.s + '%');
      console.log(query)

      mysql.pool.query(query, function(error, results, fields){
            if(error){
                res.write(JSON.stringify(error));
                res.end();
            }
            context.employee = results;
            complete();
        });
    }

    function getProjectInfo(res, mysql, context, id, complete){
        var sql = "SELECT Fname, Lname, Salary, Dno FROM EMPLOYEE WHERE Fname = ?";
        var inserts = [id];
        mysql.pool.query(sql, inserts, function(error, results, fields){
            if(error){
                res.write(JSON.stringify(error));
                res.end();
            }
            context.projects = results[0];
            complete();
        });
    }


    router.get('/', function(req, res){
        var callbackCount = 0;
        var context = {};
        context.jsscripts = ["filterEmployee.js","searchEmployee.js"];
        var mysql = req.app.get('mysql');
        getEmployees(res, mysql, context, complete);
        getProjects(res, mysql, context, complete);
        function complete(){
            callbackCount++;
            if(callbackCount >= 2){
                res.render('employee', context);
            }
        }
    });

    router.get('/filter/:project', function(req, res){
        var callbackCount = 0;
        var context = {};
        context.jsscripts = ["filterEmployee.js"];
        var mysql = req.app.get('mysql');
        getEmployeebyProject(req,res, mysql, context, complete);
        getProjects(res, mysql, context, complete);
        function complete(){
            callbackCount++;
            if(callbackCount >= 2){
                res.render('people', context);
            }

        }
    });

    /*Display all people whose name starts with a given string. Requires web based javascript to delete users with AJAX */
    router.get('/search/:s', function(req, res){
        var callbackCount = 0;
        var context = {};
        context.jsscripts = ["searchEmployee.js"];
        var mysql = req.app.get('mysql');
        getEmployeeWithNameLike(req, res, mysql, context, complete);
        getProjects(res, mysql, context, complete);
        function complete(){
            callbackCount++;
            if(callbackCount >= 2){
                res.render('people', context);
            }
        }
    });

    return router;
}();
