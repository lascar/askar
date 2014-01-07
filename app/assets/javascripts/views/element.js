FichaElement = Backbone.View.extend({
  template: _.template(elementTemplate),
  initialize: function () {
    this.model.bind('change', this.render, this);
    this.model.bind('destroy', this.remove, this);
  },
  render: function () {
    console.log(this.model);
    $(this.el).html(this.template(this.model.toJSON()));
    return this;
  },
  remove: function () { /* ... */}
});
var elements = new Elements;
var element = elements.first;
var ficha = new FichaElement({el:$('body'), model: element});
ficha.render();
