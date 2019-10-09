/**
 * Created by alaputsky on 9/18/2019.
 */
@RestResource(UrlMapping='/FilmLibrary/*')
global with sharing class FilmLibraryRest {
@TestVisible
    private class Wrapper {
        List<FilmWrapper> films;
    }
    private class FilmWrapper {
        Film__c film;
        List<ActorWrapper> actors;
    }
    private class ActorWrapper {
        Actor__c actor;
    }

    @HttpPost
    global static List<ActorInFilm__c> manageFilmLibrary() {
        Wrapper container = (Wrapper)System.JSON.deserialize(
                RestContext.request.requestBody.toString(),
                Wrapper.class
        );

        Map<String, Film__c> mapOfFilms = filmUpsert(container);
        Map<String, Actor__c> mapOfActors = actorUpsert(container);

        return actorInFilmUpsert(container, mapOfFilms, mapOfActors);
    }

    private static Map<String, Film__c> filmUpsert(Wrapper container) {
        Map<String, Film__c> filmsFromRequestToUpsert = new Map<String, Film__c>();

        for(FilmWrapper filmWrapper : container.films) {
            if (!(filmsFromRequestToUpsert.containsKey(filmWrapper.film.Name__c))) {
                filmsFromRequestToUpsert.put(filmWrapper.film.Name__c, filmWrapper.film);
            }
        }

        upsert filmsFromRequestToUpsert.values() Name__c;

        return filmsFromRequestToUpsert;
    }

    private static Map<String, Actor__c> actorUpsert(Wrapper container) {
        Map<String, Actor__c> actorsFromRequestToUpsert = new Map<String, Actor__c>();

        for (FilmWrapper filmWrapper : container.films) {
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                if (!(actorsFromRequestToUpsert.containsKey(actorWrapper.actor.Name__c))) {
                    actorsFromRequestToUpsert.put(actorWrapper.actor.Name__c, actorWrapper.actor);
                }
            }
        }

        upsert actorsFromRequestToUpsert.values() Name__c;

        return actorsFromRequestToUpsert;
    }

    private static List<ActorInFilm__c> actorInFilmUpsert(Wrapper container, Map<String, Film__c> mapOfFilms, Map<String, Actor__c> mapOfActors) {
        Map<String, Set<String>> mapOfFilmAndItsActors = new Map<String, Set<String>>();

        for (FilmWrapper filmWrapper : container.films) {
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                if (!String.isEmpty(actorWrapper.actor.Name__c)) {
                    if (!(mapOfFilmAndItsActors.containsKey(filmWrapper.film.Name__c))) {
                        mapOfFilmAndItsActors.put(filmWrapper.film.Name__c, new Set<String>());
                    }
                    mapOfFilmAndItsActors.get(filmWrapper.film.Name__c).add(actorWrapper.actor.Name__c);
                }
            }
        }
        List<ActorInFilm__c> actorsInFilmsToUpsert = new List<ActorInFilm__c>();

        for (String filmName : mapOfFilmAndItsActors.keySet()) {
            Film__c film = mapOfFilms.get(filmName);
            for (String actorName : mapOfFilmAndItsActors.get(filmName)) {
                Actor__c actor = mapOfActors.get(actorName);
                ActorInFilm__c actorInFilm = new ActorInFilm__c(
                    Actor__c = actor.Id,
                    Film__c = film.Id,
                    Identifier__c = film.Name__c + ':' + actor.Name__c
                );
                actorsInFilmsToUpsert.add(actorInFilm);
            }
        }
        upsert actorsInFilmsToUpsert Identifier__c;

        return actorsInFilmsToUpsert;
    }

    @HttpDelete
    global static void deleteActorInFilms() {
        RestRequest req = RestContext.request;
        String stringOfObjects = req.params.get('json');
        Wrapper container = (Wrapper)System.JSON.deserialize(
                stringOfObjects,
                Wrapper.class
        );

        ActorInFilmsToDelete(container);
    }

    private static void ActorInFilmsToDelete(Wrapper container) {
        List<String> listOfIdentifiers = new List<String>();
        for (FilmWrapper filmWrapper : container.films) {
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                String identifier = filmWrapper.film.Name__c + ':' + actorWrapper.actor.Name__c;
                listOfIdentifiers.add(identifier);
            }
        }

        List<ActorInFilm__c> actorInFilmsToDelete = new List<ActorInFilm__c>();
        actorInFilmsToDelete = [
                SELECT Id, Film__r.Name__c, Actor__r.Name__c
                FROM ActorInFilm__c
                WHERE Identifier__c = :listOfIdentifiers
        ];

        delete actorInFilmsToDelete;
    }
}