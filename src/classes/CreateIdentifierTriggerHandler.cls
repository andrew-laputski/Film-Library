/**
 * Created by alaputsky on 10/3/2019.
 */

public with sharing class CreateIdentifierTriggerHandler {
    public static List<ActorInFilm__c> identifierCreation(List<ActorInFilm__c> createdAndUpdatedActorInFilms) {
        System.debug('createdAndUpdatedActorInFilms=== ' + createdAndUpdatedActorInFilms[0].Film__r.Name__c);

        List<Id> filmIds = new List<Id>();
        for (ActorInFilm__c actorInFilm : createdAndUpdatedActorInFilms) {
            filmIds.add(actorInFilm.Film__c);
        }

        List<Film__c> films = new List<Film__c>();
        films = [
                SELECT Id, Name__c
                FROM Film__c
                WHERE Id = :filmIds
        ];
        System.debug('films=== ' + films);

        List<Film__c> filmsSorted = new List<Film__c>();
        for (Id filmId : filmIds) {
            for (Film__c film : films) {
                if (film.Id == filmId) {
                    filmsSorted.add(film);
                }
            }
        }
        System.debug('filmsSorted=== ' + filmsSorted);

        List<Id> actorIds = new List<Id>();
        for (ActorInFilm__c actorInFilm : createdAndUpdatedActorInFilms) {
            actorIds.add(actorInFilm.Actor__c);
        }

        List<Actor__c> actors = new List<Actor__c>();
        actors = [
                SELECT Id, Name__c
                FROM Actor__c
                WHERE Id = :actorIds
        ];
        System.debug('actors=== ' + actors);

        List<Actor__c> actorsSorted = new List<Actor__c>();
        for (Id actorId : actorIds) {
            for (Actor__c actor : actors) {
                if (actor.Id == actorId) {
                    actorsSorted.add(actor);
                }
            }
        }
        System.debug('actorsSorted=== ' + actorsSorted);

        Integer i = 0;
        for (ActorInFilm__c actorInFilm : createdAndUpdatedActorInFilms) {
            actorInFilm.Identifier__c = filmsSorted[i].Name__c + ':' + actorsSorted[i].Name__c;
            i++;
        }


        return createdAndUpdatedActorInFilms;
    }
}