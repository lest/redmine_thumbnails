require 'redmine'
require 'thumbnails_asset_tag_helper_patch'
require 'thumbnails_issues_hooks'

Redmine::Plugin.register :redmine_thumbnails do
  name 'Thumbnails plugin'
  author 'Just Lest'
  description ''
  version '0.3.0'

  requires_redmine_plugin :redmine_image_cache, '0.0.1'

  settings :default => {
    'thumb_width'  => '400',
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
        case name
        when "width"
          thumb_width = value
        when "height"
          thumb_height = value
        when "issue"
          issue_id = value.to_i
        end
      end
    end

    thumb_width  ||= Setting.plugin_redmine_thumbnails['thumb_width']
    thumb_height ||= Setting.plugin_redmine_thumbnails['thumb_height']
    thumb_width, thumb_height = [thumb_width, thumb_height].map(&:to_i)

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
      case [params[:controller], params[:action]]
      when ['documents', 'show']
        container = Document.find(params[:id])
      end
    end

    return nil unless container && container.attachments
    attach = container.attachments.find_by_filename(filename)
    return nil unless attach && attach.image?

    resize_options = ''
    resize_options += "#{thumb_width}" unless thumb_width.zero?
    resize_options += "x#{thumb_height}" unless thumb_height.zero?

    thumb_url  = url_for_mogrified_attach(attach, [['resize', resize_options]])
    attach_url = url_for(:controller => 'attachments', :action => 'download', :id => attach.id, :filename => attach.filename)

    %{<a class="thumb" href="#{attach_url}"><img src="#{thumb_url}" alt="" /></a>}
  end
end
