config.gem 'mini_magick'

require 'redmine'
require 'thumbnails_asset_tag_helper_patch'
require 'thumbnails_issues_hooks'

Redmine::Plugin.register :redmine_thumbnails do
  name 'Thumbnails plugin'
  author 'Just Lest'
  description ''
  version '0.2.0'

  settings :default => {
    'thumb_width' => '400',
    'thumb_height' => '0'
  }, :partial => 'settings/thumbnails_settings'
end

Redmine::WikiFormatting::Macros.register do
  desc "Thumb macro"
  macro :thumb do |obj, args|
    thumb_width = nil
    thumb_height = nil
    issue_id = nil

    args.each do |arg|
      name, value = arg.split("=")
      name = name.strip
      if value
        if "width" == name
          thumb_width = value
        elsif "height" == name
          thumb_height = value
        elsif "issue" == name
          issue_id = value.to_i
        end
      end
    end

    thumb_width ||= Setting.plugin_redmine_thumbnails["thumb_width"]
    thumb_height ||= Setting.plugin_redmine_thumbnails["thumb_height"]

    filename = args[0]

    if issue_id
      container = Issue.find(issue_id)
    elsif obj.is_a?(Journal)
      container = obj.issue
    elsif obj.is_a?(WikiContent)
      container = obj.page
    else
      container = obj
    end

    if container.nil?
      container = Document.find(params[:id]) if params[:controller] == 'documents' && params[:action] == 'show'
    end

    return nil unless container && container.attachments
    attach = container.attachments.find_by_filename(filename)
    return nil unless attach && attach.image?

    thumb_link = url_for(:controller => :thumbnails, :action => :show, :id => attach.id,
                         :width => thumb_width, :height => thumb_height)

    attach_link = url_for(:controller => 'attachments', :action => 'download',
                          :id => attach.id, :filename => attach.filename)

    %{<a class="thumb" href="#{attach_link}"><img src="#{thumb_link}" /></a>}
  end
end
