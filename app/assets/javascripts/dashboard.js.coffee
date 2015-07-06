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

  is_blank = (node) ->
    node.val().trim().length == 0

  is_not_email = (node) ->
    # for now, we'll just check that it's non zero and has an @
    v = node.val().trim()
    v.size == 0 || !(v.match(/@/))

  is_numeric = (node) ->
    node.val().trim().match(/^\d+$/)

  has_length = (node, length) ->
    node.val().trim().length == length

  form_is_valid = (j_form) ->
    cond1 = true
    if (is_blank(j_form.find('#email_address')) || is_not_email(j_form.find('#email_address')))
        cond1 = false

    if (is_blank(j_form.find('#username')))
        cond1 = false

    cond2 = is_numeric(j_form.find('input#cc_number')) && is_numeric(j_form.find('input#cvc')) && \
      is_numeric(j_form.find('input#exp_month')) && is_numeric(j_form.find('input#exp_year')) && \
      (has_length(j_form.find('input#exp_year'), 2) || has_length(j_form.find('input#exp_year'), 4))\
      && has_length(j_form.find('input#exp_month'), 2) 

    cond1 && cond2

  post_form_load = ->
    for id in ['#username', '#email_address', '#primary-key', '#cc_number', '#cvc', '#exp_month', '#exp_year']
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
      $('#payment-errors').text('One of your inputs is missing or incorrect. Please re-check your form.').fadeIn(400)

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

