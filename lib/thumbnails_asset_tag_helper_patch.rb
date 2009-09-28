module ActionView
  module Helpers
    module AssetTagHelper
      def javascript_include_tag_with_thumbnails(*sources)
        out = javascript_include_tag_without_thumbnails(*sources)
        if sources.is_a?(Array) and sources[0] == 'jstoolbar/textile'
          out += javascript_tag <<-javascript_tag
jsToolBar.prototype.elements.thumb = {
	type: 'button',
	title: 'Thumb',
	fn: {
		wiki: function() { this.encloseSelection("{{thumb(", ")}}") }
	}
}
javascript_tag
          out += stylesheet_link_tag 'thumb', :plugin => 'redmine_thumbnails'
        end
        out
      end
      alias_method_chain :javascript_include_tag, :thumbnails
    end
  end
end
