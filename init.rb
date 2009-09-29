require 'redmine'
require 'thumbnails_asset_tag_helper_patch'

Redmine::Plugin.register :redmine_thumbnails do
  name 'Thumbnails plugin'
  author 'Just Lest'
  description ''
  version '0.1.0'
  
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
    args.each do |arg|
      name, value = arg.split("=")
      name = name.strip
      if value
        if "width" == name
          thumb_width = value
        elsif "height" == name
          thumb_height = value
        end
      end
    end
    thumb_width ||= Setting.plugin_redmine_thumbnails["thumb_width"]
    thumb_height ||= Setting.plugin_redmine_thumbnails["thumb_height"]
    filename = args[0]
    if obj.is_a?(Issue)
      container = obj
    elsif obj.is_a?(Journal)
      container = obj.issue
    elsif obj.is_a?(WikiContent)
      container = obj.page
    end
    return nil unless container
    attach = Attachment.find(:first, :conditions => {
     :container_id => container.id,
     :container_type => container.class.name,
     :filename => filename
    })
    return nil unless attach
    
    thumb_link = url_for :controller => :thumbnails,
                         :action => :show,
                         :id => attach.id,
                         :width => thumb_width,
                         :height => thumb_height
    attach_link = url_for :controller => 'attachments',
                          :action => 'download',
                          :id => attach.id,
                          :filename => attach.filename
    
    img = Magick::Image.read("files/" + attach.disk_filename).first
    tw = thumb_width.to_i
    th = thumb_height.to_i
    if ((tw == 0 || img.columns < tw) && (th == 0 || img.rows < th))
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
