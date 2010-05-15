require 'mini_magick'
require 'redmine'
require 'thumbnails_asset_tag_helper_patch'
require 'thumbnails_issues_hooks'

Redmine::Plugin.register :redmine_thumbnails do
  name 'Thumbnails plugin'
  author 'Just Lest'
  description ''
  version '0.1.1'

  settings :default => {
    'thumb_width' => '400',
    'thumb_height' => '0'
  }, :partial => 'settings/thumbnails_settings'
end

Redmine::WikiFormatting::Macros.register do
  desc "Thumb macro"
  macro :thumb do |obj, args|
    url_prefix = Setting.host_name.split("/")[1] || ""
    url_prefix = "/" + url_prefix if url_prefix != ""
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
    attach = container.attachments.find(:first, :conditions => {:filename => filename})
    return nil unless attach

    image = MiniMagick::Image.from_file("files/#{attach.disk_filename}")
    tw = thumb_width.to_i
    th = thumb_height.to_i
    tw = image[:width] if tw == 0
    th = image[:height] if th == 0

    thumb_link = url_for :controller => :thumbnails,
                         :action => :show,
                         :id => attach.id,
                         :width => tw,
                         :height => th
    attach_link = url_for :controller => 'attachments',
                          :action => 'download',
                          :id => attach.id,
                          :filename => attach.filename

    if ((tw == 0 || image[:width] < tw) && (th == 0 || image[:height] < th))
      html = <<-eos
<img src="#{attach_link}" />
eos
    else
      html = <<-eos
<a class="thumb" href="#{attach_link}"><img src="#{thumb_link}" /></a>
eos
    end
    html
  end
end
