/*jslint browser: true, nomen: true*/
var Elements = Backbone.Collection.extend({
  model: Element,
  url: '/elements',
  initialize: function(){
    this.fetch();
  }
});
