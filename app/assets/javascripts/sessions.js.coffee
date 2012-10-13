window.signIn = ->
  $.post '/session', null, ->
    location.href = '/dashboard'