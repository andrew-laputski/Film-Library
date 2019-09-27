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
    global static String manageFilmLibrary() {
        Wrapper container = (Wrapper)System.JSON.deserialize(
                RestContext.request.requestBody.toString(),
                Wrapper.class
        );

        List<Integer> amountOfActorsInEachFilm = new List<Integer>();
        Integer i = 0;
        for (FilmWrapper filmWrapper : container.films) {
            i = 0;
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                i++;
            }
            amountOfActorsInEachFilm.add(i);
        }

        List<Film__c> films = filmInsert(container);
        List<Actor__c> actors = actorInsert(container);

        return JSON.serialize(actorInFilmInsert(films, actors, amountOfActorsInEachFilm));
    }

    private static List<Film__c> filmInsert(Wrapper container) {
        List<Film__c> films = new List<Film__c>();
        films = [
                SELECT Id, Name__c
                FROM Film__c
        ];

        List<String> filmNames = new List<String>();
        for (Film__c film : films) {
            filmNames.add(film.Name__c);
        }

        List<Film__c> filmsFromRequest = new List<Film__c>();
        for(FilmWrapper filmWrapper : container.films) {
            filmsFromRequest.add(filmWrapper.film);
        }

        Set<Film__c> setOfNewFilms = new Set<Film__c>();
        List<String> filmNamesToQuery = new List<String>();
        for (Film__c film : filmsFromRequest) {
            filmNamesToQuery.add(film.Name__c);
            if (!(filmNames.contains(film.Name__c))) {
                setOfNewFilms.add(film);
            }
        }

        List<Film__c> filmsFromRequestToInsert = new List<Film__c>(setOfNewFilms);
        insert filmsFromRequestToInsert;

        List<Film__c> filmsForActorInFilm = new List<Film__c>();
        filmsForActorInFilm.addAll(existingFilm(filmNamesToQuery));

        return filmsForActorInFilm;
    }

    private static List<Film__c> existingFilm (List<String> names) {
        List<Film__c> films = new List<Film__c>();
        films = [
                SELECT Id, Name__c
                FROM Film__c
                WHERE Name__c IN :names
        ];

        List<Film__c> filmsForActorInFilmSorted = new List<Film__c>();
        for (String filmName : names) {
            for (Film__c film : films) {
                if (film.Name__c == filmName) {
                    filmsForActorInFilmSorted.add(film);
                }
            }
        }

        return filmsForActorInFilmSorted;
    }

    private static List<Actor__c> actorInsert(Wrapper container) {
        List<Actor__c> actors = new List<Actor__c>();
        actors = [
                SELECT Id, Name__c
                FROM Actor__c
        ];

        List<String> actorNames = new List<String>();
        for (Actor__c actor : actors) {
            actorNames.add(actor.Name__c);
        }

        List<Actor__c> actorsFromRequest = new List<Actor__c>();
        for (FilmWrapper filmWrapper : container.films) {
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                actorsFromRequest.add(actorWrapper.actor);
            }
        }

        Set<Actor__c> setOfNewActors = new Set<Actor__c>();
        List<String> actorNamesToQuery = new List<String>();
        for (Actor__c actor : actorsFromRequest) {
            actorNamesToQuery.add(actor.Name__c);
            if (!(actorNames.contains(actor.Name__c))) {
                setOfNewActors.add(actor);
            }
        }
        List<Actor__c> actorsFromRequestToInsert = new List<Actor__c>(setOfNewActors);
        insert actorsFromRequestToInsert;

        List<Actor__c> actorsForActorInFilm = new List<Actor__c>();
        actorsForActorInFilm.addAll(existingActor(actorNamesToQuery));

        return actorsForActorInFilm;
    }

    private static List<Actor__c> existingActor (List<String> names) {
        List<Actor__c> actors = new List<Actor__c>();
        actors = [
                SELECT Id, Name__c
                FROM Actor__c
                WHERE Name__c LIKE :names
        ];

        List<Actor__c> filmsForActorInFilmSorted = new List<Actor__c>();
        for (String actorName : names) {
            for (Actor__c actor : actors) {
                if (actor.Name__c == actorName) {
                    filmsForActorInFilmSorted.add(actor);
                }
            }
        }

        return filmsForActorInFilmSorted;
    }

    private static List<ActorInFilm__c> actorInFilmInsert(List<Film__c> films, List<Actor__c> actors, List<Integer> amount) {
        Integer indexOfActorList = 0;
        Integer indexOfAmountList = 0;
        List<List<Id>> listOfListsNewIds = new List<List<Id>>();
        for (Film__c film : films) {
            if(amount[indexOfAmountList] != 0) {
                for (Integer i = 0; i < amount[indexOfAmountList]; i++) {
                    List<Id> listNewIds = new List<Id>();
                    listNewIds.add(film.Id);
                    listNewIds.add(actors[indexOfActorList].Id);
                    listOfListsNewIds.add(listNewIds);
                    indexOfActorList ++;
                }
            }
            indexOfAmountList ++;
        }

        List<ActorInFilm__c> actorInFilms = new List<ActorInFilm__c>();
        actorInFilms = [
                SELECT Film__c, Actor__c
                FROM ActorInFilm__c
        ];

        List<List<Id>> listOfListsExistIds = new List<List<Id>>();
        for (ActorInFilm__c actInFilm : actorInFilms) {
            List<Id> listExistIds = new List<Id>();
            listExistIds.add(actInFilm.Film__c);
            listExistIds.add(actInFilm.Actor__c);
            listOfListsExistIds.add(listExistIds);
        }

        List<ActorInFilm__c> actorInFilmsToInsert = new List<ActorInFilm__c>();
        for (List<Id> newIds : listOfListsNewIds) {
            if (!(listOfListsExistIds.contains(newIds))) {
                ActorInFilm__c actInFilm = new ActorInFilm__c(
                        Film__c = newIds[0],
                        Actor__c = newIds[1]
                );
                actorInFilmsToInsert.add(actInFilm);
            }
        }
        insert actorInFilmsToInsert;

        return actorInFilmsToInsert;
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
        List<List<String>> listOfListsNewStrings = new List<List<String>>();
        for (FilmWrapper filmWrapper : container.films) {
            for (ActorWrapper actorWrapper : filmWrapper.actors) {
                List<String> listNewStrings = new List<String>();
                listNewStrings.add(filmWrapper.film.Name__c);
                listNewStrings.add(actorWrapper.actor.Name__c);
                listOfListsNewStrings.add(listNewStrings);
            }
        }

        List<ActorInFilm__c> actorInFilms = new List<ActorInFilm__c>();
        actorInFilms = [
                SELECT Id, Film__r.Name__c, Actor__r.Name__c
                FROM ActorInFilm__c
        ];

        List<ActorInFilm__c> actorInFilmsToDelete = new List<ActorInFilm__c>();
        for (ActorInFilm__c act : actorInFilms) {
            for (List<String> str : listOfListsNewStrings) {
                if (act.Film__r.Name__c == str[0] && act.Actor__r.Name__c == str[1]) {
                    actorInFilmsToDelete.add(act);
                }
            }
        }
        delete actorInFilmsToDelete;
    }
}