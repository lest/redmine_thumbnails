class ThumbnailsController < ApplicationController
  unloadable

  caches_action :show

  def show
    attach = Attachment.find(params[:id])
    thumb_width = params[:width] || Setting.plugin_redmine_thumbnails["thumb_width"]
    thumb_height = params[:height] || Setting.plugin_redmine_thumbnails["thumb_height"]
    image = MiniMagick::Image.from_file("files/#{attach.disk_filename}")
    image.resize "#{thumb_width}x#{thumb_height}"
    send_data image.to_blob, :type => image['image/%m'], :disposition => 'inline'
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
