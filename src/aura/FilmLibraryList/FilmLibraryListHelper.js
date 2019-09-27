({
    loadFilms : function(component) {
        var action = component.get("c.getFilms");
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.FilmLibrary", response.getReturnValue());
                component.set("v.FilmLibraryList", response.getReturnValue());
                this.updateTotal(component);
            }
        });
        $A.enqueueAction(action);

        var actorAction = component.get("c.getActors");
        actorAction.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = [];
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    var item = {
                        "label": response.getReturnValue()[i],
                        "value": response.getReturnValue()[i]
                    };
                    items.push(item);
                }
                component.set("v.options", items);
            }
        });
        $A.enqueueAction(actorAction);
    },
     
    updateTotal : function(component) {
        var films = component.get("v.FilmLibrary");
        component.set("v.totalFilms", films.length);
    },

    searchFilmByActor : function(component, nameSegmentParam) {
        var action = component.get('c.searchFilmByNameBack');
        action.setParams({ nameSegment : nameSegmentParam});
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.FilmLibrary', response.getReturnValue());
                component.set("v.FilmLibraryList", response.getReturnValue());

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }

})