var UserService = {
   
    logout: function () {
      localStorage.clear();
      // Hide user-related sections
      $('#userDiv').hide();
      $('#commentDisplay').hide();
      $('#commentFormModal').hide();
      $('#commentsDisplay').hide();

      // Show the login section
      $('#LoginDiv').show();
    }
  };
  