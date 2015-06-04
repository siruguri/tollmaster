$(document).ready -> 
  show_error  = (data) ->
    $('#dash-error').text(data['message'])
    $('#dash-error').show()

  $('form.dash-action-form').submit (evt) ->
    $('#dash-error').hide()
    $(this).append($('<input type="hidden">').attr('name', 'link_secret').val($('#link-secret').data('value')))
    $(this).get(0).submit()
