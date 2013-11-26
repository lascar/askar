/*jslint browser: true, nomen: true*/
/*global $, jQuery*/
var Lascar = {
  readResponse: function (data) {
    Lascar.controller = data.controller;
    Lascar.action = data.action;
    Lascar.elements = data.elements;
    Lascar.fields = data.fields;
    Lascar.fields_to_show = data.fields_to_show;
    Lascar.element = data.element;
    Lascar.actions = data.actions;
    Lascar.executeResponse(Lascar.action);
  },
  executeResponse: function (action) {
    "use strict";
    var actions = {
      'list': function () {return Lascar.displayList(); },
      'show': function () {return Lascar.displayShow(); }
    };
    try {return actions[action](); }
    catch(err) {return false; }
  },

  displayList: function () {
    Lascar.displayTab();
    Lascar.displayTabContentList();
  },

  displayShow: function () {
    Lascar.displayTab();
    Lascar.displayTabContentShow();
  },

  displayTab: function () {
    'use strict';
    var suffix = "";
    var tab = Lascar.createOrActiveNode("tab_", suffix, $("#tabs"));
    tab.html(Lascar.controller + "<br>" + Lascar.action);
  },

  createOrActiveNode: function (id_pref, id_suf, parent_node){
    var class_node = parent_node.data("child");
    $("." + class_node).removeClass("active").addClass("inactive");
    node = $("#" + id_pref + Lascar.controller + "_" + Lascar.action + id_suf)
    if (node.length < 1) {
      node = $("<div id='" + id_pref + Lascar.controller + "_" + Lascar.action + id_suf + "'></div>");
      parent_node.append(node);
    }
    node.addClass(class_node + " active");
    return node;
  },

  displayTabContentShow: function () {
    'use strict';
    var tab_content =  Lascar.createOrActiveNode("", "", $("#tabs_contents"));
  },

  displayTabContentList: function () {
    'use strict';
    var element_raw, field_content_div, link_action,
      tab_content = Lascar.createOrActiveNode("", "", $("#tabs_contents"));
    tab_content.addClass('tab_content');
    $.each(Lascar.elements, function (index, element) {
      element_raw = Lascar.rawBuild(element.id);
      $.each(Lascar.fields_to_show, function (index, field) {
        field_content_div = Lascar.fieldBuild(element, field);
        element_raw.append(field_content_div);
      });
      $.each(Lascar.actions, function (index, action) {
        link_action = Lascar.buildLinkAction(element, action);
        element_raw.append(link_action);
      });
      tab_content.append(element_raw);
    });
  },

  fieldBuild: function (element, field) {
    'use strict';
    var field_content_div = $("<div id='" + Lascar.controller + "_" + Lascar.action + "_" + element.id + "'></div>");
    field_content_div.addClass("field " + field);
    field_content_div.text(element[field]);
    return field_content_div;
  },

  rawBuild: function (id) {
    'use strict';
    var element_raw = $("<div id='element_raw_" + id + "'></div>");
    element_raw.addClass("element_raw");
    return element_raw;
  },

  buildLinkAction: function (element, action) {
    'use strict';
    var div_action, link_action;
    div_action = $("<div id='div_link_" + Lascar.controller + "_" + action + "_" + element.id + "'></div>");
    div_action.addClass("div_link_" + action + " field");
    link_action = $("<a id='link_" + Lascar.controller + "_" + action + "_" + element.id + "'>" + action + "</a>");
    link_action.addClass("link_" + action);
    link_action.on('click', function () { Lascar.lauchAction(element.id, action); });
    div_action.append(link_action);
    return div_action;
  },

  lauchAction: function (element_id, action) {
    'use strict';
    $.ajax({
      url: Lascar.controller + "/" + action + "/" + element_id,
      type: "POST",
      dataType:'json',
      success: function (data) {
        Lascar.readResponse(data);
      },
      error: function (xhr, ajaxOptions, thrownError) {
        console.log(xhr.status);
        console.log(thrownError);
      }
    });
  }
}

