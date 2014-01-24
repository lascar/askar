Ext.define('AM.view.element.List' ,{
    extend: 'Ext.grid.Panel',
    alias : 'widget.elementlist',

    title : 'All Elements',

    store: 'Elements',

    initComponent: function() {
        this.columns = [
            {header: 'Name',  dataIndex: 'name',  flex: 1},
            {header: 'Description', dataIndex: 'description', flex: 1}
        ];

        this.callParent(arguments);
    }
});
