/**
 * Created by alaputsky on 9/23/2019.
 */
@IsTest
public with sharing class FilmLibraryTest {
    @isTest static void testCreate() {

        createTestData();

        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI ='https://red-cat-dev-ed.lightning.force.com/services/apexrest/FilmLibrary';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"films":[' +
                '{"film":{"Name__c":"Film 1"},"actors":[{"actor":{"Name__c":"Actor 10"}}]},' +
                '{"film":{"Name__c":"Film 13"},"actors":[{"actor":{"Name__c":"Actor 13"}},{"actor":{"Name__c":"Actor 1"}}]},' +
                '{"film":{"Name__c":"Film 14"},"actors":[{"actor":{"Name__c":"Actor 14"}}]},' +
                '{"film":{"Name__c":"Film 15"},"actors":[{"actor":{"Name__c":"Actor 1"}}]},' +
                '{"film":{"Name__c":"Film 1"},"actors":[{"actor":{"Name__c":"Actor 15"}}]},' +
                '{"film":{"Name__c":"Film 16"},"actors":[]},' +
                '{"film":{"Name__c":"Film 2"},"actors":[]}]}');

        RestContext.request = request;
        FilmLibraryRest.manageFilmLibrary();
        Test.stopTest();

        List<ActorInFilm__c> actorInFilms = new List<ActorInFilm__c>();
        actorInFilms = [
                SELECT Id, Film__r.Name__c, Actor__r.Name__c
                FROM ActorInFilm__c
        ];

        List<List<String>> listOfListsNewStrings = new List<List<String>>();
        List<String> s1 = new List<String>{'Film 13', 'Actor 13'};
        List<String> s2 = new List<String>{'Film 13', 'Actor 1'};
        List<String> s3 = new List<String>{'Film 14', 'Actor 14'};
        List<String> s4 = new List<String>{'Film 15', 'Actor 1'};
        List<String> s5 = new List<String>{'Film 1', 'Actor 15'};
        listOfListsNewStrings.add(s1);
        listOfListsNewStrings.add(s2);
        listOfListsNewStrings.add(s3);
        listOfListsNewStrings.add(s4);
        listOfListsNewStrings.add(s5);

        List<ActorInFilm__c> actorInFilmsToCheck = new List<ActorInFilm__c>();
        for (ActorInFilm__c act : actorInFilms) {
            for (List<String> str : listOfListsNewStrings) {
                if (act.Film__r.Name__c == str[0] && act.Actor__r.Name__c == str[1]) {
                    actorInFilmsToCheck.add(act);
                }
            }
        }

        System.assertEquals(5, actorInFilmsToCheck.size());
    }

    @isTest static void testDelete() {

        createTestData();

        Test.startTest();
        List<ActorInFilm__c> actorInFilms = new List<ActorInFilm__c>();
        actorInFilms = [
                SELECT Id, Film__r.Name__c, Actor__r.Name__c
                FROM ActorInFilm__c
                WHERE Film__r.Name__c LIKE 'Film 1'
                AND Actor__r.Name__c LIKE 'Actor 10'
        ];

        RestRequest request = new RestRequest();
        request.requestURI ='https://red-cat-dev-ed.lightning.force.com/services/apexrest/FilmLibrary/?json={"films":[{"film":{"Name__c":"Film 1"},"actors":[{"actor":{"Name__c":"Actor 10"}}]}';
        request.httpMethod = 'DELETE';
        request.params.put('json', '{"films":[{"film":{"Name__c":"Film 1"},"actors":[{"actor":{"Name__c":"Actor 10"}}]}]}');
        RestContext.request = request;
        FilmLibraryRest.deleteActorInFilms();
        Test.stopTest();

        List<ActorInFilm__c> actorInFilmsToCheck = [
                SELECT Id, Film__r.Name__c, Actor__r.Name__c
                FROM ActorInFilm__c
                WHERE Film__r.Name__c LIKE 'Film 1'
                AND Actor__r.Name__c LIKE 'Actor 10'
        ];

        System.assertNotEquals(actorInFilms.size(), actorInFilmsToCheck.size());
        System.assertEquals(0, actorInFilmsToCheck.size());
    }

    static void createTestData() {
        List<Film__c> films = new List<Film__c>();
        for (Integer i = 1; i < 11; i++) {
            Film__c newFilm = new Film__c(
                    Name__c = 'Film ' + i
            );
            films.add(newFilm);
        }
        insert films;

        List<Actor__c> actors = new List<Actor__c>();
        for (Integer i = 1; i < 11; i++) {
            Actor__c newActor = new Actor__c(
                    Name__c = 'Actor ' + i
            );
            actors.add(newActor);
        }
        insert actors;

        List<ActorInFilm__c> actorInFilm = new List<ActorInFilm__c>();
        Integer j = 9;
        for(Integer i = 0; i < 10; i++) {
            ActorInFilm__c actInFilm = new ActorInFilm__c(
                    Actor__c = actors[i].Id,
                    Film__c = films[i].Id);
            actorInFilm.add(actInFilm);

            ActorInFilm__c actInFilm1 = new ActorInFilm__c(
                    Actor__c = actors[j].Id,
                    Film__c = films[i].Id);
            actorInFilm.add(actInFilm1);
            j--;
        }
        insert actorInFilm;
    }

}