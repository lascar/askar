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
        var win    = button.up('window'),
            form   = win.down('form'),
            record = form.getRecord(),
            values = form.getValues(),
            metas, meta, hidden;

        metas = document.getElementsByTagName('meta');
        for (var x=0,y=metas.length; x<y; x++) {
            if (metas[x].name.toLowerCase() == "csrf-token") {
                meta = metas[x].content;
                break;
            }
        }
        hidden = new Ext.form.TextField({xtype: 'hidden', name: 'csrf-token', value: meta});
        form.add(hidden);
        record.set(values);
        win.close();
        this.getElementsStore().sync();
    }
});
