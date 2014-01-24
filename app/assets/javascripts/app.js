Ext.application({
    name: 'AM',

    appFolder: '/assets/app',

    launch: function() {
        Ext.create('Ext.container.Viewport', {
            layout: 'fit',
            items: [
                {
                    xtype: 'elementlist'
                }
            ]
        });
    },
    controllers: [
        'Elements'
    ],
});
