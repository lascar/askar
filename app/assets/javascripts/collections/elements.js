/*jslint browser: true, nomen: true*/
app.Elements = Backbone.Collection.extend({
  model: Element,
  url: '/elements',
  initialize: function(){
    this.fetch();
  }
});
