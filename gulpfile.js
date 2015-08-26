/*
 *      Build- and test-automation script.
 *
 *      Tasks:
 *
 *      'build-contracts' - build the smart contracts (requires the solidity compiler 'solc')
 *
 *      'build-test-contracts' - build the smart contract unit tests (requires the solidity compiler as well)
 *
 *      'deploy-contracts' - Deploy the system onto a chain.
 */

var gulp = require('gulp');
var contractsModule = require('./lib/contracts');
var fs = require('fs-extra');
var dapp = require('./dapp.json');

require('require-dir')('./gulp-tasks');

// Build the contracts.
gulp.task('build-contracts', ['contracts-build']);

// Build the contract tests.
gulp.task('build-test-contracts', ['contracts-post-build-tests']);

// Deploy contracts task.
gulp.task('deploy-contracts', function(cb){deploy(cb)});

// Default is to build the contracts.
gulp.task('default', ['build-contracts']);

function deploy(callback){
    var abi, compiled;
    try {
        abi = fs.readJsonSync('contracts/build/FileStore.abi');
        compiled = fs.readFileSync('contracts/build/FileStore.binary').toString();
    } catch (error){
        callback(error);
        return;
    }
    contractsModule(function(error, contracts){
        if(error){
            throw error;
        }

        var fsFactory = contracts(abi);

        fsFactory.new({data: compiled}, function(error, contract){
            if(error){
                callback(error);
                return;
            }
            dapp.fs_address = contract.address;
            var err;
            try {
                fs.writeJsonSync('dapp.json', dapp);
            } catch(error){
                err = error;
            }
            callback(err);
        })

    });

}