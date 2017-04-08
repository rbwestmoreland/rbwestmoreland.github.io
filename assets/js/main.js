window.app = window.app || {};

window.app.ensureExternalLinksOpenNewWindows = function(){
	$(document.links).filter(function() {
		return this.hostname != window.location.hostname;
	}).attr('target', '_blank');
};

window.app.ensureTimeTagsAreRelative = function() {
	if (!window.moment) return;

	$('time').each(function() {
		var $el = $(this),
				title = $el.text(),
				timestamp = $el.attr('datetime');

		if (timestamp){
			var ago = moment(timestamp).fromNow();
			$el.html(ago);
			$el.attr('title', title);
			$el.css('cursor', 'help');
		}
	});
};

window.app.init = function() {
	window.app.ensureExternalLinksOpenNewWindows();
	window.app.ensureTimeTagsAreRelative();
};

$(document).ready(function () {
	app.init();
});