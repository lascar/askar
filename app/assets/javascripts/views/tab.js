FichaTab = Backbone.View.extend({
  template: _.template(tabTemplate),
  initialize: function () {
    this.model.bind('click', this.render, this);
    this.model.bind('destroy', this.remove, this);
  },
  render: function () {
    $(this.el).html(this.template(this.model));
    return this;
  },
  remove: function () { /* ... */}
});
var elements = new Elements;
var tab = elements.first;
var ficha = new FichaTab({el:$('tabs'), model: tab});
ficha.render();
