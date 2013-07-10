# Auto-login when logged-in in other browser window (9887c4e)
if document.getElementById('login-form')
  cookie_regex = /(^|;)\s*tgt=/
  checkCookieExists = ->
    if(cookie_regex.test(document.cookie))
      service = document.getElementById('service').getAttribute('value')
      url = '/login'
      url += ('?service=' + encodeURIComponent(service)) if service
      window.location = url
    else
      setTimeout(checkCookieExists, 1000)
  checkCookieExists()
