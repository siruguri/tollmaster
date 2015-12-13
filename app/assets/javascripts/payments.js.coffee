page_functions = ->
  fill_suffix_box = (data) ->
    $('#primary-key').prop('disabled', true)
    $('#pk-submit').hide()
    $('.entry-form-container').after(data)

    if ($('#send-first-sms-form').length != 0)
      $('#send-first-sms-form').append(
        $("<input>").attr('type', 'hidden').attr('name', 'primary_key').val($('#entry-form #primary-key').val())
      )
    else
      # Let's remove the top form when we get the re-send message
      # to make it clearer

      $('.entry-form-container').hide()
    null

  $('#entry-form').submit (evt) ->
    evt.preventDefault();

    if ($('#primary-key').val().trim().length > 0)
      $.ajax(
        url: $('#entry-form').attr('action'),
        data: {primary_key: $('#primary-key').val()},
        type: 'post',
        success: fill_suffix_box
        )
    else
      $('.error-box').text('Please enter a phone number.')
      $('.error-box').show()

    null

  null

$(document).on('ready page:load', page_functions)
