// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-datepicker
//= require_tree .

function getRndColor() {
    var r = 255*Math.random()|0,
        g = 255*Math.random()|0,
        b = 255*Math.random()|0;
    return 'rgb(' + r + ',' + g + ',' + b + ')';
}

function rgbSum(rgb){
	var s = 0;
	var str = rgb.toString().substr(4);
	str = str.substr(0,str.length - 1);
	str = str.split(',');
	s = parseInt(str[0]) + parseInt(str[1]) + parseInt(str[2]);
	return s;
}

function capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

function popOut(){
	$('#chatWindow').width(200);
	$('#chatForm').show();
}

function popIn(){
	$('#chatWindow').width(27);
	$('#chatForm').hide();
}