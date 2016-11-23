var express = require('express');
var router = express.Router();
var uuid = require('uuid');
var redis = require("redis")
var Promise = require("bluebird");

redisIP = "192.168.99.100";
reditPort = 6379

client = redis.createClient(reditPort,redisIP);

Promise.promisifyAll(redis.RedisClient.prototype);
Promise.promisifyAll(redis.Multi.prototype);

/* GET home page. */
router.get('/:transactionId', function(req, res, next)
{
    var transactionId = req.params.transactionId;
    console.log(transactionId);
    client.hgetallAsync(transactionId).then(function(redisRes) {
        // check if exist in DB
        if(redisRes){
            res.json(redisRes);
        }
        else{
            res.status(404).send("Payment id not found")
        }
        });
});

router.post("/", function(req, res, next)
{
    var paymentId = uuid();
    var cc = req.body.cc;
    var amount = req.body.amount;

    if((cc)&&(amount))
    {
        client.hmset([paymentId, 'cc', cc, 'amount', amount], function(err,res){
            if(err)
            {

            }
        });
        res.json({"transaction":paymentId});
    }
    else{
        console.log(cc);
        console.log(amount);
        res.status(404).send("Params are not defined correctly")
    }
});

module.exports = router;
