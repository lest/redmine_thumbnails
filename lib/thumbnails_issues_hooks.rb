class ThumbnailsIssuesHooks < Redmine::Hook::ViewListener
  def view_issues_show_description_bottom(context = {})
    out = ''
    out += <<JS
<script type="text/javascript" src="#{root_path}plugin_assets/redmine_thumbnails/javascripts/ZeroClipboard.js"></script>
<script type="text/javascript">
  ZeroClipboard.setMoviePath('#{root_path}plugin_assets/redmine_thumbnails/images/ZeroClipboard.swf');
  var counter = 0;
  $$('.issue .attachments p').each(function (element) {
    var filename = element.down().innerHTML;
    if (!filename.match(/(jpe?g|png|gif)$/i)) {
      return;
    }

    var button = document.createElement('img');
    var button_id = 'thumbnail_clipboard_' + counter
    button.id = button_id;
    button.width = '16';
    button.height = '16';
    button.src = '#{root_path}images/copy.png';

    element.appendChild(button);

    var clip = new ZeroClipboard.Client();
    clip.setText('{{thumb(' + filename + ', issue=#{context[:issue].id})}}');
    clip.glue(button_id);
    clip.addEventListener('onComplete', function () {
      Effect.Pulsate(button);
    });

    counter++;
  });
</script>
JS
    out
  end
end
