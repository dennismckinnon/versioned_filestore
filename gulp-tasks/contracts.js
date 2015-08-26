var gulp = require('gulp');
var gDebug = require('gulp-debug');
var gUtil = require('gulp-util');
var path = require('path');
var del = require('del');
var fs = require('fs-extra');
var gsm = require('gulp-smake');
var os = require('os');

var exports = {};

var options = require('../contracts/contracts.json');
var build = options.build;
var buildtests = options.buildtests;

var buildDir = path.join(build.root, build.buildDir);
var testBuildDir = path.join(build.root, buildtests.buildDir);
var docsDir = path.join(build.root, build.docsDir);

// Just some debugging info. Enable if the SOL_UNIT_BUILD_DEBUG envar is set.
var debugMode = true;// process.env.SOL_UNIT_BUILD_DEBUG;
var dbg;

if(debugMode){
    dbg = gDebug;
} else {
    dbg = gUtil.noop;
}

// TODO better chaining. Fix compiler flag for tests.

// Removes the build folders.
gulp.task('contracts-clean-all', cleanAll);
gulp.task('contracts-clean-build', cleanBuild);
gulp.task('contracts-clean-build-tests', cleanTestBuild);

// Writes the complete source tree to a temp folder. This is also where external source dependencies
// would be fetched and set up if needed.
gulp.task('contracts-pre-build', ['contracts-clean-build'], preBuild);
gulp.task('contracts-pre-build-tests-init', ['contracts-clean-build-tests'], preBuild);

gulp.task('contracts-pre-build-tests', ['contracts-pre-build-tests-init'], preBuildTests);

// Compiles the contracts. This is also where external code dependencies would be set up and built if needed.
gulp.task('contracts-build', ['contracts-pre-build'], buildS);
gulp.task('contracts-build-tests', ['contracts-pre-build-tests'], buildTests);

// Cleanup of the build directory is put here.
gulp.task('contracts-post-build-tests', ['contracts-build-tests'], postBuildTests);

function cleanAll(cb) {
    del([buildDir, docsDir, testBuildDir], cb);
}

function cleanBuild(cb) {
    del([buildDir, docsDir], cb);
}

function cleanTestBuild(cb) {
    del([testBuildDir], cb);
}

function preBuild(){
    // Create an empty folder in temp to use as temporary root when building.
    var temp = path.join(os.tmpdir(), "sol-unit");
    fs.emptyDirSync(temp);
    // Modify the source folder in the object, so that it uses the new temp folder.
    exports.base = temp;
    // Create the path to the root source folder.
    var base = path.join(build.root, build.sourceDir);
    return gulp.src(build.paths, {base: base})
        .pipe(dbg())
        .pipe(gulp.dest(temp));
}

function preBuildTests(){
    // Create the path to the root source folder.
    var base = path.join(build.root, buildtests.testDir);
    return gulp.src(buildtests.paths, {base: base})
        .pipe(dbg())
        .pipe(gulp.dest(exports.base));
}

function buildTests() {
    exports.buildDir = path.join(build.root, buildtests.buildDir);
    return gulp.src(exports.base + '/**/*')
        .pipe(dbg())
        .pipe(gsm.build(build, exports));
}

function buildS() {
    return gulp.src(exports.base + '/**/*')
        .pipe(dbg())
        .pipe(gsm.build(build, exports));
}

function postBuildTests(cb){
    del([path.join(buildDir,'Asserter.*'), path.join(docsDir,'Asserter.*')], cb);
}