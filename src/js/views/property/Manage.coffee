define [
  "jquery"
  "underscore"
  "backbone"
  'models/Property'
  'models/Unit'
  'models/Lease'
  'models/Inquiry'
  "i18n!nls/property"
  "i18n!nls/common"
  "underscore.inflection"
  'templates/property/manage'
  "templates/property/menu/show"
  "templates/property/menu/reports"
  "templates/property/menu/building"
  "templates/property/menu/actions"
], ($, _, Parse, Property, Unit, Lease, Inquiry, i18nProperty, i18nCommon, inflection) ->

  class ManagePropertyView extends Parse.View

    el: '#main'
    
    events:
      'click .edit-property-picture': 'editProfilePicture'
      "submit #property-picture-upload-form" : 'save'

    initialize: (attrs) ->
      
      @model.prep('units')
      @model.prep('leases')
      @model.prep('listings')
      @model.prep('inquiries')
      
      @listenTo @model, 'change:image_profile', @refresh
      @listenTo @model, 'destroy', @clear

      @listenTo Parse.Dispatcher, 'user:logout', @clear

      @baseUrl = if @model.get("network") then "/properties/#{@model.id}" else "/inside"

      @file = false
      
      # Render immediately, as we will display a subview
      @render()
      @changeSubView attrs.path, attrs.params

    # Re-render the contents of the property item.
    render: ->
      vars = _.merge @model.toJSON(),
        publicUrl: @model.publicUrl()
        cover: @model.cover 'profile'
        i18nProperty: i18nProperty
        i18nCommon: i18nCommon
        hasNetwork: @model.get("network")
        baseUrl: @baseUrl
      
      @$el.html JST["src/js/templates/property/manage.jst"](vars)
      @$form = @$("#property-picture-upload-form")
      @$("[rel=tooltip]").tooltip()
      @

    changeSubView: (path, params) =>
      
      # Remove the leading "/" and split into components
      # urlComponents = e.currentTarget.pathname.substring(1).split("/")
      
      action = if path then path.split("/") else Array('units')

      @$(".page-header .nav-tabs > li.active").removeClass("active")
      
      if action.length is 1 or action[0] is "add"
        name = "views/property/sub/#{action.join("/")}"

        # See if we should apply an active tab style
        if action[0] isnt "add" then @$(".page-header .nav-tabs ##{action[0]}-tab").addClass("active")

        @renderSubView name, model: @model, params: params, forNetwork: true, baseUrl: @baseUrl
        
      else

        # Subnode view
        node = action[0][0].toUpperCase() + inflection.singularize[action[0]].substring(1) # units => Unit
        subid = action[1]
        subaction = if action[2] then "sub/#{action[2]}" else "show"
        name = "views/#{node}/#{subaction}"

        # Load the model if it exists.
        submodel = if @model[action[0]] then @model[action[0]].get(subid) else false

        if submodel
          @renderSubView name, property: @model, model: submodel, forNetwork: true, baseUrl: @baseUrl
        # Else get it from the server.
        else
          nodeType = switch action[0]
            when "inquiries" then Inquiry
            when "leases" then Lease
            when "units" then Unit
          (new Parse.Query(nodeType)).get subid, success: (submodel) =>
            @renderSubView name, property: @model, model: submodel, forNetwork: true, baseUrl: @baseUrl


    renderSubView: (name, vars) =>
      @subView.trigger "view:change" if @subView
      @$('.content').removeClass 'in'
      require [name], (PropertySubView) =>
        @subView = new PropertySubView(vars).render()
        @$('.content').addClass 'in'
  
    # Re-render the contents of the property item.
    refresh: ->
      @$('#property-picture img').prop('src', @model.cover('profile'))
    
    clear: =>
      @undelegateEvents()
      @stopListening()
      @subView.trigger "view:change" if @subView
      Parse.history.navigate "", true
      delete this
    
    editProfilePicture: ->
      
      _this = @ # Keep for below

      require ['jquery.fileupload', 'jquery.fileupload-fp', 'jquery.fileupload-pr'],  =>
        
        # Initiate the file upload.
        @$form.fileupload
          autoUpload: true
          type: "POST"
          dataType: "json"
          # fileInput: '#file-input'
          filesContainer: _this.$('#preview-property-picture')
          multipart: false # Tell Fileupload to keep file as binary, as Parse only takes binary files.
          context: @$form[0]
          submit: (e, data) ->
            data.url = "https://api.parse.com/1/files/" + data.files[0].name
          send: (e, data) ->
            delete data.headers['Content-Disposition']; # Parse does not accept this header.
          done: (e, data) ->
            _this.file = data.result

            # Defer to our photo rendering method.
            that = _this.$(this).data("blueimp-fileupload") or $(this).data("fileupload")
            that._transition(data.context)
            
            # data.context.each (index) ->
            #   node = $(this)
            #   that._transition(node).done ->
            #     node.remove()

            _this.$('#preview-property-picture img').prop('src', _this.file.url)

            
        @$('#edit-property-picture-modal').modal()
        
    save: (e) =>
      e.preventDefault()
      if @file
        @model.save image_thumb: @file.url, image_profile: @file.url, image_full: @file.url
        @$('#edit-property-picture-modal').modal('hide')
      else 
        @$form.after """
          <div class="alert alert-block alert-error fade in">
            <p class="message">#{i18nCommon.errors.no_picture}</p>
          </div>
        """