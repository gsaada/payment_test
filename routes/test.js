
var express = require('express');
var router = express.Router();
var uuid = require('uuid');


var database = {};

/* GET home page. */
router.get('/', function(req, res, next)
{
	res.status(200).send("Payment id not found")
});

router.post("/", function(req, res, next)
{
  var paymentId = uuid();
  var cc = req.body.cc;
  var amount = req.body.amount;

  if((cc)&&(amount))
  {
    database[paymentId] = {'cc': cc, 'amount':amount};
    res.json({"transaction":paymentId});
  }
  else{
    res.status(404).send("Params are not defined correctly")
  }
});

module.exports = router;
