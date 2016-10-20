@Kodi.module "TVShowApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    ## The TVShow page.
    initialize: (options) ->
      id = parseInt options.id
      tvshow = App.request "tvshow:entity", id
      ## Fetch the tvshow
      App.execute "when:entity:fetched", tvshow, =>
        ## Get the layout.
        @layout = @getLayoutView tvshow
        ## Ensure background removed when we leave.
        @listenTo @layout, "destroy", =>
          App.execute "images:fanart:set", 'none'
        ## Listen to the show of our layout.
        @listenTo @layout, "show", =>
          @getDetailsLayoutView tvshow
          @getSeasons tvshow
        ## Add the layout to content.
        App.regionContent.show @layout

    ## Get the base layout
    getLayoutView: (tvshow) ->
      new Show.PageLayout
        model: tvshow

    ## Build the details layout.
    getDetailsLayoutView: (tvshow) ->
      headerLayout = new Show.HeaderLayout model: tvshow
      @listenTo headerLayout, "show", =>
        teaser = new Show.TVShowTeaser model: tvshow
        detail = new Show.Details model: tvshow
        headerLayout.regionSide.show teaser
        headerLayout.regionMeta.show detail
      @layout.regionHeader.show headerLayout

    getSeasons: (tvshow) ->
      collection = App.request "season:entities", tvshow.get('tvshowid')
      App.execute "when:entity:fetched", collection, =>
        view = App.request "season:list:view", collection
        @layout.regionContent.show view