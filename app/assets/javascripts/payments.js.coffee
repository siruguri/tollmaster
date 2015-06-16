page_functions = ->
  fill_suffix_box = (data) ->
    $('#primary-key').prop('disabled', true)
    $('#pk-submit').hide()
    $('#entry-form-paragraph').after(data)

    if ($('#send-first-sms-form'))
      $('#send-first-sms-form').append(
        $("<input>").attr('type', 'hidden').attr('name', 'primary_key').val($('#entry-form #primary-key').val())
      )
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
