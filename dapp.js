var express = require('express');
var path = require('path');
var bodyParser = require('body-parser');
var fs = require('fs-extra');
var contractsMod = require('./lib/contracts');
// Just for the utilities.
var erisC = require('eris-contracts');
var dapp = require('./dapp.json');

var vfs, app;
var contracts;

var zeroBytes = "0000000000000000000000000000000000000000000000000000000000000000";
var latestHex = erisC.utils.padRight(erisC.utils.atoh("latest"), 32);

exports.start = function(callback){
    contractsMod(function(error, _contracts){
        if(error){
            callback(error);
            return;
        }
        contracts = _contracts;
        vfs = loadVfsContract();
        app = loadApp();
        callback(null, app);
    });
};

// Load the express app.
function loadApp() {
    app = express();
    app.use(bodyParser.json());
    app.use(express.static(path.join(__dirname, 'public')));
    addApiRoutes(app, vfs);
    // catch 404
    app.use(function (req, res, next) {
        var err = new Error('Not Found');
        err.status = 404;
    });
    return app;
}

// Load the filestore contract object.
function loadVfsContract() {
    if (!dapp.fs_address) {
        throw new Error("Bank contract not deployed");
    }
    var abi = fs.readJsonSync('./contracts/build/FileStore.abi');
    var vfsFactory = contracts(abi);
    return vfsFactory.at(dapp.fs_address);
}

/*
    Creating and getting files

    Create a file:      POST    /api/files
    Delete a file:      DELETE  /api/files
    Get all files:      GET     /api/files
    Get a file:         GET     /api/files/:name

    Push commit:        POST    /api/files/:name/commits
    Get commits:        GET     /api/files/:name/commits
    Get a file commit:  GET     /api/files/:name/commits/:ref
    Get latest commit:  GET     /api/files/:name/commits/latest

    Add tag:            POST    /api/files/:name/tags
    Remove tag:         DELETE  /api/files/:name/tags
    Get all tags:       GET     /api/files/:name/tags
    Get a tag:          GET     /api/files/:name/tags/:tag

    Add file editor:    POST    /api/files/:name/editors
    Remove file editor: DELETE  /api/files/:name/editors
    Get all editors:    GET     /api/files/:name/editors
    (can't get single editor atm. as they are just the address that they're identified by)

    DATA



 */

// Add routes.
function addApiRoutes(app, vfs){

    var abi = fs.readJsonSync('./contracts/build/File.abi');
    var fileFactory = contracts(abi);

    function getFC(address){
        return fileFactory.at(address);
    }

    app.post('/api/files', function(req, res, next){
        if(!req.body.file_name || req.body.file_name == ""){
            res.status(400).send('No filename provided.');
            return;
        }
        vfs.createFile(fn, function(error, result){

            if(error){
                res.status(500).send('Failed to create file: ' + error.message);
            } else {
                var code = result.toNumber();
                if(code != 0){
                    res.status(500).send("Failed to endow. Error code: " + code);
                } else {
                    res.status(200).send({});
                }
            }
        });

    });

    // Get username from address. See public/javascript/vfs.js for explanation why this is
    // manually set to a transaction (even though its really a call).
    app.get('/api/files/:filename', function(req, res, next){
        var name = req.param('filename');
        vfs.getFileAddress(erisC.utils.atoh(name), function(error, fileAddress){
            if(error){
                res.status(500).send('Failed to get fileAddress: ' + error.message);
            } else {
                res.status(200).send({file_address: fileAddress});
            }
        });
    });

    app.post('/api/files/:filename/commits', function(req, res, next){
        if(!req.body.file_hash || req.body.file_hash == ""){
            res.status(400).send('No hash provided.');
            return;
        }
        var name = req.param('filename');
        console.log(name);
        vfs.getFileAddress(erisC.utils.atoh(name), function(error, fileAddress){
            if(error){
                res.status(500).send('Failed to get fileAddress: ' + error.message);
            } else {
                var fc = getFC(fileAddress);
                fc.commit(req.body.file_hash, function(error, result){
                    if(error){
                        res.status(500).send('Failed to commit: ' + error.message);
                    } else {
                        var code = result.toNumber();
                        if(code != 0){
                            res.status(500).send("Failed to commit. Error code: " + code);
                        } else {
                            res.status(200).send({});
                        }
                    }
                });
            }
        });

    });

    // Get username from address. See public/javascript/vfs.js for explanation why this is
    // manually set to a transaction (even though its really a call).
    app.get('/api/files/:filename/tags/latest', function(req, res, next){
        var name = req.param('filename');
        vfs.getFileAddress(erisC.utils.atoh(name), function(error, fileAddress){
            if(error){
                res.status(500).send('Failed to get fileAddress: ' + error.message);
            } else {
                var fc = getFC(fileAddress);
                fc.getRef(latestHex, function(error, hash){
                    if(error){
                        res.status(500).send('Failed to get latest ref: ' + error.message);
                    } else {
                        res.status(200).send({file_hash: hash});
                    }
                });
            }
        });
    });

}