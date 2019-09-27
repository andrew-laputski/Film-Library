/**
 * Created by alaputsky on 9/16/2019.
 */

public with sharing class FilmLibraryController {    

    @AuraEnabled
    public static List<Film__c> getFilms() {
        List<Film__c> films = [
                SELECT Id, Name__c, (SELECT Actor__r.Name__c FROM ActorInFilms__r)
                FROM Film__c
                ORDER BY Name__c ASC 
        ];

        return films;
    }

    @AuraEnabled
    public static List<Film__c> searchFilmByNameBack(String nameSegment) {
        String nameSegmentSoql = '%' + nameSegment + '%';
        List<ActorInFilm__c> actors = [
                SELECT Id, Actor__r.Name__c, Film__r.Id
                FROM ActorInFilm__c
                WHERE Actor__r.Name__c LIKE :nameSegmentSoql
        ];

        List<Id> filmIds = new List<Id>();
        for (ActorInFilm__c act : actors) {
            filmIds.add(act.Film__r.Id);
        }

        List<Film__c> films = [
                SELECT Id, Name__c, (SELECT Actor__r.Name__c FROM ActorInFilms__r)
                FROM Film__c
                WHERE Id = :filmIds
        ];

        return films;
    }

    @AuraEnabled
    public static List<String> getActors() {
        List<Actor__c> actors = [
                SELECT Id, Name__c
                FROM Actor__c
        ];

        List<String> actorNames = new List<String>();
        for (Actor__c act : actors) {
            actorNames.add(act.Name__c);
        }

        return actorNames;
    }
}