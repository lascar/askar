Ext.define('AM.controller.Elements', {
    extend: 'Ext.app.Controller',

    stores: [
        'Elements'
    ],

    models: [
        'Element'
    ],

    views: [
        'element.List',
        'element.Edit'
    ],

    init: function() {
        this.control({
            'viewport > elementlist': {
                itemdblclick: this.editElement
            },
            'elementedit button[action=save]': {
                click: this.updateElement
            }
        });
    },

    editElement: function(grid, record) {
        var view = Ext.widget('elementedit');

        view.down('form').loadRecord(record);
    },

    updateElement: function(button) {
        var record, value,
            win    = button.up('window'),
            form   = win.down('form'),
            record = form.getRecord(),
            values = form.getValues(),
            csrfToken = Ext.select("meta[name='csrf-token']").elements[0].getAttribute('content');
         
        if (csrfToken) {
            Ext.Ajax.on('beforerequest', function(o) {
               o.defaultHeaders = Ext.apply(o.defaultHeaders || {}, {'X-CSRF-Token': csrfToken});
            });
        }
        
        record.set(values);
        win.close();
        this.getElementsStore().sync();
    }
});
