require 'mini_magick'

class ThumbnailsController < ApplicationController
  unloadable

  caches_action :show

  def show
    attach = Attachment.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless attach.image? && attach.visible?

    thumb_width = params[:width] || Setting.plugin_redmine_thumbnails["thumb_width"]
    thumb_height = params[:height] || Setting.plugin_redmine_thumbnails["thumb_height"]

    image = MiniMagick::Image.from_file("#{Attachment.storage_path}/#{attach.disk_filename}")
    image_width = image[:width]
    image_height = image[:height]

    tw = thumb_width.to_i
    th = thumb_height.to_i
    tw = image_width if tw.zero? || image_width < tw
    th = image_height if th.zero? || image_height < th

    image.resize "#{tw}x#{th}"
    send_data image.to_blob, :type => image['image/%m'], :disposition => 'inline'
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
