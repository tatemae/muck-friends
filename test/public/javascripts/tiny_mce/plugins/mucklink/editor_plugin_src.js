/**
 * Modified version of advlink
 * @author Tatemae
 * @copyright Copyright � 2009, Tatemae, All rights reserved.
 */
(function() {
	tinymce.create('tinymce.plugins.MuckLink', {
		init : function(ed, url) {
			this.editor = ed;
			// Register commands
			ed.addCommand('mceMuckLink', function() {
				var se = ed.selection;
				// No selection and not in link
				if (se.isCollapsed() && !ed.dom.getParent(se.getNode(), 'A'))
					return;
				ed.windowManager.open({
					file : jQuery('#tiny_mce_links_path').val(),
					width : parseInt(jQuery('#tiny_mce_links_width').val()) + parseInt(ed.getLang('mucklink.delta_width', 0)),
					height : parseInt(jQuery('#tiny_mce_links_height').val()) + parseInt(ed.getLang('mucklink.delta_height', 0)),
					inline : 1
				}, {
					plugin_url : url
				});
			});
			// Register buttons
			ed.addButton('mucklink', {
				title : 'Create Link',
				cmd : 'mceMuckLink',
				image : '/images/tinymce/link.jpg'
			});
			ed.addShortcut('ctrl+k', 'Create Link', 'mceMuckLink');
			ed.onNodeChange.add(function(ed, cm, n, co) {
				cm.setDisabled('link', co && n.nodeName != 'A');
				cm.setActive('link', n.nodeName == 'A' && !n.name);
			});
		},
		getInfo : function() {
			return {
				longname : 'Advanced file',
				author : 'Tatemae',
				authorurl : 'http://Tatemae.com',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});
	// Register plugin
	tinymce.PluginManager.add('mucklink', tinymce.plugins.MuckLink);
})();