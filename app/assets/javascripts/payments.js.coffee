page_functions = ->
  Stripe.setPublishableKey($('#publishable-key').data('key-value'));
  stripeResponseHandler = (status, response) ->
    form = $('#payments-form')
    form.find('.btn').prop('disabled', false)

    if (response.error)
       # Show the errors on the form
       form.find('.payment-errors').text(response.error.message)
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
      has_length(j_form.find('input#exp_year'), 2) && has_length(j_form.find('input#exp_month'), 2) 

  for id in ['#primary-key', '#cc_number', '#cvc', '#exp_month', '#exp_year']
    $('input' + id).focus (evt) ->
      $('.payment-errors').text('').hide()
      $('.error-box').text('').hide()
      $('.alert').hide()
        
  payment_form_checks = (evt) ->
    form = $(this)
    if form_is_valid(form)
      form.find('.btn').prop('disabled', true)
      form.find('.btn').val('Submitting...')

      Stripe.card.createToken(form, stripeResponseHandler)
      # Prevent the form from submitting with the default action
    else
      $('.payment-errors').text('One of your inputs is incorrect. Please re-check your form.')

    false

  fill_suffix_box = (data) ->
    $('#primary-key').prop('disabled', true)
    $('#pk-submit').hide()
    $('#entry-form').after(data)

    if ($('#payments-form'))
      # We added a form to add CC info
      $('#payments-form').submit(payment_form_checks)
      $('#payments-form').append(
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
