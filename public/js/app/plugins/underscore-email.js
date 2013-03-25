(function() {

  define({
    valid_email_address: function(email) {
      var re;
      re = /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
      return re.test(email);
    }
  });

}).call(this);
