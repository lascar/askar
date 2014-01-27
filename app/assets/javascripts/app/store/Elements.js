Ext.define('AM.store.Elements', {
    extend: 'Ext.data.Store',
    
    model: 'AM.model.Element',
    autoLoad: true,

    proxy: {
        type: 'rest',
        api: {
            read: 'elements/list',
            update: 'elements/update'
        },
        reader: {
            type: 'json',
            root: 'elements',
            sucessProperty: 'success'
        }
    }
});
