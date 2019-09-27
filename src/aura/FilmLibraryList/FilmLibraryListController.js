({
    doInit : function(component, event, helper) {
        helper.loadFilms(component);
    },
    
    searchByActor : function(component, event, helper) {
        var nameSegment = component.get("v.nameForSearch");
        if (!nameSegment) {
            nameSegment = '';
        }
        helper.searchFilmByActor(component, nameSegment);
    }

})