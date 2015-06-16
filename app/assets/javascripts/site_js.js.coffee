window.form_ajaxify = (f, validate, success_callback) ->
  f.submit (e) ->
    e.preventDefault()
    if validate($(this))
      data = $(this).serialize()
      $.ajax({
        url: f.attr('action'),
        type: "POST",
        data: data,
        dataType: 'json',
        success: success_callback
        })
