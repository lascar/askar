/*jslint browser: true, nomen: true*/
var Tools = {
    //zacas childNodes for ie8- count the white space between elements as element
    getChildren: function (node) {
        var i, len, array = [], childs = node.childNodes;
        for (i = 0; i < childs.length; i += 1) {
            if (childs[i].nodeType == 1){
                array.push(childs[i]);
            }
        }
        return array;
    }
}
