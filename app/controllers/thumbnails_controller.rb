class ThumbnailsController < ApplicationController
  unloadable
  
  def show
    attach = Attachment.find(params[:id])
    thumb_width = params[:width] || Setting.plugin_redmine_thumbnails["thumb_width"]
    thumb_height = params[:height] || Setting.plugin_redmine_thumbnails["thumb_height"]
    img = Magick::Image.read("files/" + attach.disk_filename).first
    tw = thumb_width.to_i
    th = thumb_height.to_i
    img = Magick::Image.read("files/" + attach.disk_filename).first
    thumb = img.resize_to_fit(tw, th)
    send_data thumb.to_blob, :type => thumb.mime_type, :disposition => 'inline'
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
