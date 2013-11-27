/*jslint browser: true, nomen: true*/
/*global $, jQuery*/
var Lascar = {
  readResponse: function (data) {
    'use strict';
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
    Lascar.displayTab();
    var actions = {
      'list': function () {return Lascar.displayTabContentList(); },
      'show': function () {return Lascar.displayTabContentShow(); }
    };
    try {return actions[action](); }
    catch (err) {return false; }
  },

  displayTab: function () {
    'use strict';
    var action = Lascar.action === "show" ? " " + Lascar.element.id : "",
      suffix = Lascar.action + action,
      tab = Lascar.createOrActiveNode("tab_", suffix, $("#tabs"));
    tab.addClass("tab");
    tab.html(Lascar.controller + "<br>" + suffix);
  },

  createDiv: function (id_name, parent_id, class_name, content) {
    'use strict';
    var new_div = document.createElement('div'), div_parent = document.getElementById(parent_id);
    new_div.setAttribute('id', id_name);
    if (class_name) {
      new_div.setAttribute('class', class_name);
    }
    if (parent_id && parent_id !== "" && div_parent) {
      div_parent.appendChild(new_div);
    }
    console.log(content);
    if (content && div_parent) {
      new_div.innerHTML(content);
    }
    return new_div;
  },

  toogleClass: function (element, old_class, new_class) {
    'use strict';
    element.className = element.className.replace(old_class, new_class);
  },

  desactiveChildren: function (parent_id) {
    'use strict';
    var i, child_nodes = document.getElementById(parent_id).children;
    if (child_nodes) {
      for (i = 0; i < child_nodes.length; i += 1) {
        if (!/inactive/.test(child_nodes[i].className)) {
          Lascar.toogleClass(child_nodes[i], /active/, "inactive");
        }
      }
    }
  },

  createOrActiveNode: function (prefix, suffix, parent_node) {
    'use strict';
    var node, id = prefix + Lascar.controller + "_" + Lascar.action + suffix,
      parent_id = parent_node.attr('id');
    Lascar.desactiveChildren(parent_id);
    node = document.getElementById(id) || this.createDiv(id, parent_id);
    node.setAttribute('class', "active");
    return $(node);
  },

  displayTabContentShow: function () {
    'use strict';
    var label_field_raw_id, text_field_raw_id,
      tab_content =  Lascar.createOrActiveNode("", "", $("#tabs_contents"));
    Lascar.desactiveChildren($("#tabs_contents").attr('id'));
    console.log(Lascar.fields_to_show);
    $.each(Lascar.fields_to_show, function (index, field) {
      console.log(field);
      var field_raw_id = Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field;
      label_field_raw_id = Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field + "_label";
      text_field_raw_id =  Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field + "_text";
      var field_raw = Lascar.createDiv(field_raw_id, tab_content.attr('id'), "field_raw " + field);
      console.log(label_field_raw_id);
      console.log(field_raw_id);
      console.log( "label " + field);
      Lascar.createDiv(label_field_raw_id, field_raw_id, "label " + field, field);
      Lascar.createDiv(text_field_raw_id, field_raw_id, "text " + field, Lascar.element[field]);
      //field_raw = Lascar.buidFieldRaw(field);
      //tab_content.append(field_raw);
    });
  },

  buidFieldRaw: function (field) {
    'use strict';
    var field_raw_id = Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field,
      label_field_raw = $("<div id='" + Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field + "_label'></div>"),
      text_field_raw = $("<div id='" + Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field + "_text'></div>"),
      field_raw = $("<div id='" + Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field + "'></div>");
    label_field_raw.addClass("label " + field);
    text_field_raw.addClass("text " + field);
    field_raw.addClass("field_raw " + field);
    label_field_raw.text(field);
    text_field_raw.text(Lascar.element[field]);
    field_raw.append(label_field_raw).append(text_field_raw);
    return field_raw;
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
      dataType: 'json',
      success: function (data) {
        Lascar.readResponse(data);
      }
    });
  }
}

