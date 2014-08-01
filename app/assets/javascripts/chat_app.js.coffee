class @ChatApp

  messageTemplate: (message, channelName = 'broadcast', user = '') ->
    """
    <div>
      <span>
        <label class='label label-#{if channelName == 'broadcast' then 'warning' else 'info'}'>
          [#{channelName}]
        </label> <font color='GREEN'>#{user}</font>: #{message}
      </span>
    </div>
    """
  joinTemplate: (channelName,user = @username) ->
    """
    <div>
      <span>
        <label class='label label-'>
          #{user}
        </label> joined to #{channelName} room
      </span>
    </div>
    """
  actionTemplate: (user, action) ->
    """
    <i>#{user} #{action}</i>
    """
  constructor: (@currentChannel = undefined, @username = undefined) ->
    @dispatcher = new WebSocketRails(window.location.host + "/websocket")
    @bindEvents()

  bindEvents: ->
    @dispatcher.bind 'user_info', @setUserInfo
    @dispatcher.bind 'new_messagee', @receiveGlobalMessage
    @dispatcher.bind 'action', @action_message
    $('#send_message').click @sendMessage
    $('#new_message').keypress @keysPress
    $('.join_chan').click @joinChannel

  setUserInfo: (userInfo) =>
    @username = userInfo.user

  receiveGlobalMessage: (message) =>
    if message.text
      $('#chat_history').append @messageTemplate(message.text)
    else
      alert "Введите сообщение"

  receiveMessage: (message) =>
    if message.text
      $('#chat_history').append @messageTemplate(message.text, @currentChannel.name, @username)
    else
      alert "Введите сообщение"

  keysPress: (e) =>
    @dispatcher.trigger 'action', username: @username , action: 'typing...'


  action_message: (e) =>
    area = $('.system_area')
    if e.user != @username
      area.children().remove()
      area.append @actionTemplate(e.user, e.action)
      $('.alert').hide 10000
    else
      area.children().remove()


  removeAction: (object) =>
    #t = setTimeout(object.children.remove, 5000)
    #clearTimeout(t)
    console.log object


  sendMessage: (e) =>
    e.preventDefault()
    message = $('#new_message').val()
    if @currentChannel?
      @currentChannel.trigger 'new_message', text: message, username: @username
    else
      @dispatcher.trigger 'new_message', text: message, username: @username
    $('#new_message').val('')

  joinChannel: (e) =>
    e.preventDefault()
    @dispatcher.unsubscribe(@currentChannel.name) if @currentChannel?

    channelName = $(e.target).html()
    @currentChannel = @dispatcher.subscribe(channelName)
    @currentChannel.bind 'new_message', @receiveMessage
    $('#chat_history').append @joinTemplate(channelName)

$(document).ready ->
  window.chatApp = new ChatApp
