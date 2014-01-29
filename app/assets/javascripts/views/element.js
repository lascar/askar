app.FichaElements = Backbone.View.extend({
  el: '#tabs_contents',
  template: _.template('#element-list-template'),
  initialize: function () {
    this.render();
  },
  render: function (elements) {
    console.log("render : " +  app.elements);
    $(this.el).html(this.template(app.elements.toJSON()));
    return this;
  }
});
