affix = ->
  banner = $('.banner-main')
  if banner.length
    $('.navbar').removeData('bs.affix').removeClass('affix affix-top affix-bottom')
    $('.navbar').affix({
      offset: {
        top: banner.outerHeight()
      }
    })
  else
    $('.navbar').addClass('affix affix-top')
    $('body').css('padding-top', $('.navbar').outerHeight(true))
setupAffix = ->
  $('.navbar').on 'affixed.bs.affix', ->
    $('body').css('padding-top', $('.navbar').outerHeight(true))
  .on 'affixed-top.bs.affix', ->
    $('body').css('padding-top', 0)
  affix()
  $(window).resize ->
    affix()

setupFadeIn = ->
  $('.title').css('opacity',0).animate({opacity: 1}, 2000)
  delay = 500
  $('.subtitle ul').children().css('opacity', 0).each (index, item)->
    $(item).delay(delay).animate({opacity: 1}, 2000)
    delay += 500

setupUserVoice = ->
  window.UserVoice = window.UserVoice || []
  uv = document.createElement('script')
  uv.type = 'text/javascript'
  uv.async = true
  uv.src = '//widget.uservoice.com/5ZIjAw7O0QxQ2Eszc3IJFw.js'
  s = document.getElementsByTagName('script')[0]
  s.parentNode.insertBefore(uv, s)

  window.UserVoice.push ['set', {
    contact_title: 'Send me a message',
    screenshot_enabled: false
  }]

  window.UserVoice.push ['addTrigger', '#contact', {
    position: 'top-right',
    target: false
  }]
  window.UserVoice.push ['addTrigger', '#talk-software', {}]
  window.UserVoice.push ['addTrigger', '#talk-consulting', {}]
  window.UserVoice.push ['addTrigger', '#talk-training', {position: 'top'}]

setupTooltips = ->
  $('.tipped').tooltip()

$(document).ready ->
  # setupFadeIn()
  setupAffix()
  setupUserVoice()
  setupTooltips()