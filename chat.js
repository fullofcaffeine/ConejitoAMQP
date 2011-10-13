Chat = {
  _nickname:null,
  _interval_id:null,

  initialize:function() {
    this._init_handlers();
  },

  _init_handlers:function() {
    this._setup_dialog = $('#setup_dialog').dialog(
      {height:115,
        width:507,
        resizable:false
    }
    );
    $('#setup_form').bind('submit',this._setup);
    $('#chat_form').bind('submit',this._broadcast_message);
  },

  _setup:function() {
    var _this = Chat;
    alert('d');
    _this._nickname = $('#nickname').attr('value');
    $.ajax({
      url:"/app/setup",
      data: {nickname:_this._nickname},
      success:function(data) {
        $('#setup_dialog').dialog('close');
        var fm = _this._fetch_messages;
        fm();
      }

    });
    return false;
  },

  _fetch_messages:function() {
    var _this = Chat;
    $.ajax({
      type: "GET",
      url:"/app/fetch_messages",
      async: true,
      timeout: 50000,
      data: "nickname="+_this._nickname,
      success:function(data) {
        _this._append_message(data);
        setTimeout(
          _this._fetch_messages,
          50
        );
      }});
  },

  _append_message:function(msg) {
    var _this = this;
    $('#messages').append(
      "<div class='msg'>" + msg + "</div>"
    );
    _this._scroll_chat();
  },

  _scroll_chat:function(div) {
    $('#messages')[0].scrollTop = $('#messages')[0].scrollHeight;
  },

  _broadcast_message:function() {
    var _this = Chat;
    $.ajax({
      url:"/app/broadcast_message",
      data: "nickname="+_this._nickname+"&message="+$("#chat-msg").attr('value'),
      onsuccess:function(data) {
        $('#chat-msg').attr('value','');
      }
      });
      return false;
  }
}

$(document).ready(function() {
  Chat.initialize();
});
