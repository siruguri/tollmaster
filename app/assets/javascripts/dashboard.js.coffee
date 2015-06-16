$(document).ready -> 
  Stripe.setPublishableKey($('#publishable-key').data('key-value'));
  stripeResponseHandler = (status, response) ->
    form = $('#payments-form')
    form.find('.btn').prop('disabled', false)

    if (response.error)
       # Show the errors on the form
       form.find('#payment-errors').text(response.error.message).show()
       form.find('.btn').prop('disabled', false)
       form.find('.btn').val('Pay!')
    else
       # token contains id, last4, and card type
       token = response.id

       # Insert the token into the form so it gets submitted to the server
       form.append($('<input type="hidden" name="payment_token_record[token_processor]" />').val('stripe'))
       form.append($('<input type="hidden" name="payment_token_record[token_value]" />').val(token))

       # and re-submit
       form.get(0).submit()
    null

  is_numeric = (node) ->
    node.val().trim().match(/^\d+$/)

  has_length = (node, length) ->
    node.val().trim().length == length

  form_is_valid = (j_form) ->
    is_numeric(j_form.find('input#cc_number')) && is_numeric(j_form.find('input#cvc')) && \
      is_numeric(j_form.find('input#exp_month')) && is_numeric(j_form.find('input#exp_year')) && \
      (has_length(j_form.find('input#exp_year'), 2) || has_length(j_form.find('input#exp_year'), 4))\
      && has_length(j_form.find('input#exp_month'), 2) 

  post_form_load = ->
    for id in ['#primary-key', '#cc_number', '#cvc', '#exp_month', '#exp_year']
      $('input' + id).focus (evt) ->
        $('#payment-errors').text('').hide()
        $('.error-box').text('').hide()
        $('.alert').hide()
        
  payment_form_checks = (evt) ->
    form = $(this)
    evt.preventDefault()

    if form_is_valid(form)
      form.find('.btn').prop('disabled', true)
      form.find('.btn').val('Submitting...')
      Stripe.card.createToken(form, stripeResponseHandler)
      # Prevent the form from submitting with the default action
    else
      $('#payment-errors').text('One of your inputs is incorrect. Please re-check your form.').show()

    false

  profile_validate = (formObj) ->
    true

  profile_response_handle = (data) ->
    if (data.updated == true)
      for id in data.update_ids
        $('#' + id).hide('blind', {}, 400)
        $('label[for=' + id + ']').hide('blind', {}, 400)

  show_error  = (data) ->
    $('#dash-error').text(data['message'])
    $('#dash-error').show()
   
  if ($('form#payments-form'))
    # We added a form to add CC info
    post_form_load()
    $('#payments-form').submit(payment_form_checks)

  if ($('form#profile-update-form'))
    form_ajaxify $('form#profile-update-form'), profile_validate, profile_response_handle

