Ext.define('AM.store.Elements', {
    extend: 'Ext.data.Store',

    fields: ['name', 'description'],

    data: [
        {name: 'Ed',    description: 'ed@sencha.com'},
        {name: 'Tommy', description: 'tommy@sencha.com'}
    ]
});
